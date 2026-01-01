<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Restaurant;
use App\Models\User;
use App\Services\GeoService;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Inertia\Inertia;

class RestaurantController extends Controller
{
    protected GeoService $geoService;

    public function __construct(GeoService $geoService)
    {
        $this->geoService = $geoService;
    }

    /**
     * Display a listing of restaurants (e.g., the "main page").
     */
    public function index(Request $request)
    {
        $this->authorize('viewAny', Restaurant::class);

        // Try to get last known coordinates from session
        $geo = $this->geoService->getValidGeoFromSession($request);
        $lat = $geo['lat'] ?? null;
        $lng = $geo['lng'] ?? null;

        // Build query with optional distance calculation
        $restaurants = Restaurant::query()
            ->select(['id', 'name', 'address', 'latitude', 'longitude', 'rating', 'description', 'opening_hours'])
            ->when($lat !== null && $lng !== null, fn ($q) => $q->withDistanceTo($lat, $lng))
            ->with(['images', 'foodTypes.menuItems'])
            ->latest('rating')
            ->get()
            ->map(fn ($restaurant) => $this->formatRestaurant($restaurant));

        return Inertia::render('Customer/Restaurants/Index', [
            'restaurants' => $restaurants,
        ]);
    }

    /**
     * Display the specified restaurant along with its categories, menu items, allergens, images.
     */
    public function show(Request $request, Restaurant $restaurant)
    {
        $this->authorize('view', $restaurant);

        // Try to get last known coordinates from session (set by MapController)
        $geo = $this->geoService->getValidGeoFromSession($request);
        $lat = $geo['lat'] ?? null;
        $lng = $geo['lng'] ?? null;

        // Fetch restaurant with optional distance calculation in one query
        $restaurant = Restaurant::query()
            ->whereKey($restaurant->getKey())
            ->when($lat !== null && $lng !== null, fn ($q) => $q->withDistanceTo($lat, $lng))
            ->with([
                'foodTypes.menuItems.images',
                'menuItems.allergens',
                'images',
                'reviews.customer.user',
                'reviews.images',
            ])
            ->firstOrFail();

        return Inertia::render('Customer/Restaurants/Show', [
            'restaurant' => $this->formatRestaurant($restaurant),
            'isFavorited' => $this->isRestaurantFavorited($restaurant, $request->user()),
        ]);
    }

    /**
     * Toggle favorite status for a restaurant.
     *
     * Note: Auth middleware ensures authenticated user.
     * Customer existence check below handles authorization.
     */
    public function toggleFavorite(Request $request, Restaurant $restaurant)
    {
        $user = $request->user();
        $customer = $user->customer;

        if (! $customer) {
            return back()->with('error', 'Only customers can favorite restaurants.');
        }

        // Wrap in transaction to prevent race conditions
        $message = \DB::transaction(function () use ($customer, $restaurant) {
            // Check if already favorited
            $isFavorited = $customer->favoriteRestaurants()->where('restaurant_id', $restaurant->id)->exists();

            if ($isFavorited) {
                // Remove from favorites
                $customer->favoriteRestaurants()->detach($restaurant->id);

                // Reorder remaining favorites to ensure consecutive ranks
                $remainingFavorites = $customer->favoriteRestaurants()->orderBy('favorite_restaurants.rank')->get();
                $remainingFavorites->each(function ($favRestaurant, $index) use ($customer) {
                    $customer->favoriteRestaurants()->updateExistingPivot($favRestaurant->id, ['rank' => $index + 1]);
                });

                return 'Restaurant removed from favorites.';
            } else {
                // Add to favorites with auto-assigned rank
                // Get the current maximum rank and add 1 (lower priority = higher number)
                $maxRank = $customer->favoriteRestaurants()->max('favorite_restaurants.rank') ?? 0;
                $customer->favoriteRestaurants()->attach($restaurant->id, [
                    'rank' => $maxRank + 1,
                ]);

                return 'Restaurant added to favorites!';
            }
        });

        // Return back with success message
        return back()->with('success', $message);
    }

    /**
     * Check if a restaurant is favorited by the current user.
     */
    private function isRestaurantFavorited(Restaurant $restaurant, ?User $user): bool
    {
        if (! $user || ! $user->customer) {
            return false;
        }

        return $user->customer->favoriteRestaurants()
            ->where('restaurant_id', $restaurant->id)
            ->exists();
    }

    private function formatRestaurant(Restaurant $restaurant): array
    {
        return [
            'id' => $restaurant->id,
            'name' => $restaurant->name,
            'address' => $restaurant->address,
            'latitude' => $restaurant->latitude,
            'longitude' => $restaurant->longitude,
            'rating' => $restaurant->rating,
            'description' => $restaurant->description,
            'opening_hours' => $restaurant->opening_hours,
            'distance' => isset($restaurant->distance) ? $this->geoService->formatDistance($restaurant->distance) : null,
            'images' => $restaurant->images->map(fn ($img) => [
                'id' => $img->id,
                'url' => $img->url,
                'is_primary_for_restaurant' => $img->is_primary_for_restaurant,
            ]),
            'food_types' => $restaurant->foodTypes->map(fn ($ft) => [
                'id' => $ft->id,
                'name' => $ft->name,
                'menu_items' => $ft->menuItems->map(fn ($mi) => [
                    'id' => $mi->id,
                    'name' => $mi->name,
                    'price' => $mi->price,
                    'description' => $mi->description,
                    'images' => $mi->relationLoaded('images') ? $mi->images->map(fn ($img) => [
                        'id' => $img->id,
                        'url' => $img->url,
                        'is_primary_for_menu_item' => $img->is_primary_for_menu_item,
                    ]) : [],
                    'allergens' => $mi->relationLoaded('allergens') ? $mi->allergens->map(fn ($al) => [
                        'id' => $al->id,
                        'name' => $al->name,
                    ]) : [],
                ]),
            ]),
            'reviews' => $restaurant->relationLoaded('reviews') ? $restaurant->reviews->map(fn ($review) => [
                'id' => $review->id,
                'rating' => $review->rating,
                'title' => $review->title,
                'content' => $review->content,
                'created_at' => $review->created_at->toIso8601String(),
                'user_name' => $review->customer?->user?->name ?? 'Anonymous',
                'customer_user_id' => $review->customer_user_id,
                'images' => $this->formatReviewImages($review->images),
            ]) : [],
        ];
    }

    private function formatReviewImages(Collection $images): Collection
    {
        return $images
            ->filter(fn ($img) => ! empty($img->image))
            ->map(fn ($img) => [
                'id' => $img->id,
                'url' => $img->url,
            ])->values();
    }
}
