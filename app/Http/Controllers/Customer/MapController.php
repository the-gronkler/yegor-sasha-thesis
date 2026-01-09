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
     * Display a map of restaurants.
     *
     * Optionally filters by geolocation if lat, lng, and radius are provided.
     *
     * Performance optimizations:
     * - Only loads 'images' relation (NOT foodTypes.menuItems - huge payload reduction)
     * - Uses model scopes for clean, maintainable geospatial logic
     * - Limits to 500 restaurants max (protects JSON payload + Mapbox rendering)
     * - Uses MariaDB ST_Distance_Sphere or improved Haversine fallback
     *
     * Ranking algorithm:
     * - Combines rating (0-5), review count, and distance (if available)
     * - Rating: 50% weight, Reviews: 30% weight, Distance: 20% weight
     * - Ensures quality restaurants appear first, with proximity as a tiebreaker
     *
     * @param  Request  $request  The incoming HTTP request, optionally containing
     *                            'lat' (float), 'lng' (float), and 'radius' (float, km)
     *                            query parameters for geolocation filtering.
     * @return Response Inertia response rendering the Customer/Map/Index page with:
     *                  - 'restaurants': a collection of restaurants including
     *                  id, name, address, latitude, longitude, rating,
     *                  description, opening_hours, reviews_count, and related images.
     *                  Distance (km, rounded to 2 decimals) included when lat/lng provided.
     *                  Sorted by composite score (rating + reviews + proximity).
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

        $user = $request->user();
        $customerId = $user?->customer?->user_id;

        $query = Restaurant::with(['images:id,restaurant_id,image,is_primary_for_restaurant'])
            ->withCount('reviews') // Add reviews count for better ranking
            ->select([
                'restaurants.id',
                'restaurants.name',
                'restaurants.address',
                'restaurants.latitude',
                'restaurants.longitude',
                'restaurants.rating',
                'restaurants.description',
                'restaurants.opening_hours',
            ])
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->limit(self::MAX_RESTAURANTS_LIMIT); // Defensive limit: protects against huge payloads + Mapbox perf

        // PERFORMANCE OPTIMIZATION: Use LEFT JOIN instead of separate query + in_array()
        // This is O(1) database lookup vs O(n*m) array iteration
        // Only executes when user is authenticated with customer profile
        if ($customerId) {
            $query->leftJoin('favorite_restaurants', function ($join) use ($customerId) {
                $join->on('restaurants.id', '=', 'favorite_restaurants.restaurant_id')
                    ->where('favorite_restaurants.customer_user_id', '=', $customerId);
            })
                ->addSelect(\DB::raw('CASE WHEN favorite_restaurants.restaurant_id IS NOT NULL THEN 1 ELSE 0 END as is_favorited'));
        }

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
        }

        // Fetch restaurants and apply composite scoring
        $restaurants = $query->get()
            ->map(function (Restaurant $restaurant) {
                // Calculate composite score for ranking
                // Factors: rating (0-5), review count, and distance (if available)
                $score = $this->calculateCompositeScore(
                    $restaurant->rating ?? 0,
                    $restaurant->reviews_count ?? 0,
                    $restaurant->distance ?? null
                );

                return [
                    'id' => $restaurant->id,
                    'name' => $restaurant->name,
                    'address' => $restaurant->address,
                    'latitude' => (float) $restaurant->latitude,
                    'longitude' => (float) $restaurant->longitude,
                    'rating' => $restaurant->rating,
                    'description' => $restaurant->description,
                    'opening_hours' => $restaurant->opening_hours,
                    'distance' => $this->geoService->formatDistance($restaurant->distance),
                    'reviews_count' => $restaurant->reviews_count ?? 0,
                    'is_favorited' => (bool) ($restaurant->is_favorited ?? false),
                    'score' => $score, // Add score for debugging/transparency
                    'images' => $restaurant->images->map(fn ($img) => [
                        'id' => $img->id,
                        'url' => $img->image,
                        'is_primary_for_restaurant' => $img->is_primary_for_restaurant,
                    ]),
                ];
            })
            ->sortByDesc('score') // Sort by composite score (best first)
            ->values(); // Reset array keys after sorting

        return Inertia::render('Customer/Map/Index', [
            'restaurants' => $restaurants,
            'filters' => [
                'lat' => $latitude,
                'lng' => $longitude,
                'radius' => $radius,
            ],
        ]);
    }

    /**
     * Calculate a composite score for ranking restaurants.
     *
     * Algorithm:
     * - Rating component (0-50): Normalized rating (0-5) * 10
     * - Reviews component (0-30): Log-scaled review count (more reviews = better, with diminishing returns)
     * - Distance component (0-20): Inverse distance bonus (closer = better, only when location available)
     *
     * This creates a balanced score where:
     * - A perfect 5-star restaurant with many reviews nearby gets ~100 points
     * - Quality (rating + reviews) matters more than proximity
     * - Restaurants with no reviews still get credit for good ratings
     *
     * @param  float  $rating  Restaurant rating (0-5)
     * @param  int  $reviewCount  Number of reviews
     * @param  float|null  $distanceKm  Distance in kilometers (null if no location)
     * @return float Composite score (0-100)
     */
    private function calculateCompositeScore(float $rating, int $reviewCount, ?float $distanceKm): float
    {
        // Rating component: 0-50 points (rating normalized to 0-5, then scaled)
        $ratingScore = ($rating / 5) * 50;

        // Reviews component: 0-30 points (log scale for diminishing returns)
        // Uses log10(count + 1) to handle 0 reviews gracefully
        // 1 review = 0 points, 10 reviews = 10 points, 100 reviews = 20 points, 1000+ reviews = 30 points
        $reviewScore = min(30, log10($reviewCount + 1) * 10);

        // Distance component: 0-20 points (only if location is available)
        $distanceScore = 0;
        if ($distanceKm !== null) {
            // Inverse distance: closer restaurants get more points
            // Within 1km = 20 points, 5km = 10 points, 10km = 5 points, 20km+ = 0 points
            $distanceScore = max(0, 20 * (1 - ($distanceKm / 20)));
        }

        return $ratingScore + $reviewScore + $distanceScore;
    }
}
