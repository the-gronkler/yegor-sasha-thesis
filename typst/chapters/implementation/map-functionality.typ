#import "../../config.typ": source_code_link, code_example

== Map-Based Restaurant Discovery Implementation <map-implementation>

This section describes how the map-based discovery feature was implemented in the customer-facing application. The implementation follows the technology choices described in @map-technologies and applies the architectural organization described in @map-architecture.

The main implementation artifacts are:
- Backend controller: #source_code_link("app/Http/Controllers/Customer/MapController.php")
- Geospatial helper service: #source_code_link("app/Services/GeoService.php")
- Page component: #source_code_link("resources/js/Pages/Customer/Map/Index.tsx")
- Page logic hook: #source_code_link("resources/js/Hooks/useMapPage.ts")
- Map component: #source_code_link("resources/js/Components/Shared/Map.tsx")
- Overlay controls: #source_code_link("resources/js/Pages/Customer/Map/Partials/MapOverlay.tsx")
- Bottom sheet list: #source_code_link("resources/js/Pages/Customer/Map/Partials/BottomSheet.tsx")
- Popup: #source_code_link("resources/js/Components/Shared/MapPopup.tsx")
- Map style layers: #source_code_link("resources/js/Components/Shared/mapStyles.ts")
- Layout wrapper: #source_code_link("resources/js/Layouts/MapLayout.tsx")

=== Backend implementation

The discovery dataset is produced by the `MapController@index` action. It implements the three-stage request pipeline described in @map-architecture: (1) resolve the request center, (2) select a bounded candidate set by proximity (and optional radius), and (3) rank and hydrate the final dataset.

==== Request validation and filter semantics

The endpoint accepts optional coordinates and a radius. All parameters are optional so the page can load with safe defaults.

#code_example[
The controller authorizes access and validates optional geospatial parameters before executing queries.

```php
// app/Http/Controllers/Customer/MapController.php
public function index(Request $request): Response
{
    $this->authorize('viewAny', Restaurant::class);

    $validated = $request->validate([
        'lat' => 'nullable|numeric|between:-90,90',
        'lng' => 'nullable|numeric|between:-180,180',
        'search_lat' => 'nullable|numeric|between:-90,90',
        'search_lng' => 'nullable|numeric|between:-180,180',
        'radius' => 'nullable|numeric|min:0|max:' . GeoService::MAX_RADIUS_KM,
    ]);

    // ...
}
```
]

Two location concepts are supported (as described in @map-architecture):

/ *User location* (`lat`/`lng`): persisted in the Laravel session to improve defaults across visits.
/ *Search center* (`search_lat`/`search_lng`): an ephemeral exploration center used by the "Search here" interaction.

Only the user location updates session state. The search center affects only the current request.

==== Center resolution (Phase A)

The controller resolves one effective center point using a priority cascade: search center -> user location -> session fallback -> default.

#code_example[
The normalization method applies the priority cascade and persists only explicit user location.

```php
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

Session retrieval and expiry validation are handled inside `GeoService`, keeping session logic out of the controller.

#code_example[
`GeoService` rejects missing or expired session values and returns a normalized coordinate pair.

```php
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

==== Candidate selection with optional radius (Phase B)

After resolving the center, the controller selects a bounded set of restaurant IDs by distance. When radius is enabled, it is enforced in SQL (not post-filtered), so the returned candidate set cannot contain out-of-range restaurants.

#code_example[
Phase B selects only IDs and enforces the radius in SQL.

```php
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

The bounding-box filter is implemented in `GeoService` and is used as a cheap coarse prefilter before exact distance checks.

#code_example[
Bounding box computation approximates coordinate deltas from a radius and clamps latitude to remain stable.

```php
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

If no candidates are found, the controller short-circuits and returns an empty dataset, avoiding unnecessary scoring query construction.

==== Scoring, hydration, and ordering (Phase C)

Within the bounded candidate set, the controller computes a composite score in SQL and joins it back to the `restaurants` table to hydrate Eloquent models while keeping ordering in the database.

#code_example[
Phase C aggregates review counts once, computes distance once, and orders by a derived composite score.

```php
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
    ->selectRaw(
        '((COALESCE(rwd.rating, 0) / 5) * 50 + ' .
        'LEAST(30, LOG10(COALESCE(rc.review_count, 0) + 1) * 10) + ' .
        'GREATEST(0, 20 * (1 - (rwd.distance_km / 20)))) AS composite_score'
    );

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
        'scored.distance_km as distance',
        'scored.review_count as reviews_count',
        'scored.composite_score',
    ])
    ->orderByDesc('scored.composite_score')
    ->orderBy('scored.distance_km', 'asc');
```
]

The controller formats values for the frontend payload and rounds distance values using a small helper on `GeoService`.

#code_example[
Distance rounding is centralized in `GeoService` so the frontend receives a stable numeric value.

```php
// app/Services/GeoService.php
public function formatDistance(?float $distanceKm): ?float
{
    return $distanceKm === null ? null : round($distanceKm, 2);
}
```
]

=== Frontend implementation

The frontend is split into a page component (composition), a page hook (state and navigation), and focused UI components (overlay, map canvas, popup, list). This mirrors the separation described in @map-architecture, but the following subsections focus on how the behavior is implemented in code.

==== Page composition

The map page wires hook state and callbacks into the overlay, map canvas, and bottom sheet.

#code_example[
The page component remains declarative: it composes the UI and passes state and handlers from the page hook.

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

==== Dataset refresh and "Search here"

The `useMapPage` hook triggers server refreshes through Inertia visits and requests only the dataset props that change. It also implements the "Search here" behavior by sending `search_lat` and `search_lng` based on the current camera center.

#code_example[
The hook uses Inertia visits to refresh only the dataset props while keeping client UI state.

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

#code_example[
"Search here" uses the current view center as an ephemeral search center and preserves user location when available.

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

==== Map interaction and selection

The `Map` component converts restaurants into a GeoJSON source, enables Mapbox clustering, and exposes selection through a single callback. It also supports a "pick on map" mode where a click sets the user location instead of selecting a restaurant.

To reduce configuration mistakes, the component validates that the Mapbox token is present and is the correct public token type before initializing the map.

==== Draggable list synchronization

The `BottomSheet` component uses pointer events and snapping to provide a mobile-friendly list surface. It synchronizes selection by scrolling the selected restaurant card into view; since the bottom sheet can be mid-transition when selection changes, the implementation waits for the sheet transition to settle before measuring and scrolling.

#code_example[
The selection scroll waits for a relevant transition event (with a timeout fallback) before scrolling the selected card.

```tsx
// resources/js/Pages/Customer/Map/Partials/BottomSheet.tsx
useLayoutEffect(() => {
  if (!selectedRestaurantId) return;

  const sheetEl = sheetRef.current;
  const cardEl = cardRefs.current.get(selectedRestaurantId);
  if (!sheetEl || !cardEl) return;

  let done = false;

  const waitForTransition = new Promise<void>((resolve) => {
    const onEnd = (e: TransitionEvent) => {
      if (done) return;

      if (e.propertyName !== 'padding' && e.propertyName !== 'min-height' && e.propertyName !== 'gap') {
        return;
      }

      done = true;
      sheetEl.removeEventListener('transitionend', onEnd);
      resolve();
    };

    sheetEl.addEventListener('transitionend', onEnd);

    window.setTimeout(() => {
      if (done) return;
      done = true;
      sheetEl.removeEventListener('transitionend', onEnd);
      resolve();
    }, 300);
  });

  waitForTransition.then(() => {
    const sheetRect = sheetEl.getBoundingClientRect();
    const cardRect = cardEl.getBoundingClientRect();

    const current = sheetEl.scrollTop;
    const delta = (cardRect.top - sheetRect.top) - sheetRect.height / 2 + cardRect.height / 2;

    sheetEl.scrollTo({ top: Math.max(0, current + delta), behavior: 'smooth' });
  });
}, [selectedRestaurantId]);
```
]

=== Summary

The map feature is implemented as a thin, validated backend endpoint plus an interactive frontend page:

- The backend resolves the effective center, enforces radius constraints in SQL, and produces a bounded, ranked dataset.
- The frontend refreshes only the dataset props when filters change, keeping camera and selection stable.
- Map selection and the bottom-sheet list remain synchronized through a single selection state owned by the page hook.
