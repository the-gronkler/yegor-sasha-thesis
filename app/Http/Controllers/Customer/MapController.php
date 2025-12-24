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
            'radius' => 'nullable|numeric|min:0|max:100', // allow 0 == "no range"
        ]);

        $latitude = $validated['lat'] ?? null;
        $longitude = $validated['lng'] ?? null;

        // If radius is omitted -> keep your default.
        // If radius is explicitly 0 -> interpret as "no range".
        $radius = array_key_exists('radius', $validated)
            ? (float) $validated['radius']
            : 50.0;

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

        $earthRadiusKm = 6371; // Earth's radius in kilometers

        // Apply geolocation filtering if coordinates are provided
        // Uses Haversine formula to calculate distance
        if ($latitude !== null && $longitude !== null) {
            // Always compute distance when we have coords so we can order by it
            $query->selectRaw(
                '(? * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) AS distance',
                [$earthRadiusKm, $latitude, $longitude, $latitude]
            );

            if ($radius > 0) {
                // Bounding box only when radius is limiting results
                $kmPerDegree = 111;
                $clampedLatitude = max(min($latitude, 85.0), -85.0);

                $latDelta = $radius / $kmPerDegree;
                $lngDelta = $radius / ($kmPerDegree * cos(deg2rad($clampedLatitude)));

                // Bounding box filter for initial narrowing (requires full table scan within box).
                // For better performance on large datasets, consider using MySQL's spatial data types
                // and indexes (POINT, SPATIAL INDEX) instead of separate lat/lng columns.
                $query->whereBetween('latitude', [$latitude - $latDelta, $latitude + $latDelta])
                    ->whereBetween('longitude', [$longitude - $lngDelta, $longitude + $lngDelta])
                    ->having('distance', '<=', $radius);
            }

            $query->orderBy('distance');
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
