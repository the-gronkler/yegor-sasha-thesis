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
     * - Limits to 500 restaurants max (protects JSON payload + Mapbox rendering)
     * - Uses MariaDB ST_Distance_Sphere or improved Haversine fallback
     * - Calculates composite score at database level for efficient sorting
     *
     * Ranking algorithm (calculated in database):
     * - Combines rating (0-5), review count, and distance (if available)
     * - Rating: 50% weight (0-50 points), Reviews: 30% weight (0-30 points), Distance: 20% weight (0-20 points)
     * - Ensures quality restaurants appear first, with proximity as a tiebreaker
     * - Total score range: 0-100 points
     *
     * @param  Request  $request  The incoming HTTP request, optionally containing
     *                            'lat' (float), 'lng' (float), and 'radius' (float, km)
     *                            query parameters for geolocation filtering.
     * @return Response Inertia response rendering the Customer/Map/Index page with:
     *                  - 'restaurants': a collection of restaurants including
     *                  id, name, address, latitude, longitude, rating,
     *                  description, opening_hours, reviews_count, is_favorited, score,
     *                  distance (formatted string, included when lat/lng provided), and related images.
     *                  Sorted by composite score descending (best restaurants first).
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
            'search_lat' => 'nullable|numeric|between:-90,90', // For "search in area" without setting user location
            'search_lng' => 'nullable|numeric|between:-180,180',
            'radius' => 'nullable|numeric|min:0|max:'.GeoService::MAX_RADIUS_KM, // allow 0 == "no range"
        ]);

        $latitude = $validated['lat'] ?? null;
        $longitude = $validated['lng'] ?? null;

        // Check if this is a "search in area" request (uses search_lat/search_lng)
        $searchLatitude = $validated['search_lat'] ?? null;
        $searchLongitude = $validated['search_lng'] ?? null;

        // Use search coordinates for distance calculation if provided
        $distanceCalcLat = $searchLatitude ?? $latitude;
        $distanceCalcLng = $searchLongitude ?? $longitude;

        // If no coordinates provided in request, try to use persisted session coordinates
        // This allows showing distance even when user hasn't clicked "My Location" on this page
        if ($distanceCalcLat === null && $distanceCalcLng === null) {
            $geo = $this->geoService->getValidGeoFromSession($request);
            if ($geo) {
                $distanceCalcLat = $geo['lat'];
                $distanceCalcLng = $geo['lng'];
            }
        }

        // Only persist user's actual location in session (not search coordinates)
        if ($latitude !== null && $longitude !== null) {
            $this->geoService->storeGeoInSession($request, $latitude, $longitude);
        }

        // If radius is omitted -> default 50 km
        // If radius is explicitly 0 -> interpret as "no range"
        $radius = array_key_exists('radius', $validated)
            ? (float) $validated['radius']
            : GeoService::DEFAULT_RADIUS_KM;

        $isSearchInArea = $searchLatitude !== null && $searchLongitude !== null;
        $actualRadius = $radius;
        $expandedRadius = false;

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
        $hasLocation = false;
        if ($distanceCalcLat !== null && $distanceCalcLng !== null) {
            // Use model scope for distance calculation
            // (MariaDB ST_Distance_Sphere or Haversine fallback)
            $query->withDistanceTo($distanceCalcLat, $distanceCalcLng);

            // Adaptive radius for "search in area" when zoomed in very close
            // For small radii, automatically expand to ensure we get enough results
            if ($isSearchInArea && $radius > 0 && $radius < 5) {
                // Calculate expanded radius: multiply by factor based on how small it is
                // 0.2km → 16x → 3.2km, 1km → 5x → 5km, 2km → 3x → 6km, 5km → no expansion
                $expansionFactor = min(16, ceil(5 / $radius));
                $actualRadius = min($radius * $expansionFactor, GeoService::MAX_RADIUS_KM);
                $expandedRadius = ($actualRadius > $radius);
            } elseif ($radius > 0) {
                // Normal radius filtering
                $actualRadius = $radius;
            } else {
                $actualRadius = 0;
            }

            // PERFORMANCE OPTIMIZATION: Apply bounding box prefilter to reduce search space
            // This uses indexed lat/lng columns to eliminate most restaurants before distance calculation
            // Critical for performance with large datasets (e.g., 10k+ restaurants)
            if ($actualRadius > 0) {
                // Get bounding box for the search area
                $bounds = $this->geoService->getBoundingBox($distanceCalcLat, $distanceCalcLng, $actualRadius);

                // Apply bounding box prefilter (uses indexes on latitude/longitude)
                $query->whereBetween('latitude', [$bounds['latMin'], $bounds['latMax']])
                    ->whereBetween('longitude', [$bounds['lngMin'], $bounds['lngMax']]);

                // Add is_in_radius column for original requested radius
                // This allows us to show restaurants outside the original radius but within expanded search
                // Must repeat the distance calculation because SQL doesn't allow referencing column aliases
                // in the same SELECT clause where they're defined
                // Use parameter binding to prevent SQL injection
                $query->selectRaw(
                    '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) <= ? as is_in_radius',
                    [$distanceCalcLng, $distanceCalcLat, $radius]
                );
            } else {
                // No radius limit - all restaurants are considered "in radius"
                $query->addSelect(\DB::raw('1 as is_in_radius'));
            }

            $hasLocation = true;
        }

        // PERFORMANCE OPTIMIZATION: Calculate composite score in database instead of PHP
        // This allows MySQL/MariaDB to handle sorting using indexes before loading into memory
        // Significantly more efficient than loading 500 restaurants then sorting in PHP
        $this->addCompositeScoreToQuery($query, $hasLocation, $distanceCalcLat, $distanceCalcLng);

        // Sort by: is_in_radius DESC (inside first), then distance ASC (closer first), then composite_score DESC (better first)
        // This ensures restaurants within radius appear first, sorted by distance, then quality
        if ($hasLocation) {
            $query->orderByRaw('is_in_radius DESC, distance ASC, composite_score DESC');
        } else {
            $query->orderByRaw('composite_score DESC');
        }

        // Fetch restaurants (already sorted by database)
        $restaurants = $query->get()
            ->map(function (Restaurant $restaurant) {
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
                    'is_in_radius' => (bool) ($restaurant->is_in_radius ?? true),
                    'score' => round($restaurant->composite_score ?? 0, 2), // Add score for debugging/transparency
                    'images' => $restaurant->images->map(fn ($img) => [
                        'id' => $img->id,
                        'url' => $img->image,
                        'is_primary_for_restaurant' => $img->is_primary_for_restaurant,
                    ]),
                ];
            });

        return Inertia::render('Customer/Map/Index', [
            'restaurants' => $restaurants,
            'filters' => [
                'lat' => $latitude,
                'lng' => $longitude,
                'radius' => $actualRadius, // Return the actual radius used (may be expanded)
                'requested_radius' => $radius, // Original requested radius
                'radius_expanded' => $expandedRadius, // Whether radius was auto-expanded
            ],
        ]);
    }

    /**
     * Add composite score calculation to the query.
     *
     * This method adds a raw SQL expression to calculate the composite score
     * directly in the database, allowing for efficient sorting before loading
     * results into PHP memory.
     *
     * Algorithm (same as calculateCompositeScore but in SQL):
     * - Rating component (0-50): (COALESCE(rating, 0) / 5) * 50
     * - Reviews component (0-30): LEAST(30, LOG10(review_count + 1) * 10)
     * - Distance component (0-20): GREATEST(0, 20 * (1 - (distance_km / 20)))
     *   (only calculated when location is available)
     *
     * The distance calculation is duplicated in the SQL because column aliases
     * cannot be referenced in the same SELECT clause where they're defined.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query  The query builder instance
     * @param  bool  $hasLocation  Whether location data is available for distance scoring
     * @param  float|null  $latitude  User's latitude (required if hasLocation is true)
     * @param  float|null  $longitude  User's longitude (required if hasLocation is true)
     */
    private function addCompositeScoreToQuery($query, bool $hasLocation, ?float $latitude = null, ?float $longitude = null): void
    {
        // Rating score: 0-50 points
        $ratingScore = '(COALESCE(restaurants.rating, 0) / 5) * 50';

        // Review score: 0-30 points (log scale)
        // Using LOG10(count + 1) * 10, capped at 30
        $reviewScore = 'LEAST(30, LOG10(COALESCE((SELECT COUNT(*) FROM reviews WHERE reviews.restaurant_id = restaurants.id), 0) + 1) * 10)';

        // Distance score: 0-20 points (only if location available)
        if ($hasLocation && $latitude !== null && $longitude !== null) {
            // We must duplicate the distance calculation here because SQL doesn't allow
            // referencing column aliases (like 'distance') in the same SELECT clause
            // Use parameter binding to prevent SQL injection
            $distanceCalc = '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000)';

            // Inverse distance: closer = better
            // GREATEST ensures we don't go below 0
            $distanceScore = "GREATEST(0, 20 * (1 - (COALESCE({$distanceCalc}, 999999) / 20)))";

            // Combine all components into composite score with parameter binding
            $query->selectRaw(
                "({$ratingScore} + {$reviewScore} + {$distanceScore}) as composite_score",
                [$longitude, $latitude]
            );
        } else {
            // No distance score - only rating and reviews
            $query->addSelect(\DB::raw("({$ratingScore} + {$reviewScore}) as composite_score"));
        }
    }

    /**
     * Calculate a composite score for ranking restaurants.
     *
     * Algorithm:
     * - Rating component (0-50): (rating / 5) * 50
     * - Reviews component (0-30): Log-scaled review count (more reviews = better, with diminishing returns)
     * - Distance component (0-20): Inverse distance bonus (closer = better, only when location available)
     *
     * This creates a balanced score where:
     * - A perfect 5-star restaurant with many reviews nearby gets ~100 points
     * - Quality (rating + reviews) matters more than proximity
     * - Restaurants with no reviews still get credit for good ratings
     *
     * NOTE: This method is kept for reference but sorting now happens at database level
     * using addCompositeScoreToQuery() for better performance.
     *
     * @param  float  $rating  Restaurant rating (0-5)
     * @param  int  $reviewCount  Number of reviews
     * @param  float|null  $distanceKm  Distance in kilometers (null if no location)
     * @return float Composite score (0-100)
     *
     * @deprecated Use database-level scoring via addCompositeScoreToQuery() instead
     */
    private function calculateCompositeScore(float $rating, int $reviewCount, ?float $distanceKm): float
    {
        // Rating component: 0-50 points (rating normalized to 0-5, then scaled)
        $ratingScore = ($rating / 5) * 50;

        // Reviews component: 0-30 points (log scale for diminishing returns)
        // Uses log10(count + 1) to handle 0 reviews gracefully
        // 0 reviews = 0 points, 1 review ≈ 3 points, 10 reviews = 10 points, 100 reviews = 20 points, 1000+ reviews = 30 points
        $reviewScore = min(30, log10($reviewCount + 1) * 10);

        // Distance component: 0-20 points (only if location is available)
        $distanceScore = 0;
        if ($distanceKm !== null) {
            // Inverse distance: closer restaurants get more points
            // Within 1km ≈ 20 points, 5km = 15 points, 10km = 10 points, 20km+ = 0 points
            $distanceScore = max(0, 20 * (1 - ($distanceKm / 20)));
        }

        return $ratingScore + $reviewScore + $distanceScore;
    }
}
