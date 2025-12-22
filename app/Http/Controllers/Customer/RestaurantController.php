<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Restaurant;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Inertia\Inertia;

class RestaurantController extends Controller
{
    /**
     * Display a listing of restaurants (e.g., the "main page").
     */
    public function index(Request $request)
    {
        $this->authorize('viewAny', Restaurant::class);
        // TODO: limit selection of restaurants by user's geolocation, accept filtering/sorting? params
        // Fetch restaurants with their images, food types, and menu items
        $restaurants = Restaurant::with(['images', 'foodTypes.menuItems'])
            ->select(['id', 'name', 'address', 'latitude', 'longitude', 'rating', 'description', 'opening_hours'])
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

        // Load related data
        $restaurant->load([
            'foodTypes.menuItems.images',         // food types → menu items → images
            'menuItems.allergens',                // all allergens of menu items
            'images',                              // restaurant images
            'reviews.customer.user',               // reviews with customer and user details
            'reviews.images',                      // review images
        ]);

        return Inertia::render('Customer/Restaurants/Show', [
            'restaurant' => $this->formatRestaurant($restaurant),
        ]);
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
