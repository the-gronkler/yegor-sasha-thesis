<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Restaurant;
use App\Services\GeoService;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class MapController extends Controller
{
    private const MAX_RESTAURANTS_LIMIT = 250;

    protected GeoService $geoService;

    public function __construct(GeoService $geoService)
    {
        $this->geoService = $geoService;
    }

    /**
     * Display a map of restaurants.
     *
     * Optionally filters by geolocation if lat, lng, and radius are provided.
     *
     * Performance optimizations:
     * - Only loads 'images' relation (NOT foodTypes.menuItems - huge payload reduction)
     * - Uses model scopes for clean, maintainable geospatial logic
     * - Limits to 250 restaurants max (protects JSON payload + Mapbox rendering)
     * - Uses MariaDB ST_Distance_Sphere or improved Haversine fallback
     *
     * @param  Request  $request  The incoming HTTP request, optionally containing
     *                            'lat' (float), 'lng' (float), and 'radius' (float, km)
     *                            query parameters for geolocation filtering.
     * @return Response Inertia response rendering the Customer/Map/Index page with:
     *                  - 'restaurants': a collection of restaurants including
     *                  id, name, address, latitude, longitude, rating,
     *                  description, opening_hours, and related images.
     *                  Distance (km, rounded to 2 decimals) included when lat/lng provided.
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
            'radius' => 'nullable|numeric|min:0|max:'.GeoService::MAX_RADIUS_KM, // allow 0 == "no range"
        ]);

        $latitude = $validated['lat'] ?? null;
        $longitude = $validated['lng'] ?? null;

        // If no coordinates provided in request, try to use persisted session coordinates
        // This allows showing distance even when user hasn't clicked "My Location" on this page
        if ($latitude === null && $longitude === null) {
            $geo = $this->geoService->getValidGeoFromSession($request);
            if ($geo) {
                $latitude = $geo['lat'];
                $longitude = $geo['lng'];
            }
        }

        // If radius is omitted -> default 50 km
        // If radius is explicitly 0 -> interpret as "no range"
        $radius = array_key_exists('radius', $validated)
            ? (float) $validated['radius']
            : GeoService::DEFAULT_RADIUS_KM;

        // CRITICAL OPTIMIZATION: Only load 'images', NOT 'foodTypes.menuItems'
        // Map page only needs images for markers/cards; menu data is HEAVY
        // Reduces DB query cost and JSON payload size by ~80%
        // Also restrict image columns to only what's needed
        $query = Restaurant::with(['images:id,restaurant_id,image,is_primary_for_restaurant'])
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
            ->whereNotNull('longitude')
            ->limit(self::MAX_RESTAURANTS_LIMIT); // Defensive limit: protects against huge payloads + Mapbox perf

        // Apply geolocation filtering if coordinates are provided
        if ($latitude !== null && $longitude !== null) {
            // Persist coordinates in session for reuse on other pages (e.g., Restaurant Show)
            // Allows distance calculation to be consistent across the app
            $this->geoService->storeGeoInSession($request, $latitude, $longitude);

            // Use model scope for distance calculation
            // (MariaDB ST_Distance_Sphere or Haversine fallback)
            $query->withDistanceTo($latitude, $longitude);

            if ($radius > 0) {
                // Use model scope for radius filtering
                // (Bounding box + HAVING distance constraint)
                $query->withinRadiusKm($latitude, $longitude, $radius);
            }

            // Use model scope for ordering
            $query->orderByDistance();
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
                'distance' => $this->geoService->formatDistance($restaurant->distance),
                'images' => $restaurant->images->map(fn ($img) => [
                    'id' => $img->id,
                    'url' => $img->image,
                    'is_primary_for_restaurant' => $img->is_primary_for_restaurant,
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
