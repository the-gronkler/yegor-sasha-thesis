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
     * @param  \Illuminate\Support\Collection  $selectedIds  IDs from Phase 1 (closest restaurants)
     * @param  float  $centerLat  Center latitude for distance/score calculation
     * @param  float  $centerLng  Center longitude for distance/score calculation
     * @return array Ordered array of restaurant IDs (score-sorted)
     */
    private function scoreAndOrderRestaurantIds(\Illuminate\Support\Collection $selectedIds, float $centerLat, float $centerLng): array
    {
        // Build composite score query for selected IDs only
        $results = \DB::table('restaurants')
            ->select('id')
            ->whereIn('id', $selectedIds->toArray())
            ->selectRaw(
                '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) AS distance_km',
                [$centerLng, $centerLat]
            )
            ->selectRaw(
                '(COALESCE(rating, 0) / 5) * 50 AS rating_score'
            )
            ->selectRaw(
                'LEAST(30, LOG10((SELECT COUNT(*) FROM reviews WHERE reviews.restaurant_id = restaurants.id) + 1) * 10) AS review_score'
            )
            ->selectRaw(
                'GREATEST(0, 20 * (1 - (COALESCE((ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000), 999999) / 20))) AS distance_score',
                [$centerLng, $centerLat]
            )
            ->selectRaw(
                '((COALESCE(rating, 0) / 5) * 50 + LEAST(30, LOG10((SELECT COUNT(*) FROM reviews WHERE reviews.restaurant_id = restaurants.id) + 1) * 10) + GREATEST(0, 20 * (1 - (COALESCE((ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000), 999999) / 20)))) AS composite_score',
                [$centerLng, $centerLat]
            )
            ->orderByDesc('composite_score')
            ->orderBy('distance_km', 'asc')
            ->get();

        return $results->pluck('id')->toArray();
    }

    /**
     * Phase 3: Fetch full restaurant models with relations, preserving order.
     *
     * This is the final step that loads complete restaurant data with relations.
     * Uses FIELD(id, ...) to preserve the score-sorted order from Phase 2.
     *
     * What this phase does:
     *   - Fetches full Restaurant models for ordered IDs
     *   - Loads 'images' relation (excludes heavy foodTypes.menuItems)
     *   - Adds reviews_count via withCount()
     *   - Calculates distance and composite_score (for response transparency)
     *   - Detects favorite status via LEFT JOIN (if user authenticated)
     *   - Preserves Phase 2 ordering using FIELD() in ORDER BY
     *   - Maps to response format
     *
     * FIELD() ordering explanation:
     *   FIELD(id, 5, 12, 3, 8) returns 1 for id=5, 2 for id=12, etc.
     *   This ensures results maintain the exact order from Phase 2.
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

        // Build FIELD() expression for order preservation
        $fieldOrder = 'FIELD(restaurants.id, '.implode(',', $orderedIds).')';

        $query = Restaurant::with(['images:id,restaurant_id,image,is_primary_for_restaurant'])
            ->withCount('reviews')
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
            ->whereIn('restaurants.id', $orderedIds);

        // Add distance calculation
        $query->selectRaw(
            '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) AS distance',
            [$centerLng, $centerLat]
        );

        // Add composite score (for transparency in response)
        $query->selectRaw(
            '((COALESCE(restaurants.rating, 0) / 5) * 50 + LEAST(30, LOG10((SELECT COUNT(*) FROM reviews WHERE reviews.restaurant_id = restaurants.id) + 1) * 10) + GREATEST(0, 20 * (1 - (COALESCE((ST_Distance_Sphere(POINT(restaurants.longitude, restaurants.latitude), POINT(?, ?)) / 1000), 999999) / 20)))) AS composite_score',
            [$centerLng, $centerLat]
        );

        // Add favorite detection if user is authenticated
        if ($customerId) {
            $query->leftJoin('favorite_restaurants', function ($join) use ($customerId) {
                $join->on('restaurants.id', '=', 'favorite_restaurants.restaurant_id')
                    ->where('favorite_restaurants.customer_user_id', '=', $customerId);
            })
                ->addSelect(\DB::raw('CASE WHEN favorite_restaurants.restaurant_id IS NOT NULL THEN 1 ELSE 0 END as is_favorited'));
        }

        // Preserve order using FIELD()
        $query->orderByRaw($fieldOrder);

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
