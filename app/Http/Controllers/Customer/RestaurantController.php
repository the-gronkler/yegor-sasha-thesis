<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Restaurant;
use App\Services\GeoService;
use Illuminate\Http\Request;
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
        $query = Restaurant::query()
            ->select(['id', 'name', 'address', 'latitude', 'longitude', 'rating', 'description', 'opening_hours'])
            ->when($lat !== null && $lng !== null, fn ($q) => $q->withDistanceTo($lat, $lng))
            ->with(['images', 'foodTypes.menuItems'])
            ->latest('rating');

        $restaurants = $query->get()
            ->map(function ($restaurant) {
                return [
                    'id' => $restaurant->id,
                    'name' => $restaurant->name,
                    'address' => $restaurant->address,
                    'latitude' => $restaurant->latitude,
                    'longitude' => $restaurant->longitude,
                    'rating' => $restaurant->rating,
                    'description' => $restaurant->description,
                    'opening_hours' => $restaurant->opening_hours,
                    'distance' => $this->geoService->formatDistance($restaurant->distance),
                    'images' => $restaurant->images->map(fn ($img) => [
                        'id' => $img->id,
                        'url' => $img->image,
                        'is_primary_for_restaurant' => $img->is_primary_for_restaurant,
                    ]),
                    'food_types' => $restaurant->foodTypes->map(fn ($ft) => [
                        'id' => $ft->id,
                        'name' => $ft->name,
                        'menu_items' => $ft->menuItems->map(fn ($mi) => [
                            'id' => $mi->id,
                            'name' => $mi->name,
                        ]),
                    ]),
                ];
            });

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
        // Uses when() for conditional scope application
        $restaurant = Restaurant::query()
            ->whereKey($restaurant->getKey())
            ->when($lat !== null && $lng !== null, fn ($q) => $q->withDistanceTo($lat, $lng))
            ->with([
                'foodTypes.menuItems.images',
                'menuItems.allergens',
                'images',
            ])
            ->firstOrFail();

        // Prepare data for Inertia
        return Inertia::render('Customer/Restaurants/Show', [
            'restaurant' => [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'address' => $restaurant->address,
                'latitude' => $restaurant->latitude,
                'longitude' => $restaurant->longitude,
                'description' => $restaurant->description,
                'rating' => $restaurant->rating,
                'opening_hours' => $restaurant->opening_hours,
                'distance' => $this->geoService->formatDistance($restaurant->distance),
                // relations:
                'food_types' => $restaurant->foodTypes->map(fn ($ft) => [
                    'id' => $ft->id,
                    'name' => $ft->name,
                    'menu_items' => $ft->menuItems->map(fn ($mi) => [
                        'id' => $mi->id,
                        'name' => $mi->name,
                        'price' => $mi->price,
                        'description' => $mi->description,
                        'images' => $mi->images->map(fn ($img) => [
                            'id' => $img->id,
                            'url' => $img->image,   // make sure Model attribute
                            'is_primary_for_menu_item' => $img->is_primary_for_menu_item,
                        ]),
                        'allergens' => $mi->allergens->map(fn ($al) => [
                            'id' => $al->id,
                            'name' => $al->name,
                        ]),
                    ]),
                ]),
                'restaurant_images' => $restaurant->images->map(fn ($img) => [
                    'id' => $img->id,
                    'url' => $img->image,
                    'is_primary_for_restaurant' => $img->is_primary_for_restaurant,
                ]),
            ],
        ]);
    }
}
