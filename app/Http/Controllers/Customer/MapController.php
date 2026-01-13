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
    private const MAX_RESTAURANTS_LIMIT = 500;

    protected GeoService $geoService;

    public function __construct(GeoService $geoService)
    {
        $this->geoService = $geoService;
    }

    /**
     * Map of restaurants.
     *
     * ARCHITECTURE CHANGE (Scalable approach):
     * - Restaurants are loaded from Mapbox Vector Tiles (NOT Inertia props)
     * - Tiles are generated from exported GeoJSON via Mapbox Tiling Service
     * - Frontend fetches restaurant details on-demand via API when user clicks a point
     *
     * This approach:
     * - Eliminates large JSON payloads (works smoothly with 10k+ restaurants)
     * - Uses Mapbox's built-in clustering at tile level
     * - Loads only visible restaurants based on viewport
     * - Provides instant map rendering with progressive detail loading
     *
     * @param  Request  $request  The incoming HTTP request, optionally containing
     *                            'lat' (float), 'lng' (float) for user geolocation.
     * @return Response Inertia response rendering the Customer/Map/Index page with:
     *                  - 'mapboxToken': Mapbox public API key
     *                  - 'tilesetId': Mapbox tileset ID for restaurant points
     *                  - 'initialViewport': map center and zoom level
     *                  - 'userGeo': user's latitude/longitude from session (if available)
     */
    public function index(Request $request): Response
    {
        $this->authorize('viewAny', Restaurant::class);

        // Validate optional geolocation parameters
        $validated = $request->validate([
            'lat' => 'nullable|numeric|between:-90,90',
            'lng' => 'nullable|numeric|between:-180,180',
        ]);

        $latitude = $validated['lat'] ?? null;
        $longitude = $validated['lng'] ?? null;

        // If no coordinates provided in request, try to use persisted session coordinates
        if ($latitude === null && $longitude === null) {
            $geo = $this->geoService->getValidGeoFromSession($request);
            if ($geo) {
                $latitude = $geo['lat'];
                $longitude = $geo['lng'];
            }
        }

        // Persist coordinates in session if provided
        if ($latitude !== null && $longitude !== null) {
            $this->geoService->storeGeoInSession($request, $latitude, $longitude);
        }

        // Default viewport (Warsaw, Poland - centered on the city)
        $defaultViewport = [
            'longitude' => 20.9449511,
            'latitude' => 52.3331203,
            'zoom' => 6, // Zoomed out to show Poland region
        ];

        // If user has location, center on them
        if ($latitude !== null && $longitude !== null) {
            $defaultViewport['latitude'] = $latitude;
            $defaultViewport['longitude'] = $longitude;
            $defaultViewport['zoom'] = 10; // Closer zoom when user location is known
        }

        return Inertia::render('Customer/Map/Index', [
            'mapboxToken' => config('services.mapbox.public_key'),
            'tilesetId' => config('services.mapbox.restaurants_tileset'),
            'initialViewport' => $defaultViewport,
            'userGeo' => $latitude !== null && $longitude !== null
                ? ['lat' => $latitude, 'lng' => $longitude]
                : null,
        ]);
    }
}
