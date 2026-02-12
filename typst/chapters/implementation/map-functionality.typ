#import "../../config.typ": code_example, source_code_link

== Map-Based Restaurant Discovery Implementation <map-implementation>

This section presents the implementation of the customer-facing map feature. The implementation realizes the architectural patterns from @map-architecture using the technologies described in @map-technologies. The backend produces a validated, performance-bounded dataset through the three-phase pipeline, while the React frontend renders an interactive Mapbox map with synchronized controls and a draggable restaurant list.

The principal implementation artifacts are:
- Backend: #source_code_link("app/Http/Controllers/Customer/MapController.php") and #source_code_link("app/Services/GeoService.php")
- Frontend page and logic: #source_code_link("resources/js/Pages/Customer/Map/Index.tsx") and #source_code_link("resources/js/Hooks/useMapPage.ts")
- Map and list components: #source_code_link("resources/js/Components/Shared/Map.tsx") and #source_code_link("resources/js/Pages/Customer/Map/Partials/BottomSheet.tsx")
- Overlay controls: #source_code_link("resources/js/Pages/Customer/Map/Partials/MapOverlay.tsx")

=== Backend implementation: deterministic three-phase processing

The dataset for the map is produced by the `index` action in #source_code_link("app/Http/Controllers/Customer/MapController.php"). The endpoint authorizes access through Laravel policies and validates all optional geospatial query parameters (`lat`, `lng`, `search_lat`, `search_lng`, `radius`). All parameters may be absent, defaulting to a radius of 50 km; `radius = 0` is interpreted as "no range limit." The default center coordinates are set to Warsaw, since that is the most likely location of a user of the application. The following sections present the concrete implementation of each phase from @map-arch-three-phase.

==== Phase A: center coordinate normalization

The controller normalizes coordinates into a single center point using the priority cascade described in @map-arch-three-phase. Only real user location (`lat/lng`) is persisted to the session via #source_code_link("app/Services/GeoService.php"); search coordinates (`search_lat/search_lng`) are deliberately ephemeral, allowing map exploration without overwriting the stored user position.

#code_example[
  The normalization method implements the priority cascade: search center, user location, session (with 24-hour expiry), then Warsaw default.

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

==== Phase B: proximity-first selection with hard radius enforcement

Phase B returns only restaurant IDs within the radius, using a bounding box prefilter (indexed `whereBetween` on latitude and longitude, as described in @map-arch-bounding-box) to reduce the candidate set before the expensive `ST_Distance_Sphere` calculation.

#code_example[
  Phase B enforces the radius as a hard SQL constraint via HAVING, returning only IDs.

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

The `HAVING` clause enforces the radius determinism guarantee (@map-arch-guarantees): only rows satisfying `distance_km <= radius` remain candidates before the limit is applied. When `radius = 0`, the clause is omitted and the 250 nearest restaurants globally are returned. If Phase B yields an empty collection, the controller short-circuits Phase C and returns an empty dataset immediately.

==== Phase C: quality-based ranking in SQL

Phase C hydrates full restaurant models and computes composite quality scores in a single SQL pass using derived tables. Review counts are aggregated once, distance is computed once, and three weighted signals produce the composite score: rating (0--50 points), review count (0--30 points, logarithmic scale), and proximity (0--20 points, linear decay). The scored subquery is then joined back to `restaurants` for Eloquent hydration.

#code_example[
  The final query joins scores for Eloquent hydration, eager-loads only required relations, and orders by composite score with distance as tiebreaker.

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

The `$scoredRestaurants` subquery is constructed using Laravel's `fromSub` and `leftJoinSub` query builder methods, following the single-pass computation principle from @map-arch-query-optimization. Favorite detection is included conditionally for authenticated users via a `LEFT JOIN`. The controller eager-loads only the `images` relation, deliberately excluding the full menu hierarchy to minimize response payload; detailed menu data is loaded on-demand when users navigate to individual restaurant pages.

=== Frontend implementation: orchestration, state, and synchronized UI

The frontend implements the component hierarchy from @map-arch-component-hierarchy. The `MapIndex` page component composes `MapOverlay`, `Map`, and `BottomSheet`, passing state and handlers from the `useMapPage` hook without embedding logic in JSX.

==== Page state management and data flow

The `useMapPage` hook manages search query state (Fuse-based filtering), view state (camera position), selection state (active restaurant), geolocation flow, and Inertia navigation for dataset refresh. Following the data flow pattern from @map-arch-data-flow, filter changes trigger partial reloads that fetch only `restaurants` and `filters` while preserving UI state.

#code_example[
  Reload operations fetch only `restaurants` and `filters`, preserving camera position and scroll.

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

The "Search here" button uses the same partial reload pattern but sends `search_lat/search_lng` from the current camera center while preserving existing user coordinates, implementing the session isolation guarantee from @map-arch-guarantees. It appears when the camera moves more than ~0.01 degrees (~1 km) from the initial center. Geolocation is triggered through the callback registration pattern described in @map-arch-geolocation-pattern, with error handling that maps browser geolocation error codes to actionable user messages.

==== Overlay controls and radius selection

The overlay provides three complementary location methods: "My Location" (geolocation), "Enter Coords" (manual input with client-side validation), and "Pick on Map" (click-to-set mode on the map canvas). Radius selection uses a commit-on-release strategy: the slider updates its local display value continuously for smooth interaction, but triggers the backend reload only on pointer release, preventing intermediate values from flooding the server. A "No range" endpoint maps to `radius = 0`.

==== Map component: clustering and multi-modal interaction

The map component renders restaurant markers as a GeoJSON source with clustering enabled for readability at low zoom levels. The click handler operates in two modes: in pick mode, any click sets user location and exits the mode; in normal mode, cluster clicks zoom to the expansion level, point clicks select a restaurant and open the popup, and empty clicks clear the selection.

#code_example[
  The click handler switches behavior based on location-picking mode while preserving clustering and selection semantics.

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

When a restaurant is selected, the map animates the camera using `flyTo` with UI-aware padding that accounts for the overlay height and expanded bottom sheet, keeping the selected point visible within the unobstructed viewport area.

==== Bottom sheet: pointer-driven drag with snap behavior

The restaurant list is implemented as a draggable bottom sheet using the Pointer Events API @W3CPointerEvents with pointer capture, providing consistent behavior across mouse and touch devices. The drag mechanism uses pointer capture on press (`setPointerCapture`), a movement threshold to distinguish drags from clicks, and snap-on-release to collapsed or expanded state based on position.

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

Selection synchronization between the map and the list uses transition-aware timing: the bottom sheet waits for CSS transitions to complete (with a timeout fallback) before measuring card positions and performing a smooth scroll to center the selected restaurant, preventing layout measurement errors during height animations.

=== Summary

The map implementation realizes the three-phase SQL pipeline from @map-architecture through distinct controller methods with hard radius enforcement, uses Inertia partial reloads for responsive filter updates without full page refreshes, and coordinates multi-modal map interactions (clustering, pick mode, selection) with a pointer-driven bottom sheet through transition-aware state synchronization.
