#import "../../config.typ": source_code_link, code_example

== Map-Based Restaurant Discovery Implementation <map-implementation>

This section presents the implementation of the customer-facing map feature used for restaurant discovery. The map enables spatial browsing, optional radius-based filtering, and deterministic quality-based ordering. The implementation is split between a Laravel backend endpoint that produces a validated, performance-bounded dataset and a React (Inertia) frontend that renders an interactive Mapbox map with overlay controls and a synchronized, draggable restaurant list.

The main implementation artifacts are:
- Backend controller: #source_code_link("app/Http/Controllers/Customer/MapController.php")
- Geospatial helper service: #source_code_link("app/Services/GeoService.php")
- Page entry component: #source_code_link("resources/js/Pages/Customer/Map/Index.tsx")
- Page logic hook: #source_code_link("resources/js/Hooks/useMapPage.ts")
- Mapbox integration component: #source_code_link("resources/js/Components/Shared/Map.tsx")
- Overlay controls: #source_code_link("resources/js/Pages/Customer/Map/Partials/MapOverlay.tsx")
- Draggable restaurant list: #source_code_link("resources/js/Pages/Customer/Map/Partials/BottomSheet.tsx")
- Selected restaurant popup: #source_code_link("resources/js/Components/Shared/MapPopup.tsx")
- Map style layers: #source_code_link("resources/js/Components/Shared/mapStyles.ts")
- Layout wrapper: #source_code_link("resources/js/Layouts/MapLayout.tsx")

=== Requirements translated into implementation constraints

The map feature is a discovery surface, not a full restaurant-detail view. Translating this goal into code-level constraints shaped both the endpoint and the UI behavior.

*Performance bounds:* The backend enforces the 250-restaurant limit described in @map-arch-scalability, protecting database workload, response serialization time, and Mapbox rendering performance.

*Dual location semantics:* The feature distinguishes user location (`lat`/`lng`) from search center (`search_lat`/`search_lng`), implementing the session isolation guarantee described in @map-arch-guarantees. This ensures that exploring another area does not overwrite the user's persisted location.

*Deterministic radius filtering:* If a radius is specified, no restaurants outside that radius may appear in results. This is enforced at the SQL level (not post-filtered in PHP), so the semantic meaning of "within radius" cannot drift.

*Graceful location degradation:* The feature must remain usable when geolocation is denied or unavailable; therefore it provides a safe default center (Warsaw) and manual alternatives (coordinate entry and map click picking).

*Quality-first ordering within proximity bounds:* Users expect high-rated and popular restaurants to appear first, but still inside their selected discovery area. This motivates a two-stage approach: proximity-first selection, then quality-first ranking.

*Synchronized selection across surfaces:* Selecting a restaurant on the map must highlight it in the list (and open a popup), and selecting a restaurant in the list must move the map camera to that point.

These constraints map directly to the controller's deterministic three-phase pipeline and to the frontend's separation of responsibilities between orchestration, state management, and UI components.

=== Backend implementation: deterministic three-phase processing

The dataset for the map is produced by the `index` action in #source_code_link("app/Http/Controllers/Customer/MapController.php"). As described in @map-arch-three-phase, the endpoint implements a deterministic three-phase architecture (input normalization, proximity-first selection, and quality-based ranking). The following sections present the concrete implementation of each phase.

==== Authorization, validation, and response shape

The endpoint authorizes access through Laravel policies and validates all optional query parameters. The validation is explicitly permissive regarding optionality: all parameters may be absent (defaulting to Warsaw + default radius), and `radius` may be `0` (interpreted as “no range limit”).

#code_example[
The controller authorizes the request and validates geospatial inputs before building any database query.

```php
  <?php
// app/Http/Controllers/Customer/MapController.php
public function index(Request $request): Response
{
    $this->authorize('viewAny', Restaurant::class);

    $validated = $request->validate([
        'lat' => 'nullable|numeric|between:-90,90',
        'lng' => 'nullable|numeric|between:-180,180',
        'search_lat' => 'nullable|numeric|between:-90,90',
        'search_lng' => 'nullable|numeric|between:-180,180',
        'radius' => 'nullable|numeric|min:0|max:'.GeoService::MAX_RADIUS_KM,
    ]);

    // ...
}
```
]

Two details are important for correctness:

1. Both `lat/lng` and `search_lat/search_lng` may be present. Search coordinates represent the latest exploration intent and therefore have priority for choosing the query center.

2. The endpoint returns `filters.lat/lng` based only on `lat/lng` (user location), not on the temporary `search_lat/search_lng`. This keeps UI semantics clear: `filters` describes user context, while the “search center” is reflected implicitly by the returned restaurants.

If `radius` is omitted, the controller applies `GeoService::DEFAULT_RADIUS_KM` (50 km). If `radius = 0`, the controller omits the radius constraint and returns the 250 nearest restaurants globally.

==== Phase A: center coordinate normalization (one center for all cases)

The controller normalizes coordinates into a single center point, with the following priority order:

1. `search_lat/search_lng` (map exploration, “Search here”)
2. `lat/lng` (user location, from “My Location” or manual entry)
3. Session value `geo.last` (previous user location, 24-hour expiry)
4. Default Warsaw center `(52.2297, 21.0122)`

A critical decision is that only real user location is persisted. Search center coordinates are deliberately ephemeral.

#code_example[
The normalization method implements the priority cascade and persists only user location (`lat/lng`) to session.

```php
  <?php
// app/Http/Controllers/Customer/MapController.php
private function normalizeCenterCoordinates(Request $request, array $validated): array
{
    if (isset($validated['search_lat'], $validated['search_lng'])) {
        return [
            'lat' => (float) $validated['search_lat'],
            'lng' => (float) $validated['search_lng'],
        ];
    }

    if (isset($validated['lat'], $validated['lng'])) {
        $lat = (float) $validated['lat'];
        $lng = (float) $validated['lng'];

        $this->geoService->storeGeoInSession($request, $lat, $lng);

        return ['lat' => $lat, 'lng' => $lng];
    }

    $sessionGeo = $this->geoService->getValidGeoFromSession($request);
    if ($sessionGeo) {
        return $sessionGeo;
    }

    return ['lat' => 52.2297, 'lng' => 21.0122];
}
```
]

This design allows exploration without losing context: users can browse multiple areas with “Search here” while the app still remembers their actual location for future visits.

==== Session-based geolocation persistence

The session persistence architecture described in @map-arch-session-persistence is implemented by #source_code_link("app/Services/GeoService.php"). The service stores coordinates under `geo.last` with a 24-hour expiry timestamp.

#code_example[
GeoService persists `geo.last` with a timestamp and rejects expired session values.

```php
  <?php
// app/Services/GeoService.php
public function getValidGeoFromSession(Request $request): ?array
{
    $geo = $request->session()->get('geo.last');

    if (! $geo || ! isset($geo['lat'], $geo['lng'])) {
        return null;
    }

    if (isset($geo['stored_at']) && (time() - (int) $geo['stored_at']) > self::SESSION_EXPIRY_SECONDS) {
        return null;
    }

    return [
        'lat' => (float) $geo['lat'],
        'lng' => (float) $geo['lng'],
    ];
}
```
]

The service also defines critical constants used throughout the geospatial logic:

- `MAX_RADIUS_KM = 100`: Maximum allowed search radius, enforced in validation
- `DEFAULT_RADIUS_KM = 50`: Default radius when parameter is omitted
- `KM_PER_DEGREE = 111.0`: Approximate kilometers per degree latitude for bounding box calculations
- `EARTH_RADIUS_KM = 6371`: Earth's mean radius for Haversine fallback formula
- `SESSION_EXPIRY_SECONDS = 86400`: 24-hour expiry for stored coordinates

These constants centralize magic numbers and provide a single source of truth for geospatial calculations, making the system easier to maintain and test.

==== Phase B: proximity-first selection with hard radius enforcement

Phase B implements the proximity-first selection described in @map-arch-three-phase. The output is intentionally lightweight (IDs only) to avoid loading models and relations before the candidate set is finalized.

#code_example[
Phase B returns only IDs, enforcing the radius as a hard SQL constraint via HAVING.

```php
  <?php
// app/Http/Controllers/Customer/MapController.php
private function selectNearestRestaurantIds(float $centerLat, float $centerLng, float $radius): \Illuminate\Support\Collection
{
    $query = \DB::table('restaurants')
        ->select('id')
        ->whereNotNull('latitude')
        ->whereNotNull('longitude')
        ->selectRaw(
            '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) AS distance_km',
            [$centerLng, $centerLat]
        );

    if ($radius > 0) {
        $bounds = $this->geoService->getBoundingBox($centerLat, $centerLng, $radius);

        $query->whereBetween('latitude', [$bounds['latMin'], $bounds['latMax']])
            ->whereBetween('longitude', [$bounds['lngMin'], $bounds['lngMax']])
            ->havingRaw('distance_km <= ?', [$radius]);
    }

    return $query->orderBy('distance_km', 'asc')
        ->limit(self::MAX_RESTAURANTS_LIMIT)
        ->pluck('id');
}
```
]

The bounding box prefilter pattern described in @map-arch-bounding-box is implemented using indexed range checks (`whereBetween`).

#code_example[
GeoService computes an approximate bounding box and clamps latitude to avoid instability near the poles.

```php
  <?php
// app/Services/GeoService.php
public function getBoundingBox(float $lat, float $lng, float $radiusKm): array
{
    $clampedLat = max(min($lat, self::MAX_LATITUDE), self::MIN_LATITUDE);

    $latDelta = $radiusKm / self::KM_PER_DEGREE;
    $lngDelta = $radiusKm / (self::KM_PER_DEGREE * cos(deg2rad($clampedLat)));

    return [
        'latMin' => $lat - $latDelta,
        'latMax' => $lat + $latDelta,
        'lngMin' => $lng - $lngDelta,
        'lngMax' => $lng + $lngDelta,
    ];
}
```
]

The `HAVING` clause enforces the hard radius guarantee (as specified in @map-arch-guarantees): only rows satisfying `distance_km <= radius` remain candidates, and only then is the limit applied. When `radius = 0`, the `HAVING` clause is omitted and the 250 nearest restaurants globally are returned.

==== Phase B to Phase C boundary: no duplicated scoring

The controller deliberately avoids computing any score while converting the selected IDs. The helper `convertSelectedIdsToArray` exists only to keep Phase boundaries explicit and to ensure scoring has a single source of truth in Phase C.

==== Phase C: scoring once and ordering by quality in SQL

Phase C implements the single-pass SQL computation strategy described in @map-arch-query-optimization. Full restaurant models are hydrated and a composite quality score is computed exactly once in a derived table using three weighted signals: rating (0–50 points), review count (0–30 points, logarithmic scale), and proximity (0–20 points, linear decay).

#code_example[
Phase C builds derived tables: review counts are aggregated once, distance is computed once, and composite score is calculated once.

```php
  <?php
// app/Http/Controllers/Customer/MapController.php
$reviewCounts = \DB::table('reviews')
    ->select('restaurant_id')
    ->selectRaw('COUNT(*) as review_count')
    ->whereIn('restaurant_id', $selectedIds)
    ->groupBy('restaurant_id');

$restaurantsWithDistance = \DB::table('restaurants')
    ->select(['id', 'latitude', 'longitude', 'rating'])
    ->selectRaw(
        '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) AS distance_km',
        [$centerLng, $centerLat]
    )
    ->whereIn('id', $selectedIds);

$scoredRestaurants = \DB::query()
    ->fromSub($restaurantsWithDistance, 'rwd')
    ->leftJoinSub($reviewCounts, 'rc', 'rwd.id', '=', 'rc.restaurant_id')
    ->select(['rwd.id', 'rwd.distance_km'])
    ->selectRaw('COALESCE(rc.review_count, 0) as review_count')
    ->selectRaw('(COALESCE(rwd.rating, 0) / 5) * 50 AS rating_score')
    ->selectRaw('LEAST(30, LOG10(COALESCE(rc.review_count, 0) + 1) * 10) AS review_score')
    ->selectRaw('GREATEST(0, 20 * (1 - (rwd.distance_km / 20))) AS distance_score')
    ->selectRaw(
        '((COALESCE(rwd.rating, 0) / 5) * 50 + '.
        'LEAST(30, LOG10(COALESCE(rc.review_count, 0) + 1) * 10) + '.
        'GREATEST(0, 20 * (1 - (rwd.distance_km / 20)))) AS composite_score'
    );
```
]

The scored subquery is joined back to `restaurants` using `joinSub`, preserving Eloquent hydration while keeping ordering in SQL. This avoids the complexity and risks of manual `FIELD()` ordering and eliminates PHP post-processing that could unintentionally change ordering semantics.

#code_example[
The final query joins scores for Eloquent hydration, eager-loads only required relations, and orders by score then distance.

```php
  <?php
// app/Http/Controllers/Customer/MapController.php
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
    ])
    ->orderByDesc('scored.composite_score')
    ->orderBy('scored.distance_km', 'asc');
```
]

Favorite detection is included conditionally for authenticated users via a `LEFT JOIN`, producing an `is_favorited` flag without additional queries. The controller maps each model into a compact JSON-friendly structure required by the map UI (distance, reviews count, score, and a reduced images array). Distance formatting is centralized in `GeoService::formatDistance`, which keeps presentation rounding out of the controller and ensures consistent formatting anywhere distance is displayed.

==== Database indexing strategy for geospatial queries

The three-phase architecture relies on specific database indexes for optimal performance, as described in @map-arch-indexing. The controller documentation explicitly identifies two critical indexes beyond the latitude/longitude indexes:

1. *`reviews.restaurant_id`* index: enables efficient GROUP BY aggregation in the review counts subquery.

2. *`(customer_user_id, restaurant_id)` composite index* on `favorite_restaurants`: optimizes the LEFT JOIN favorite detection when filtered by customer.

==== Empty result handling and early termination

When Phase B returns an empty collection (no restaurants within radius or no restaurants at all), the controller short-circuits Phase C entirely and returns an empty dataset immediately. This optimization avoids constructing complex derived table queries when the result is known to be empty.

#code_example[
The controller terminates early when no candidates are found, avoiding unnecessary query construction.

```php
  <?php
// app/Http/Controllers/Customer/MapController.php
$selectedIds = $this->selectNearestRestaurantIds($centerLat, $centerLng, $radius);

if ($selectedIds->isEmpty()) {
    return Inertia::render('Customer/Map/Index', [
        'restaurants' => [],
        'filters' => [
            'lat' => $validated['lat'] ?? null,
            'lng' => $validated['lng'] ?? null,
            'radius' => $radius,
        ],
    ]);
}
```
]

This pattern ensures that edge cases (user in a rural area with large radius, or very restrictive filters) remain performant.

==== Distance formatting and payload optimization

The `GeoService` provides a centralized `formatDistance` method that normalizes distance values to a consistent precision. This abstraction ensures consistent distance handling across all features (map, restaurant cards, search results) without duplicating rounding logic.

#code_example[
Distance formatting is centralized in GeoService to ensure consistency across the application.

```php
  <?php
// app/Services/GeoService.php
public function formatDistance(float|string|null $distance): ?float
{
    if ($distance === null) {
        return null;
    }

    return round((float) $distance, 2);
}
```
]

The controller also implements a payload optimization strategy to minimize the data sent to the frontend. Since the map UI displays only restaurant cards with thumbnails, ratings, and distances, the full menu hierarchy is unnecessary at this stage. The controller therefore eager-loads only the `images` relation, selecting specific columns (`id`, `restaurant_id`, `image`, `is_primary_for_restaurant`), while deliberately excluding the `foodTypes.menuItems` hierarchy that would otherwise include every food type, menu item, and associated metadata. This reduces response size significantly compared to loading the complete restaurant model with nested relations. Detailed menu data is instead loaded on-demand when users navigate to an individual restaurant page.

=== Frontend implementation: orchestration, state, and synchronized UI

The frontend implements the component hierarchy and separation of concerns described in @map-arch-component-hierarchy. The main implementation artifacts are:

- #source_code_link("resources/js/Pages/Customer/Map/Index.tsx") - the orchestrator entry view that composes layout and delegates business logic to the hook.
- #source_code_link("resources/js/Hooks/useMapPage.ts") - the logic hook that owns state (view, selection, geolocation) and performs Inertia navigation.
- Specialized UI components: #source_code_link("resources/js/Pages/Customer/Map/Partials/MapOverlay.tsx"), #source_code_link("resources/js/Components/Shared/Map.tsx"), #source_code_link("resources/js/Pages/Customer/Map/Partials/BottomSheet.tsx"), and #source_code_link("resources/js/Components/Shared/MapPopup.tsx").

==== Entry composition: MapLayout + Overlay + Map + BottomSheet

The page component wires the hook outputs into the UI, without embedding complex logic in JSX. This keeps the render tree readable and makes behavior changes local to the hook.

#code_example[
`MapIndex` composes the page layout and passes state/handlers to the overlay, map, and bottom sheet.

```tsx
// resources/js/Pages/Customer/Map/Index.tsx
<MapOverlay
  query={query}
  onQueryChange={setQuery}
  hasLocation={filters.lat !== null && filters.lng !== null}
  currentRadius={filters.radius ?? 50}
  onRadiusChange={(r) => {
    if (filters.lat !== null && filters.lng !== null) {
      reloadMap(filters.lat, filters.lng, r);
    }
  }}
  isGeolocating={isGeolocating}
  onTriggerGeolocate={triggerGeolocate}
  isPickingLocation={isPickingLocation}
  setIsPickingLocation={setIsPickingLocation}
  onManualLocation={handleMapGeolocate}
  onError={setLocationError}
  showSearchInArea={showSearchInArea}
  onSearchInArea={searchInArea}
  mapCenter={viewState}
/>

<Map
  viewState={viewState}
  onMove={setViewState}
  markers={mapMarkers}
  mapboxAccessToken={mapboxPublicKey || ''}
/>

<BottomSheet
  restaurants={filteredRestaurants}
  selectedRestaurantId={selectedRestaurantId}
  onSelectRestaurant={selectRestaurant}
/>
```
]

==== MapLayout: preventing body scroll conflicts

A full-screen map creates a conflict with browser scroll behavior. When users interact with the map (panning, zooming), touch and scroll events can accidentally trigger page scrolling, creating a jarring experience. The `MapLayout` component solves this by toggling CSS classes on the document root elements.

#code_example[
MapLayout disables body scrolling on mount and re-enables it on unmount using a cleanup effect.

```tsx
// resources/js/Layouts/MapLayout.tsx
useEffect(() => {
  const html = document.documentElement;
  const body = document.body;

  html.classList.add('is-map-active');
  body.classList.add('is-map-active');

  return () => {
    html.classList.remove('is-map-active');
    body.classList.remove('is-map-active');
  };
}, []);
```
]

The corresponding CSS rules set `overflow: hidden` on these elements when the class is present, preventing background scrolling without affecting the map's internal pan/zoom interactions or the bottom sheet's scrollable content. This approach is more reliable than inline style manipulation and works consistently across mobile and desktop browsers.

==== `useMapPage`: single source of truth for page state

The `useMapPage` hook manages:
- Search query state and Fuse-based filtering (via a shared `useSearch` hook).
- View state (camera position) and derived “Search here” visibility.
- Selection state (selected restaurant ID).
- Geolocation flow, including a defensive error message when the Mapbox control is not ready.
- Inertia navigation for dataset refresh, using partial reloads to only re-fetch `restaurants` and `filters`.

Following the hybrid client-server architecture described in @map-arch-data-flow, the hook requests only the props that must change, while preserving UI state and scroll position.

#code_example[
Reload operations fetch only `restaurants` and `filters`, preserving UI state and scroll to keep interactions responsive.

```ts
// resources/js/Hooks/useMapPage.ts
const reloadMap = useCallback((lat: number, lng: number, radius: number) => {
  router.get(
    route('map.index'),
    { lat, lng, radius },
    {
      replace: true,
      preserveState: true,
      preserveScroll: true,
      only: ['restaurants', 'filters'],
    },
  );
}, []);
```
]

==== "Search here": exploration without losing user context

The "Search here" button appears when the camera moves more than ~0.01 degrees (~1 km) from the initial center. This implements the session isolation guarantee from @map-arch-guarantees: `search_lat/search_lng` is sent using the current view center, while preserving existing `lat/lng` if available.

#code_example[
The “Search here” navigation updates only the search center and preserves the user location context.

```ts
// resources/js/Hooks/useMapPage.ts
const searchInArea = useCallback(() => {
  const { latitude, longitude } = viewState;
  setShowSearchInArea(false);

  router.get(
    route('map.index'),
    {
      search_lat: latitude,
      search_lng: longitude,
      ...(filters.lat !== null && filters.lng !== null
        ? { lat: filters.lat, lng: filters.lng }
        : {}),
    },
    {
      replace: true,
      preserveState: true,
      preserveScroll: true,
      only: ['restaurants', 'filters'],
    },
  );
}, [viewState, filters]);
```
]

==== Geolocation integration: trigger mechanism and error handling

The geolocation integration pattern described in @map-arch-geolocation-pattern is implemented using Mapbox's `GeolocateControl`. The control's UI is hidden (`showGeolocateControlUi={false}`) because the overlay provides its own "My Location" button, with a callback registration pattern bridging the two.

#code_example[
The page hook triggers geolocation through the registered callback and provides defensive error handling.

```ts
// resources/js/Hooks/useMapPage.ts
const triggerGeolocate = useCallback(() => {
  const ok = geolocateTriggerRef.current?.();
  if (!ok) {
    setLocationError(
      'Geolocation control not ready yet. Refresh and try again.',
    );
    return;
  }
  setIsGeolocating(true);
}, []);
```
]

The geolocation hook inside the Map component handles both success and error cases. On success, it calls `onGeolocate` with the coordinates. On error, it extracts error codes and maps them to user-friendly messages.

#code_example[
Error extraction maps browser geolocation error codes to actionable user messages.

```ts
// resources/js/Hooks/useMapGeolocation.ts (inside Map component)
const handleGeolocateError = useCallback((evt: unknown) => {
  const { code, message } = extractGeolocateError(evt);

  let errorMessage = message || 'Unable to get your location. Please check browser/OS location permissions.';

  switch (code) {
    case 1: // PERMISSION_DENIED
      errorMessage = 'Location access denied. Allow location permissions to see nearby restaurants.';
      break;
    case 2: // POSITION_UNAVAILABLE
      errorMessage = 'Location information unavailable. Check OS location services or try again.';
      break;
    case 3: // TIMEOUT
      errorMessage = 'Location request timed out. Try again or disable high accuracy.';
      break;
  }

  onGeolocateError?.(errorMessage);
}, [onGeolocateError]);
```
]

This defensive error handling ensures users receive clear, actionable guidance when geolocation fails, rather than generic browser error messages.

==== Overlay controls: location, radius, and manual entry

The overlay component provides three complementary ways to set a location:
1. “My Location” triggers geolocation.
2. “Enter Coords” accepts manual latitude/longitude with client-side range validation.
3. “Pick on Map” activates a click-to-set mode on the map canvas.

Radius selection is implemented with a deliberate commit strategy: the slider updates its local value continuously for smooth UX, but calls `onRadiusChange` only on commit (mouse up / touch end / keyboard release). This prevents flooding the backend with intermediate values while dragging.

A “No range” slider endpoint maps to backend `radius = 0`, enabling the explicit opt-out mode that the controller supports.

==== Map component: clustering, selection, and click modes

The map component turns restaurant markers into a GeoJSON source with clustering enabled. Clustering improves readability and performance at low zoom levels.

The click handler is intentionally multi-modal:
- In pick mode, any click sets user location and exits pick mode.
- In normal mode:
  - cluster clicks zoom into the cluster expansion level,
  - point clicks select a restaurant and open the popup,
  - empty clicks clear selection.

#code_example[
The click handler switches behavior based on location-picking mode, while preserving normal clustering/selection semantics.

```tsx
// resources/js/Components/Shared/Map.tsx
const handleMapClick = React.useCallback(
  (event: MapMouseEvent) => {
    if (isPickingLocation) {
      const { lng, lat } = event.lngLat;
      onPickLocation?.(lat, lng);
      return;
    }

    const map = mapRef.current?.getMap();
    if (!map) return;

    const features = map.queryRenderedFeatures(event.point, {
      layers: ['clusters', 'unclustered-point'],
    });

    if (features.length > 0) {
      const feature = features[0];

      if (feature.layer?.id === 'clusters') {
        // Zoom into cluster (expansion zoom)
      } else if (feature.layer?.id === 'unclustered-point') {
        // Select restaurant point -> open popup
        const properties = feature.properties;
        if (!properties || feature.geometry.type !== 'Point') return;
        onSelectRestaurant?.(properties.id);
      }
    } else {
      onSelectRestaurant?.(null);
    }
  },
  [isPickingLocation, onPickLocation, onSelectRestaurant],
);
```
]

When a restaurant is selected, the map animates the camera using `flyTo` and applies padding so the selected point remains visible above overlay UI and the bottom sheet. This is a small but important UX decision: it prevents the user from "losing" the selected restaurant under floating UI elements.

#code_example[
Camera animation applies UI-aware padding to keep the selected restaurant visible.

```tsx
// resources/js/Components/Shared/Map.tsx
map.flyTo({
  center: [selectedRestaurant.lng, selectedRestaurant.lat],
  zoom: Math.max(viewState.zoom, 10),
  duration: 900,
  essential: true,
  padding: { top: 240, bottom: 280, left: 40, right: 40 },
});
```
]

The padding values are carefully tuned to account for the overlay height at the top and the bottom sheet in its expanded state. The `essential: true` flag ensures the animation respects user preferences for reduced motion, improving accessibility.

The map also includes runtime API key validation to fail fast with a clear error message if the Mapbox key is missing or if a secret key (starting with `sk.`) is accidentally used in the browser.

#code_example[
Mapbox token validation prevents configuration errors and credential leaks.

```tsx
// resources/js/Components/Shared/Map.tsx
if (!mapboxAccessToken) {
  return <div className="map-error-message">Mapbox API key is not configured.</div>;
}

if (!mapboxAccessToken.startsWith('pk.')) {
  return <div className="map-error-message">Invalid Mapbox API key type.</div>;
}
```
]

This validation runs before initializing Mapbox, providing immediate feedback during development and preventing accidental exposure of secret tokens in production bundles.

==== Bottom sheet: pointer-driven drag, snapping, and selection sync

The restaurant list is implemented as a draggable bottom sheet using Pointer Events API with pointer capture. This approach yields consistent behavior across mouse and touch devices, avoiding the complexities of managing separate touch and mouse event handlers.

The drag implementation uses three key techniques:

1. *Pointer capture*: When drag starts (`onPointerDown`), the sheet captures the pointer using `setPointerCapture`. This ensures all subsequent pointer events (move, up) are delivered to the sheet element even if the pointer moves outside its bounds.

2. *Drag detection*: A `dragMovedRef` flag tracks whether the pointer has moved significantly since press. This distinguishes intentional drags from clicks.

3. *Snap-on-release*: When the pointer is released, the sheet snaps to either collapsed or expanded state based on its current position. The snap threshold uses the midpoint between states to provide intuitive behavior.

#code_example[
The bottom sheet prevents click-toggle immediately after drag to avoid accidental actions.

```tsx
// resources/js/Pages/Customer/Map/Partials/BottomSheet.tsx
const toggleSheet = () => {
  if (dragMovedRef.current) {
    dragMovedRef.current = false;
    return;
  }

  setSheetHeight((h) => (h <= COLLAPSED_PX + 2 ? expandedPx : COLLAPSED_PX));
};
```
]

Selection synchronization requires careful timing. When a restaurant becomes selected (either from map click or list click), the bottom sheet must scroll the corresponding card into view. However, if the sheet is transitioning between collapsed and expanded states, measuring card positions during the transition produces incorrect offsets.

The solution waits for CSS transitions to complete before measuring and scrolling. It observes `transitionend` events with a timeout fallback (300ms) to handle cases where the transition is interrupted or already complete.

#code_example[
Auto-scroll waits for transitions to complete before measuring positions to avoid layout thrashing.

```tsx
// resources/js/Pages/Customer/Map/Partials/BottomSheet.tsx
const waitForTransition = new Promise<void>((resolve) => {
  let resolved = false;

  const onTransitionEnd = () => {
    if (resolved) return;
    resolved = true;
    resolve();
  };

  sheetRef.current?.addEventListener('transitionend', onTransitionEnd, { once: true });

  setTimeout(() => {
    if (resolved) return;
    resolved = true;
    resolve();
  }, 500);
});
```
]

After the transition completes, the implementation measures the card position, calculates the scroll offset needed to center it in the visible area, clamps the result to valid scroll boundaries, and performs a smooth scroll. This ensures the selected restaurant is always visible and centered, providing clear visual feedback regardless of whether selection originated from the map or the list.

=== Summary

The map-based restaurant discovery feature demonstrates a complete implementation combining the architectural patterns from @map-architecture with the technology choices from @map-technologies.

*Backend implementation highlights:*
- The three-phase processing pipeline (@map-arch-three-phase) is realized through distinct controller methods that enforce phase boundaries
- SQL-level radius enforcement via HAVING clauses guarantees the architectural invariants (@map-arch-guarantees)
- Single-pass score computation (@map-arch-query-optimization) is implemented using Laravel's `fromSub` and `joinSub` query builder methods

*Frontend implementation highlights:*
- The component hierarchy (@map-arch-component-hierarchy) is implemented with clear separation between the page orchestrator, logic hook, and UI partials
- The geolocation callback registration pattern (@map-arch-geolocation-pattern) bridges the hidden Mapbox control with custom overlay buttons
- Bottom sheet drag behavior uses Pointer Events API with capture for cross-device consistency
- Transition-aware auto-scroll prevents layout measurement errors during CSS animations

*User experience refinements:*
- Multiple location acquisition methods (geolocation, manual entry, map click) provide fallback options
- Commit-on-release radius slider prevents backend flooding during drag interactions
- Camera animation with UI-aware padding keeps selected restaurants visible above overlays
- Error messages map browser geolocation codes to actionable user guidance
