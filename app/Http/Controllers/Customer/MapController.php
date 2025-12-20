<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Restaurant;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class MapController extends Controller
{
    /**
     * Display a map of restaurants.
     *
     * Optionally filters by geolocation if lat, lng, and radius are provided.
     *
     * @param  Request  $request  The incoming HTTP request, optionally containing
     *                            'lat' (float), 'lng' (float), and 'radius' (float, km)
     *                            query parameters for geolocation filtering.
     * @return Response Inertia response rendering the Customer/Map/Index page with:
     *                  - 'restaurants': a collection of restaurants including
     *                  id, name, address, latitude, longitude, rating,
     *                  description, opening_hours, and related images and
     *                  foodTypes.menuItems.
     *                  - 'filters': an array with 'lat', 'lng', and 'radius'
     *                  representing the applied geolocation filter values.
     */
    public function index(Request $request): Response
    {
        $this->authorize('viewAny', Restaurant::class);

        // Validate optional geolocation parameters
        $validated = $request->validate([
            'lat' => 'nullable|numeric|between:-90,90',
            'lng' => 'nullable|numeric|between:-180,180',
            'radius' => 'nullable|numeric|min:0.1|max:100', // Radius in kilometers
        ]);

        $latitude = $validated['lat'] ?? null;
        $longitude = $validated['lng'] ?? null;
        $radius = $validated['radius'] ?? 50; // Default 50km radius

        $query = Restaurant::with(['images', 'foodTypes.menuItems'])
            ->select([
                'id',
                'name',
                'address',
                'latitude',
                'longitude',
                'rating',
                'description',
                'opening_hours',
            ])
            ->whereNotNull('latitude')
            ->whereNotNull('longitude');

        // TODO: move this to a seperate helper finction outside the controller scope
        // Apply geolocation filtering if coordinates are provided
        // Uses Haversine formula to calculate distance
        if ($latitude !== null && $longitude !== null) {
            // Approximate kilometers per degree of latitude/longitude (used for bounding box pre-filter)
            $kmPerDegree = 111;

            // Clamp latitude to avoid pole issues (bounding box would explode)
            $clampedLatitude = max(min($latitude, 85.0), -85.0);

            // Bounding box pre-filter (approximately 1 degree ≈ 111km)
            $latDelta = $radius / $kmPerDegree;
            $lngDelta = $radius / ($kmPerDegree * cos(deg2rad($clampedLatitude)));

            $earthRadiusKm = 6371; // Earth's radius in kilometers

            $query->whereBetween('latitude', [$latitude - $latDelta, $latitude + $latDelta])
                ->whereBetween('longitude', [$longitude - $lngDelta, $longitude + $lngDelta])
                ->selectRaw(
                    '(? * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) AS distance',
                    [$earthRadiusKm, $latitude, $longitude, $latitude]
                )
                ->having('distance', '<=', $radius)
                ->orderBy('distance');
        } else {
            // Default sorting by rating if no geolocation
            $query->latest('rating');
        }

        $restaurants = $query->get()
            ->map(fn (Restaurant $restaurant) => [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'address' => $restaurant->address,
                'latitude' => (float) $restaurant->latitude,
                'longitude' => (float) $restaurant->longitude,
                'rating' => $restaurant->rating,
                'description' => $restaurant->description,
                'opening_hours' => $restaurant->opening_hours,
                'distance' => isset($restaurant->distance) ? round($restaurant->distance, 2) : null,
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
            ]);

        return Inertia::render('Customer/Map/Index', [
            'restaurants' => $restaurants,
            'filters' => [
                'lat' => $latitude,
                'lng' => $longitude,
                'radius' => $radius,
            ],
        ]);
    }
}
