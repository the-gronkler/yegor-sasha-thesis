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
     * Display a map of restaurants with deterministic proximity-first selection and quality-based sorting.
     *
     * Four-phase approach ensuring consistent behavior across all entry points:
     *
     * Phase A: Normalize center coordinates (ONE center for all cases)
     *   Priority: search_lat/search_lng > lat/lng > session > default (Warsaw)
     *   - search_lat/search_lng: Map click or "search in this area" button
     *   - lat/lng: User's "My Location" button (persisted to session)
     *   - session: Previous user location (24-hour expiry)
     *   - default: Warsaw (52.2297, 21.0122) if no location available
     *
     * Phase B: Select NEAREST restaurants (proximity-first, no quality bias)
     *   - Calculates distance to center using ST_Distance_Sphere
     *   - Applies bounding box + exact radius filter (if radius > 0)
     *   - Orders by distance ASC ONLY
     *   - Limits to 250 restaurants (protects payload size)
     *   - This ensures we get the CLOSEST restaurants, not the BEST
     *   - HARD RADIUS LIMIT: If radius = 5km, NO restaurant beyond 5km can be selected
     *     (the 250 limit is applied AFTER the radius filter)
     *
     * Phase C: Score-sort the selected restaurants (quality-based ordering)
     *   - For the selected closest restaurants (≤250, all within radius), calculate composite_score
     *   - Orders by composite_score DESC, distance ASC (tiebreaker)
     *   - Returns ordered IDs for next phase
     *
     * Phase D: Fetch full models with relations (preserves order)
     *   - Uses FIELD(id, ...) to maintain phase C ordering
     *   - Loads images relation and favorite status
     *   - Maps to final response format
     *
     * Composite score formula (applied in phases C & D):
     *   - Rating component: (rating / 5) * 50 = 0-50 points
     *   - Reviews component: LEAST(30, LOG10(count + 1) * 10) = 0-30 points
     *   - Distance component: GREATEST(0, 20 * (1 - (distance / 20))) = 0-20 points
     *   - Total range: 0-100 points
     *
     * Key guarantees:
     *   - Switching between lat/lng and search_lat/search_lng produces identical behavior
     *     (only the center point changes, selection/sorting logic is the same)
     *   - When radius > 0: returned set contains ONLY restaurants within that radius
     *     (hard limit enforced via SQL HAVING clause in Phase B)
     *   - When radius = 0: returns up to 250 nearest restaurants globally (no range limit)
     *   - Within the selected set, ordering is by quality (score DESC) with proximity tiebreaker
     *   - All ordering happens in the database; no post-processing in PHP changes the order
     *
     * @param  Request  $request  Query parameters: lat, lng, search_lat, search_lng, radius
     * @return Response Inertia response with restaurants array (sorted by score DESC, distance ASC)
     *                  and filters object (lat, lng, radius)
     */
    public function index(Request $request): Response
    {
        $this->authorize('viewAny', Restaurant::class);

        // Validate optional geolocation parameters
        // Note: Both lat/lng and search_lat/search_lng can be provided simultaneously.
        // search_lat/search_lng takes priority for center calculation (map click/search in area).
        // lat/lng is preserved for user location context and session persistence.
        $validated = $request->validate([
            'lat' => 'nullable|numeric|between:-90,90',
            'lng' => 'nullable|numeric|between:-180,180',
            'search_lat' => 'nullable|numeric|between:-90,90',
            'search_lng' => 'nullable|numeric|between:-180,180',
            'radius' => 'nullable|numeric|min:0|max:'.GeoService::MAX_RADIUS_KM,
        ]);

        // PHASE A: Normalize inputs - determine ONE search center
        // Priority: search_lat/search_lng > lat/lng > session > default (Warsaw)
        $centerCoords = $this->normalizeCenterCoordinates($request, $validated);
        $centerLat = $centerCoords['lat'];
        $centerLng = $centerCoords['lng'];

        // Parse radius (default 50km if omitted, 0 means "no range")
        $radius = array_key_exists('radius', $validated)
            ? (float) $validated['radius']
            : GeoService::DEFAULT_RADIUS_KM;

        $user = $request->user();
        $customerId = $user?->customer?->user_id;

        // PHASE B: Select nearest restaurants (distance-first, up to MAX_RESTAURANTS_LIMIT)
        $selectedIds = $this->selectNearestRestaurantIds($centerLat, $centerLng, $radius);

        if ($selectedIds->isEmpty()) {
            // No restaurants found - return empty result
            return Inertia::render('Customer/Map/Index', [
                'restaurants' => [],
                'filters' => [
                    'lat' => $validated['lat'] ?? null,
                    'lng' => $validated['lng'] ?? null,
                    'radius' => $radius,
                ],
            ]);
        }

        // PHASE C: Score-sort and fetch full models
        $orderedIds = $this->scoreAndOrderRestaurantIds($selectedIds, $centerLat, $centerLng);

        // PHASE D: Fetch full restaurant models with relations, preserving order
        $restaurants = $this->fetchRestaurantsWithRelations($orderedIds, $customerId, $centerLat, $centerLng);

        return Inertia::render('Customer/Map/Index', [
            'restaurants' => $restaurants,
            'filters' => [
                'lat' => $validated['lat'] ?? null,
                'lng' => $validated['lng'] ?? null,
                'radius' => $radius,
            ],
        ]);
    }

    /**
     * Normalize center coordinates from request inputs.
     *
     * Priority order:
     * 1. search_lat/search_lng (map click/search in area)
     * 2. lat/lng (user location button)
     * 3. Session geo.last (persisted from previous request)
     * 4. Default center (Warsaw: 52.2297, 21.0122)
     *
     * Only persist to session if real user location (lat/lng) is provided.
     *
     * @param  array  $validated  Validated request parameters
     * @return array{lat: float, lng: float}
     */
    private function normalizeCenterCoordinates(Request $request, array $validated): array
    {
        // Priority 1: search_lat/search_lng (map click, "search in this area")
        if (isset($validated['search_lat'], $validated['search_lng'])) {
            return [
                'lat' => (float) $validated['search_lat'],
                'lng' => (float) $validated['search_lng'],
            ];
        }

        // Priority 2: lat/lng (user clicked "My Location")
        if (isset($validated['lat'], $validated['lng'])) {
            $lat = (float) $validated['lat'];
            $lng = (float) $validated['lng'];

            // Persist user's actual location in session (not search coordinates)
            $this->geoService->storeGeoInSession($request, $lat, $lng);

            return ['lat' => $lat, 'lng' => $lng];
        }

        // Priority 3: Session geo.last (from previous user location)
        $sessionGeo = $this->geoService->getValidGeoFromSession($request);
        if ($sessionGeo) {
            return $sessionGeo;
        }

        // Priority 4: Default center (Warsaw)
        return [
            'lat' => 52.2297,
            'lng' => 21.0122,
        ];
    }

    /**
     * Phase 1: Select nearest restaurant IDs (distance-first selection).
     *
     * Query strategy:
     * - Calculate distance using ST_Distance_Sphere
     * - Apply bounding box prefilter if radius > 0 (performance optimization)
     * - Apply exact radius filter if radius > 0 (HARD LIMIT via HAVING clause)
     * - Order by distance ASC only
     * - Limit to MAX_RESTAURANTS_LIMIT (only applied AFTER radius filter)
     * - Return only IDs (lightweight)
     *
     * IMPORTANT GUARANTEE:
     * When radius > 0 (e.g., 5km), the HAVING clause ensures that NO restaurant
     * beyond that distance can be selected. The limit of 250 is applied AFTER
     * the radius filter, so you get "up to 250 restaurants within 5km", never
     * "250 restaurants regardless of distance".
     *
     * @param  float  $centerLat  Center latitude for distance calculation
     * @param  float  $centerLng  Center longitude for distance calculation
     * @param  float  $radius  Radius in km (0 = no limit, returns 250 nearest globally)
     * @return \Illuminate\Support\Collection Collection of restaurant IDs (all within radius if radius > 0)
     */
    private function selectNearestRestaurantIds(float $centerLat, float $centerLng, float $radius): \Illuminate\Support\Collection
    {
        $query = \DB::table('restaurants')
            ->select('id')
            ->whereNotNull('latitude')
            ->whereNotNull('longitude');

        // Calculate distance
        $query->selectRaw(
            '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) AS distance_km',
            [$centerLng, $centerLat]
        );

        // Apply radius filtering if specified
        if ($radius > 0) {
            // Bounding box prefilter (performance optimization)
            $bounds = $this->geoService->getBoundingBox($centerLat, $centerLng, $radius);
            $query->whereBetween('latitude', [$bounds['latMin'], $bounds['latMax']])
                ->whereBetween('longitude', [$bounds['lngMin'], $bounds['lngMax']]);

            // Exact radius filter
            $query->havingRaw('distance_km <= ?', [$radius]);
        }

        // Order by distance only (proximity-first selection)
        $query->orderBy('distance_km', 'asc')
            ->limit(self::MAX_RESTAURANTS_LIMIT);

        return $query->pluck('id');
    }

    /**
     * Phase 2: Calculate composite scores and return ordered IDs.
     *
     * IMPORTANT: This operates ONLY on the already-selected nearest restaurant IDs from Phase 1.
     * It does NOT re-select or filter restaurants - it only re-orders the closest ones.
     *
     * Performance optimizations:
     *   1. Distance calculated once via nested subquery (eliminates redundant ST_Distance_Sphere calls)
     *   2. Review counts pre-aggregated via leftJoinSub with GROUP BY (eliminates correlated subqueries)
     *   3. All scoring logic computed in a single pass
     *
     * Composite score calculation:
     *   - rating_score: (COALESCE(rating, 0) / 5) * 50 = 0-50 points
     *   - review_score: LEAST(30, LOG10(review_count + 1) * 10) = 0-30 points
     *   - distance_score: GREATEST(0, 20 * (1 - (distance_km / 20))) = 0-20 points
     *   - composite_score: rating_score + review_score + distance_score = 0-100 points
     *
     * Sorting order:
     *   - PRIMARY: composite_score DESC (best quality first)
     *   - SECONDARY: distance_km ASC (closer restaurants win ties)
     *
     * Index requirement:
     *   - reviews.restaurant_id must be indexed for efficient GROUP BY aggregation
     *     (See migration: add_index_to_reviews_restaurant_id.php)
     *
     * @param  \Illuminate\Support\Collection  $selectedIds  IDs from Phase 1 (closest restaurants)
     * @param  float  $centerLat  Center latitude for distance/score calculation
     * @param  float  $centerLng  Center longitude for distance/score calculation
     * @return array Ordered array of restaurant IDs (score-sorted)
     */
    private function scoreAndOrderRestaurantIds(\Illuminate\Support\Collection $selectedIds, float $centerLat, float $centerLng): array
    {
        // Step 1: Build subquery for restaurants with distance (computed once per row)
        $restaurantsWithDistance = \DB::table('restaurants')
            ->select([
                'id',
                'latitude',
                'longitude',
                'rating',
            ])
            ->selectRaw(
                '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) AS distance_km',
                [$centerLng, $centerLat]
            )
            ->whereIn('id', $selectedIds->toArray());

        // Step 2: Build subquery for review counts (aggregated once, limited to selected IDs only)
        // Index on reviews.restaurant_id is critical here for GROUP BY performance
        $reviewCounts = \DB::table('reviews')
            ->select('restaurant_id')
            ->selectRaw('COUNT(*) as review_count')
            ->whereIn('restaurant_id', $selectedIds->toArray())
            ->groupBy('restaurant_id');

        // Step 3: Join distance subquery with review counts, calculate composite score
        $results = \DB::query()
            ->fromSub($restaurantsWithDistance, 'r')
            ->leftJoinSub($reviewCounts, 'rc', 'r.id', '=', 'rc.restaurant_id')
            ->select([
                'r.id',
                'r.distance_km',
            ])
            ->selectRaw('(COALESCE(r.rating, 0) / 5) * 50 AS rating_score')
            ->selectRaw('LEAST(30, LOG10(COALESCE(rc.review_count, 0) + 1) * 10) AS review_score')
            ->selectRaw('GREATEST(0, 20 * (1 - (r.distance_km / 20))) AS distance_score')
            ->selectRaw(
                '((COALESCE(r.rating, 0) / 5) * 50 + '.
                'LEAST(30, LOG10(COALESCE(rc.review_count, 0) + 1) * 10) + '.
                'GREATEST(0, 20 * (1 - (r.distance_km / 20)))) AS composite_score'
            )
            ->orderByDesc('composite_score')
            ->orderBy('r.distance_km', 'asc')
            ->get();

        return $results->pluck('id')->toArray();
    }

    /**
     * Phase 3: Fetch full restaurant models with relations, preserving order.
     *
     * This is the final step that loads complete restaurant data with relations.
     * Uses FIELD(id, ...) to preserve the score-sorted order from Phase 2.
     *
     * Performance optimizations:
     *   1. Distance calculated once via derived table (eliminates redundant ST_Distance_Sphere calls)
     *   2. Review counts pre-aggregated via grouped subquery (eliminates correlated SELECT COUNT(*))
     *   3. Composite score computed once in SQL using pre-calculated distance and review_count
     *   4. Scored data joined back to restaurants table for Eloquent model hydration
     *
     * What this phase does:
     *   - Builds derived table with distance_km and composite_score (computed once per restaurant)
     *   - Joins scored data to restaurants table using joinSub()
     *   - Eloquent still hydrates Restaurant models normally
     *   - Eager-loads 'images' relation via with()
     *   - Detects favorite status via LEFT JOIN (if user authenticated)
     *   - Preserves Phase 2 ordering using FIELD() in ORDER BY
     *   - Maps to response format
     *
     * FIELD() ordering explanation:
     *   FIELD(id, 5, 12, 3, 8) returns 1 for id=5, 2 for id=12, etc.
     *   This ensures results maintain the exact order from Phase 2.
     *
     * Index requirements:
     *   - reviews.restaurant_id (for GROUP BY performance in review counts subquery)
     *   - favorite_restaurants(customer_user_id, restaurant_id) composite index recommended
     *     (for fast favorite lookups filtered by customer_user_id)
     *
     * @param  array  $orderedIds  Restaurant IDs in desired order (from Phase 2)
     * @param  int|null  $customerId  Customer ID for favorite detection (null if not authenticated)
     * @param  float  $centerLat  Center latitude for distance calculation
     * @param  float  $centerLng  Center longitude for distance calculation
     * @return \Illuminate\Support\Collection Collection of formatted restaurant arrays
     */
    private function fetchRestaurantsWithRelations(array $orderedIds, ?int $customerId, float $centerLat, float $centerLng): \Illuminate\Support\Collection
    {
        if (empty($orderedIds)) {
            return collect([]);
        }

        // Step 1: Build subquery for review counts (aggregated once, limited to orderedIds only)
        // Index on reviews.restaurant_id is critical here for GROUP BY performance
        $reviewCounts = \DB::table('reviews')
            ->select('restaurant_id')
            ->selectRaw('COUNT(*) as review_count')
            ->whereIn('restaurant_id', $orderedIds)
            ->groupBy('restaurant_id');

        // Step 2a: Build inner subquery for restaurants with distance (computed ONCE per row)
        $restaurantsWithDistance = \DB::table('restaurants')
            ->select([
                'id',
                'latitude',
                'longitude',
                'rating',
            ])
            ->selectRaw(
                '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) AS distance_km',
                [$centerLng, $centerLat]
            )
            ->whereIn('id', $orderedIds);

        // Step 2b: Build outer derived table that joins distance with review counts and computes composite score
        // This reuses the pre-calculated distance_km instead of recalculating ST_Distance_Sphere
        $scoredRestaurants = \DB::query()
            ->fromSub($restaurantsWithDistance, 'rwd')
            ->leftJoinSub($reviewCounts, 'rc', 'rwd.id', '=', 'rc.restaurant_id')
            ->select([
                'rwd.id',
                'rwd.distance_km',
            ])
            ->selectRaw('COALESCE(rc.review_count, 0) as review_count')
            ->selectRaw('(COALESCE(rwd.rating, 0) / 5) * 50 AS rating_score')
            ->selectRaw('LEAST(30, LOG10(COALESCE(rc.review_count, 0) + 1) * 10) AS review_score')
            ->selectRaw('GREATEST(0, 20 * (1 - (rwd.distance_km / 20))) AS distance_score')
            ->selectRaw(
                '((COALESCE(rwd.rating, 0) / 5) * 50 + '.
                'LEAST(30, LOG10(COALESCE(rc.review_count, 0) + 1) * 10) + '.
                'GREATEST(0, 20 * (1 - (rwd.distance_km / 20)))) AS composite_score'
            );

        // Build FIELD() expression for order preservation
        // Sanitize IDs to integers for security and reindex array
        $orderedIds = array_values(array_map('intval', $orderedIds));
        $placeholders = implode(',', array_fill(0, count($orderedIds), '?'));
        $fieldSql = "FIELD(restaurants.id, {$placeholders})";

        // Step 3: Join scored data to restaurants table for Eloquent model hydration
        // This allows with(['images']) to work normally while using pre-computed scores
        $query = Restaurant::query()
            ->joinSub($scoredRestaurants, 'scored', 'restaurants.id', '=', 'scored.id')
            ->with(['images:id,restaurant_id,image,is_primary_for_restaurant'])
            ->select([
                'restaurants.id',
                'restaurants.name',
                'restaurants.address',
                'restaurants.latitude',
                'restaurants.longitude',
                'restaurants.rating',
                'restaurants.description',
                'restaurants.opening_hours',
                'scored.distance_km as distance',
                'scored.review_count as reviews_count',
                'scored.composite_score',
            ]);

        // Add favorite detection if user is authenticated
        // Composite index on (customer_user_id, restaurant_id) recommended for performance
        if ($customerId) {
            $query->leftJoin('favorite_restaurants', function ($join) use ($customerId) {
                $join->on('restaurants.id', '=', 'favorite_restaurants.restaurant_id')
                    ->where('favorite_restaurants.customer_user_id', '=', $customerId);
            })
                ->addSelect(\DB::raw('CASE WHEN favorite_restaurants.restaurant_id IS NOT NULL THEN 1 ELSE 0 END as is_favorited'));
        }

        // Preserve order using FIELD()
        $query->orderByRaw($fieldSql, $orderedIds);

        $restaurants = $query->get();

        // Map to response format
        return $restaurants->map(function (Restaurant $restaurant) {
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
                'score' => round($restaurant->composite_score ?? 0, 2),
                'images' => $restaurant->images->map(fn ($img) => [
                    'id' => $img->id,
                    'url' => $img->image,
                    'is_primary_for_restaurant' => $img->is_primary_for_restaurant,
                ]),
            ];
        });
    }
}
