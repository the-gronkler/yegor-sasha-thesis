#import "../../config.typ": source_code_link, code_example

== Map-Based Restaurant Discovery Implementation <map-implementation>

This section describes the implementation of the customer-facing map feature that supports spatial exploration of restaurants, radius-based filtering, and interactive selection. The map functionality is implemented as a collaboration between a Laravel backend endpoint that provides validated, performance-bounded restaurant datasets and a React-based frontend that renders an interactive Mapbox map and associated overlay controls. The described material belongs to the implementation level: it focuses on code structure, request validation, query building, and UI interaction logic.

The main implementation artifacts discussed in this section are the customer map controller #source_code_link("app/Http/Controllers/Customer/MapController.php"), the restaurant model scopes used for geospatial computations #source_code_link("app/Models/Restaurant.php"), the map page entry component #source_code_link("resources/js/Pages/Customer/Map/Index.tsx"), the page-level logic hook #source_code_link("resources/js/Hooks/useMapPage.ts"), the shared map component #source_code_link("resources/js/Components/Shared/Map.tsx"), the customer map overlay UI #source_code_link("resources/js/Pages/Customer/Map/Partials/MapOverlay.tsx"), the draggable restaurant list #source_code_link("resources/js/Pages/Customer/Map/Partials/BottomSheet.tsx"), the map popup component #source_code_link("resources/js/Components/Shared/MapPopup.tsx"), the Mapbox layer definitions #source_code_link("resources/js/Components/Shared/mapStyles.ts"), and the map-specific layout wrapper #source_code_link("resources/js/Layouts/MapLayout.tsx").

=== Feature requirements translated into implementation constraints

The project scope describes the map as a discovery surface for restaurants, including distance-aware browsing and signals such as rating and popularity. In implementation terms, this implies several constraints.

First, map requests must remain performant. Rendering and clustering many points in the browser scales poorly when the payload grows without bounds, therefore the backend must enforce a strict maximum number of restaurants returned per request and must control the shape of the payload. Second, the system must support two conceptually different locations: the user location (which may be persisted to the session) and a temporary search center (used for the "search in this area" interaction). Third, the radius filter must support both a strict nearby mode and an opt-out mode that allows browsing without distance limits. Fourth, location acquisition must degrade gracefully when device geolocation is unavailable, denied, or inaccurate. Fifth, selection must be synchronized across the map canvas and the restaurant list.

These constraints appear explicitly in the controller validation rules, the result limiting logic, the query-scoped distance computations, and the frontend interaction patterns.

=== Backend endpoint and filter contract

==== Authorization and request validation

The map dataset is produced by the `index` action in #source_code_link("app/Http/Controllers/Customer/MapController.php"). The first operation is an authorization check to ensure that the requesting user is allowed to view restaurants. This is implementation-critical because the map can expose a broad subset of restaurant metadata.

The controller validates input parameters before constructing the query. Latitude and longitude are constrained to legal ranges, and the radius parameter is restricted to a maximum value defined in the geospatial service. The endpoint also accepts optional `search_lat` and `search_lng` parameters. These are used to support querying around the current map center without overwriting the persisted user location.

#code_example[
The controller enforces strict validation for coordinates and radius to prevent invalid or unbounded geospatial queries.

```php
// app/Http/Controllers/Customer/MapController.php
$validated = $request->validate([
    'lat' => 'nullable|numeric|between:-90,90',
    'lng' => 'nullable|numeric|between:-180,180',
    'search_lat' => 'nullable|numeric|between:-90,90',
    'search_lng' => 'nullable|numeric|between:-180,180',
    'radius' => 'nullable|numeric|min:0|max:' . GeoService::MAX_RADIUS_KM,
]);
```
]

The validation model intentionally allows `radius = 0`. In this case, the backend interprets it as an opt-out mode where results are not constrained by distance.

==== Defensive result limiting and payload shaping

The controller defines a strict upper bound on the number of restaurants returned per request, which limits worst-case serialization size and bounds client-side rendering work. The query also selects only the columns required by the map UI and eagerly loads only the image data needed for map popup cards.

#code_example[
A hard server-side limit is used to guarantee predictable response sizes.

```php
// app/Http/Controllers/Customer/MapController.php
private const MAX_RESTAURANTS_LIMIT = 250;

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
    ->whereNotNull('latitude')
    ->whereNotNull('longitude')
    ->limit(self::MAX_RESTAURANTS_LIMIT);
```
]

A key optimization is the avoidance of deeply nested menu datasets on the map page. This decision keeps the map endpoint focused on discovery and avoids transferring large unrelated payloads.

==== Favorites integration

The map response includes an `is_favorited` flag for each restaurant when the user is authenticated. The backend implements this efficiently by using a `LEFT JOIN` against the favorites pivot table. This avoids an additional query and reduces the time complexity compared to loading a separate favorites list and checking membership in application code.

#code_example[
The map query uses a `LEFT JOIN` to compute an `is_favorited` column without additional roundtrips.

```php
// app/Http/Controllers/Customer/MapController.php
if ($customerId) {
    $query->leftJoin('favorite_restaurants', function ($join) use ($customerId) {
        $join->on('restaurants.id', '=', 'favorite_restaurants.restaurant_id')
            ->where('favorite_restaurants.customer_user_id', '=', $customerId);
    })->addSelect(\DB::raw(
        'CASE WHEN favorite_restaurants.restaurant_id IS NOT NULL THEN 1 ELSE 0 END as is_favorited'
    ));
}
```
]

This field can be used by the frontend in lists and cards to show favorited state without requiring additional API calls.

=== Backend geospatial filtering strategy

==== Persisted user location and ephemeral search center

The controller distinguishes between the user location (`lat`, `lng`) and the search center (`search_lat`, `search_lng`). Only the former is persisted in the session. If the request does not include coordinates, previously stored coordinates may be reused to provide distance-aware ranking and display.

#code_example[
User location can be persisted to the session, while "search in this area" uses separate coordinates.

```php
// app/Http/Controllers/Customer/MapController.php
$distanceCalcLat = $searchLatitude ?? $latitude;
$distanceCalcLng = $searchLongitude ?? $longitude;

if ($distanceCalcLat === null && $distanceCalcLng === null) {
    $geo = $this->geoService->getValidGeoFromSession($request);
    if ($geo) {
        $distanceCalcLat = $geo['lat'];
        $distanceCalcLng = $geo['lng'];
    }
}

if ($latitude !== null && $longitude !== null) {
    $this->geoService->storeGeoInSession($request, $latitude, $longitude);
}
```
]

The separation enables explorative browsing without permanently changing the stored user context.

==== Distance computation as a model scope (ST_Distance_Sphere and Haversine fallback)

Distance computation is implemented as an Eloquent local scope in #source_code_link("app/Models/Restaurant.php"). The scope adds a computed `distance` column (in kilometers) to each row. When configured to do so, it uses MariaDB’s `ST_Distance_Sphere` function, and it can fall back to a numerically-stable Haversine formula. The fallback clamps the `acos` input to avoid `NaN` results due to floating point rounding.

#code_example[
The distance scope preserves base columns, then appends a computed `distance` value using a spatial function or a Haversine fallback.

```php
// app/Models/Restaurant.php
public function scopeWithDistanceTo($query, float $lat, float $lng)
{
    if (is_null($query->getQuery()->columns)) {
        $query->select($query->getModel()->getTable() . '.*');
    }

    $useStDistance = config('geo.distance_formula', 'st_distance_sphere') === 'st_distance_sphere';

    if ($useStDistance) {
        return $query->selectRaw(
            '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) AS distance',
            [$lng, $lat]
        );
    }

    return $query->selectRaw(
        '(? * acos(LEAST(1.0, GREATEST(-1.0,
            cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?))
            + sin(radians(?)) * sin(radians(latitude))
        )))) AS distance',
        [GeoService::EARTH_RADIUS_KM, $lat, $lng, $lat]
    );
}
```
]

The map controller applies this scope when a calculation location is available. The computed distance is also formatted via the geospatial service before being returned to the frontend.

==== Bounding-box prefilter

Even with a spatial distance function, computing distance for every restaurant row is expensive. The backend therefore applies a bounding box prefilter when a non-zero radius is active. The bounding box is computed in #source_code_link("app/Services/GeoService.php"). It approximates degrees per kilometer and adjusts longitude delta based on latitude. The latitude is clamped to avoid unstable computations near the poles.

#code_example[
The geospatial service calculates bounding box coordinates for prefiltering.

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

The controller then uses `whereBetween` constraints for latitude and longitude as a candidate reduction step.

==== Radius semantics and adaptive expansion

The backend uses a default radius if the parameter is omitted, and it treats `0` as "no range". For a "search in this area" request with very small radii, the backend may automatically expand the effective radius to improve coverage. The implementation returns both the actual radius used and the originally requested radius to support transparency in the UI.

#code_example[
The controller returns metadata that distinguishes the user-requested radius from the internally used (possibly expanded) radius.

```php
// app/Http/Controllers/Customer/MapController.php
return Inertia::render('Customer/Map/Index', [
    'restaurants' => $restaurants,
    'filters' => [
        'lat' => $latitude,
        'lng' => $longitude,
        'radius' => $actualRadius,
        'requested_radius' => $radius,
        'radius_expanded' => $expandedRadius,
    ],
]);
```
]

==== In-radius classification

When radius expansion is active, the backend also computes whether a restaurant lies within the originally requested radius. This boolean flag is used to prioritize “strictly in-radius” results in ordering while still allowing “nearby but slightly outside” results to appear when the radius was expanded.

#code_example[
The backend adds an `is_in_radius` column computed against the original radius (not the expanded one).

```php
// app/Http/Controllers/Customer/MapController.php
$query->selectRaw(
    '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) <= ? as is_in_radius',
    [$distanceCalcLng, $distanceCalcLat, $radius]
);
```
]

=== Backend composite scoring and ordering

The map feature ranks restaurants using a composite score that incorporates rating, review count, and proximity. Scoring occurs in SQL so that ordering is executed in the database prior to materialization into PHP collections.

The current implementation uses:

- Rating score component scaled to 0–50 points.
- Review score component scaled to 0–30 points (log-scaled).
- Distance score component up to 20 points when a location is available.

#code_example[
The final ordering prioritizes in-radius results and then orders by distance and composite score.

```php
// app/Http/Controllers/Customer/MapController.php
if ($hasLocation) {
    $query->orderByRaw('is_in_radius DESC, distance ASC, composite_score DESC');
} else {
    $query->orderByRaw('composite_score DESC');
}
```
]

This ordering policy ensures that the most relevant restaurants are presented first in list views (such as the bottom sheet), and that the list ordering remains consistent with spatial proximity expectations.

=== Frontend composition: page wiring, layout, overlay, and list synchronization

==== MapIndex as a controller view

The map page is implemented as an Inertia page in #source_code_link("resources/js/Pages/Customer/Map/Index.tsx"). This file acts as a controller-like view that composes the layout and binds the page-level logic hook to the UI components. It intentionally delegates complex interaction logic to `useMapPage` and delegates complex UI to partial components.

#code_example[
The map page composes its UI as `MapLayout > MapOverlay + Map + BottomSheet` and binds all interaction handlers from `useMapPage`.

```tsx
// resources/js/Pages/Customer/Map/Index.tsx
const {
  query,
  setQuery,
  filteredRestaurants,
  viewState,
  setViewState,
  selectedRestaurantId,
  selectRestaurant,
  locationError,
  isGeolocating,
  triggerGeolocate,
  registerGeolocateTrigger,
  isPickingLocation,
  setIsPickingLocation,
  handleMapGeolocate,
  handleGeolocateError,
  handlePickLocation,
  mapMarkers,
  reloadMap,
  showSearchInArea,
  searchInArea,
} = useMapPage({ restaurants, filters, mapboxPublicKey });
```
]

This structure enforces separation of concerns: the page is responsible for composition and prop wiring, while the hook and partials implement behavior and presentation.

==== Scroll management via MapLayout

A full-screen map competes with browser scroll behavior on mobile and desktop. The layout component #source_code_link("resources/js/Layouts/MapLayout.tsx") toggles a CSS class on the `<html>` and `<body>` elements to disable body scrolling while the map is active.

#code_example[
The layout toggles an `is-map-active` class to allow overflow control via CSS.

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

This approach avoids accidental scrolling behind the map canvas and ensures that the bottom sheet drag interaction behaves predictably.

==== Local search filtering (Fuse-based)

The hook #source_code_link("resources/js/Hooks/useMapPage.ts") performs client-side text filtering using the `useSearch` abstraction (which uses Fuse-compatible options). It allows quick incremental search without triggering network requests or backend filtering. The search options include weighted keys such as restaurant name, description, and nested domain data.

#code_example[
Client-side fuzzy search is configured with weighted keys for relevant restaurant fields.

```ts
// resources/js/Hooks/useMapPage.ts
const SEARCH_OPTIONS: IFuseOptions<Restaurant> = {
  keys: [
    { name: 'name', weight: 2 },
    { name: 'description', weight: 1.5 },
    { name: 'food_types.name', weight: 1 },
    { name: 'food_types.menu_items.name', weight: 0.5 },
  ],
};
```
]

==== Computing map markers and enriching popup metadata

The hook converts filtered restaurants into the marker model consumed by the map component. This includes deriving a primary image URL and passing optional metadata such as opening hours, rating, and formatted distance.

The implementation also inserts a synthetic user marker when a location is available. This marker uses an id of `-1` so that it can be reliably separated from restaurant markers on the map.

#code_example[
Markers are computed from filtered restaurants, and a synthetic user marker is appended when a location exists.

```ts
// resources/js/Hooks/useMapPage.ts
const userMarker =
  filters.lat !== null && filters.lng !== null
    ? [{ id: -1, lat: filters.lat, lng: filters.lng, name: 'You are here' }]
    : [];

return [...restaurantMarkers, ...userMarker];
```
]

This approach avoids coupling user marker rendering to backend data and keeps UI behavior deterministic.

==== Partial reloads for radius updates

When the user adjusts radius and a location is known, the map page performs a partial reload via Inertia. Only the `restaurants` and `filters` props are re-fetched, while page state is preserved.

#code_example[
The hook uses Inertia navigation to refresh only the props needed by the map without a full-page reload.

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

==== "Search in this area" as an explicit interaction

The map must not trigger server requests on every pan/zoom. Instead, the hook shows a button when the viewport center moves a significant distance from the initial center. Only when the user explicitly requests it does the hook send `search_lat` and `search_lng` to the backend.

#code_example[
When the map is moved sufficiently from the initial center, a state flag enables the "search in this area" button.

```ts
// resources/js/Hooks/useMapPage.ts
if (initialCenterRef.current) {
  const { lat: initialLat, lng: initialLng } = initialCenterRef.current;
  const latDiff = Math.abs(newViewState.latitude - initialLat);
  const lngDiff = Math.abs(newViewState.longitude - initialLng);

  if (latDiff > 0.01 || lngDiff > 0.01) {
    setShowSearchInArea(true);
  }
}
```
]

#code_example[
The explicit search action sends `search_lat` and `search_lng` while preserving any persisted user location.

```ts
// resources/js/Hooks/useMapPage.ts
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
```
]

This design reduces unnecessary network usage, improves perceived responsiveness, and keeps server filtering tied to explicit user intent.

==== Overlay controls: location modes and radius UX

The map overlay #source_code_link("resources/js/Pages/Customer/Map/Partials/MapOverlay.tsx") manages collapsible UI panels and supports three location acquisition modes:

- Device geolocation trigger (delegated to the Mapbox `GeolocateControl`).
- Manual latitude/longitude entry with validation.
- Pick-on-map mode, where clicking the map sets the location.

The radius slider uses a sentinel value for “no range”, which is converted to `radius = 0` in the backend contract.

#code_example[
The overlay reserves the rightmost slider value to represent "No range" and converts it to `radius = 0`.

```ts
// resources/js/Pages/Customer/Map/Partials/MapOverlay.tsx
const NO_RANGE_SLIDER_VALUE = 51;

const sliderToRadius = (sliderValue: number) => {
  return sliderValue === NO_RANGE_SLIDER_VALUE ? 0 : sliderValue;
};
```
]

#code_example[
Manual coordinate input is validated for numeric values and legal coordinate ranges.

```ts
// resources/js/Pages/Customer/Map/Partials/MapOverlay.tsx
const lat = Number(manualLat);
const lng = Number(manualLng);

if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
  onError('Please enter valid numeric latitude/longitude.');
  return;
}
if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
  onError('Latitude must be -90..90 and longitude must be -180..180.');
  return;
}

onManualLocation(lat, lng);
```
]

Finally, the overlay renders the explicit "Search in this area" action when enabled by the hook.

==== Bottom sheet: list synchronization and selection auto-scrolling

The restaurant list is rendered in a draggable bottom sheet (#source_code_link("resources/js/Pages/Customer/Map/Partials/BottomSheet.tsx")). The component implements pointer-event drag handling and snapping behavior, and it auto-scrolls the list to center the selected restaurant card. This provides a tight coupling between a map selection (marker click) and list browsing.

#code_example[
The bottom sheet snaps to expanded/collapsed states based on pointer drag and prevents click toggles immediately after drag.

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

#code_example[
When a restaurant becomes selected, the list scrolls to center the corresponding card.

```tsx
// resources/js/Pages/Customer/Map/Partials/BottomSheet.tsx
container.scrollTo({
  top: clamped,
  behavior: 'smooth',
});
```
]

=== Mapbox visualization and interaction model

==== Mapbox token safety checks

The shared map component #source_code_link("resources/js/Components/Shared/Map.tsx") validates the Mapbox access token on the client side. This guardrail detects missing configuration and prevents secret tokens from being used in browser code. Such checks provide immediate feedback during development and reduce the risk of accidental credential exposure.

#code_example[
The component requires a public Mapbox token (prefix `pk.`) and blocks invalid configurations.

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

==== Controlled view state and camera animation

The map component is controlled by the page-level `viewState`. Movement events propagate updates to the hook, allowing derived behaviors such as the "search in this area" prompt and consistent marker/list synchronization.

When a restaurant becomes selected, the map animates the camera to the restaurant location. The implementation uses `flyTo` with padding values that account for overlay UI and the bottom sheet.

#code_example[
Selection triggers a camera transition with overlay-aware padding.

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

==== GeoJSON source design and clustering

Restaurants are rendered through a GeoJSON `Source` with clustering enabled. The map component splits the input marker set into restaurant markers and a synthetic user marker, then constructs a GeoJSON `FeatureCollection` for restaurants. Each feature’s properties include fields required for the popup component.

#code_example[
Restaurant markers are converted into GeoJSON features with popup-relevant properties.

```tsx
// resources/js/Components/Shared/Map.tsx
const restaurantGeoJson = {
  type: 'FeatureCollection',
  features: restaurantMarkers.map((marker) => ({
    type: 'Feature',
    geometry: {
      type: 'Point',
      coordinates: [marker.lng, marker.lat],
    },
    properties: {
      id: marker.id,
      name: marker.name,
      address: marker.address,
      openingHours: marker.openingHours,
      rating: marker.rating,
      distanceKm: marker.distanceKm,
      imageUrl: marker.imageUrl,
    },
  })),
};
```
]

The GeoJSON source enables Mapbox to perform clustering directly in the renderer.

#code_example[
Clustering configuration is applied at the `Source` level.

```tsx
// resources/js/Components/Shared/Map.tsx
<Source
  id="restaurants"
  type="geojson"
  data={restaurantGeoJson}
  cluster={true}
  clusterMaxZoom={14}
  clusterRadius={50}
>
  {/* layers */}
</Source>
```
]

==== Layer definitions and selected marker styling

Layers are defined in #source_code_link("resources/js/Components/Shared/mapStyles.ts"). The cluster circle changes color and radius based on point counts using a step function. A dedicated layer renders the currently selected restaurant marker as a separate circle with stroke styling. This avoids creating React-managed marker elements for each restaurant.

#code_example[
The selected marker layer filters by restaurant id and uses accent styles.

```ts
// resources/js/Components/Shared/mapStyles.ts
export const getSelectedPointLayer = (theme: MapTheme, selectedId: number | null | undefined) => ({
  id: 'selected-point',
  type: 'circle',
  source: 'restaurants',
  filter: ['==', ['get', 'id'], selectedId || -999],
  paint: {
    'circle-color': theme.brandPrimary,
    'circle-radius': 18,
    'circle-stroke-color': theme.brandPrimaryHover,
    'circle-stroke-width': 3,
  },
});
```
]

==== Click behavior: cluster expansion, marker selection, and pick-location mode

The click interaction supports three distinct behaviors:

- When pick-location mode is enabled, clicking anywhere sets the location.
- Clicking a cluster expands it by retrieving the cluster expansion zoom and animating to that zoom.
- Clicking an unclustered restaurant selects it and opens the popup.

#code_example[
The click handler queries rendered features and expands clusters using `getClusterExpansionZoom`.

```tsx
// resources/js/Components/Shared/Map.tsx
const features = map.queryRenderedFeatures(event.point, {
  layers: ['clusters', 'unclustered-point'],
});

if (features.length > 0) {
  const feature = features[0];
  if (feature.layer?.id === 'clusters') {
    const clusterId = feature.properties?.cluster_id;
    const source = map.getSource('restaurants') as GeoJSONSource;

    source.getClusterExpansionZoom(clusterId, (err, zoom) => {
      if (err || zoom == null) return;
      map.easeTo({
        center: (feature.geometry as Point).coordinates as [number, number],
        zoom: zoom,
      });
    });
  }
}
```
]

==== Cursor feedback for interactive features

The map changes the cursor to a pointer when hovering over interactive layers. This is implemented by checking `event.features` during mouse move and updating the canvas cursor style. This small detail improves discoverability of click targets.

#code_example[
The map sets a pointer cursor when hovering over interactive layers.

```tsx
// resources/js/Components/Shared/Map.tsx
const hasFeatures = (event.features?.length ?? 0) > 0;
map.getCanvas().style.cursor = hasFeatures ? 'pointer' : '';
```
]

==== Popup rendering and details navigation

A selected restaurant is displayed using a Mapbox `Popup` component in #source_code_link("resources/js/Components/Shared/MapPopup.tsx"). The popup includes an optional image, a star rating component, metadata such as opening hours and distance, and a link to the full restaurant details page.

#code_example[
The popup uses an Inertia link to navigate to the restaurant details page.

```tsx
// resources/js/Components/Shared/MapPopup.tsx
<Link
  href={route('restaurants.show', restaurant.id)}
  className="restaurant-view-btn"
>
  View details
</Link>
```
]

This popup is configured not to close on map click automatically, which allows interaction inside the popup without losing state. The close action is explicitly handled by a dedicated button.

=== Geolocation: Mapbox control integration and error recovery

==== Trigger plumbing: calling GeolocateControl from an external UI

The map UI includes a "My Location" button inside the overlay, but the Mapbox geolocation UI is hidden (`showGeolocateControlUi={false}`). To bridge these elements, the map component exposes a trigger registration callback (`registerGeolocateTrigger`), and the `useMapGeolocation` hook registers a function that calls `GeolocateControl.trigger()` when invoked.

#code_example[
The geolocation hook registers a trigger function so that external UI can запуск geolocation without showing the native control UI.

```ts
// resources/js/Hooks/useMapGeolocation.ts
registerGeolocateTrigger(() => {
  if (!geolocateControlRef.current) return false;
  geolocateControlRef.current.trigger();
  return true;
});
```
]

The page-level hook calls this trigger and sets a loading state. If the control is not ready, an explicit error message is shown.

#code_example[
The map page triggers geolocation through the registered function and provides a clear error state if the control is not ready.

```ts
// resources/js/Hooks/useMapPage.ts
const ok = geolocateTriggerRef.current?.();
if (!ok) {
  setLocationError('Geolocation control not ready yet. Refresh and try again.');
  return;
}
setIsGeolocating(true);
```
]

==== Error extraction and user-readable messages

Geolocation errors from Mapbox controls can have varying shapes. The geolocation hook therefore extracts error codes and messages defensively and maps known codes to user-readable instructions.

#code_example[
The geolocation hook extracts error info and maps codes to actionable messages.

```ts
// resources/js/Hooks/useMapGeolocation.ts
const { code, message } = extractGeolocateError(evt);

let errorMessage =
  message ||
  'Unable to get your location. Please check browser/OS location permissions.';

switch (code) {
  case 1:
    errorMessage = 'Location access denied. Allow location permissions to see nearby restaurants.';
    break;
  case 2:
    errorMessage = 'Location information unavailable. Check OS location services or try again.';
    break;
  case 3:
    errorMessage = 'Location request timed out. Try again or disable high accuracy.';
    break;
}
```
]

On success, the map page updates the view state and requests updated restaurants from the backend using the newly obtained coordinates.

=== Summary

The implemented map feature combines backend geospatial filtering, ranking, and session-level location persistence with a frontend visualization built on Mapbox. The backend guarantees validated inputs and predictable payload sizes, computes distance using a model scope with a spatial-function strategy and a Haversine fallback, uses bounding-box prefiltering for performance, and ranks restaurants via a composite score executed in SQL. The frontend composes the map page using a strict separation between page wiring, interaction logic, and presentational partials. It supports fuzzy search filtering without network requests, explicit "search in this area" behavior that limits server roundtrips, and synchronized selection between a clustered map view and a draggable bottom sheet list. Location acquisition is implemented through a hidden Mapbox geolocation control triggered from custom UI, with defensive error handling and clear user feedback through a banner.
