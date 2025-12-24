import {
  useCallback,
  useEffect,
  useLayoutEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import { Head, router } from '@inertiajs/react';
import MapLayout from '@/Layouts/MapLayout';
import Map from '@/Components/Shared/Map';
import SearchInput from '@/Components/UI/SearchInput';
import RestaurantCard from '@/Components/Shared/RestaurantCard';
import { useSearch } from '@/Hooks/useSearch';
import { Restaurant, MapMarker } from '@/types/models';
import { PageProps } from '@/types';
import type { IFuseOptions } from 'fuse.js';

const SEARCH_OPTIONS: IFuseOptions<Restaurant> = {
  keys: [
    { name: 'name', weight: 2 },
    { name: 'description', weight: 1.5 },
    { name: 'food_types.name', weight: 1 },
    { name: 'food_types.menu_items.name', weight: 0.5 },
  ],
};

const EMPTY_KEYS: (keyof Restaurant)[] = [];

const COLLAPSED_PX = 105; // Minimal height - handle touches bottom nav
const EXPANDED_MAX_PX = 520; // Max expanded height
const EXPANDED_VH = 0.45; // 45vh

const MIN_RADIUS = 1;
const MAX_RADIUS = 50;
const NO_RANGE_SLIDER_VALUE = 51; // rightmost = "No range"

// Convert backend radius -> slider value
const radiusToSlider = (radius: number) => {
  if (!radius || radius <= 0) return NO_RANGE_SLIDER_VALUE;
  return Math.min(MAX_RADIUS, Math.max(MIN_RADIUS, radius));
};

// Convert slider value -> backend radius
const sliderToRadius = (sliderValue: number) => {
  return sliderValue === NO_RANGE_SLIDER_VALUE ? 0 : sliderValue;
};

interface MapIndexProps extends PageProps {
  restaurants: Restaurant[];
  filters: {
    lat: number | null;
    lng: number | null;
    radius: number;
  };
  mapboxPublicKey?: string;
}

const getLatLng = (restaurant: Restaurant): [number, number] | null => {
  if (
    restaurant.latitude === null ||
    restaurant.longitude === null ||
    restaurant.latitude === undefined ||
    restaurant.longitude === undefined
  ) {
    return null;
  }
  return [restaurant.latitude, restaurant.longitude];
};

export default function MapIndex({
  restaurants,
  filters,
  mapboxPublicKey,
}: MapIndexProps) {
  const {
    query,
    setQuery,
    filteredItems: filteredRestaurants,
  } = useSearch(restaurants, EMPTY_KEYS, SEARCH_OPTIONS);

  const [locationError, setLocationError] = useState<string | null>(null);

  // Radius slider state (UI value that maps to backend radius)
  const [radiusSliderValue, setRadiusSliderValue] = useState<number>(() =>
    radiusToSlider(filters.radius ?? 50),
  );

  // keep slider in sync if filters.radius changes after navigation
  useEffect(() => {
    setRadiusSliderValue(radiusToSlider(filters.radius ?? 50));
  }, [filters.radius]);

  // Derive radius for backend requests
  const radiusKm = useMemo(
    () => sliderToRadius(radiusSliderValue),
    [radiusSliderValue],
  );

  // Computed values for slider
  const radiusLabel =
    radiusSliderValue === NO_RANGE_SLIDER_VALUE
      ? 'No range'
      : `${radiusSliderValue} km`;

  // Selection state for unified map/list interaction
  const [selectedRestaurantId, setSelectedRestaurantId] = useState<
    number | null
  >(null);

  // Store refs for scrolling list items into view
  const cardRefs = useRef<Record<number, HTMLDivElement | null>>({});

  // Sheet collapsible state
  const sheetContentRef = useRef<HTMLDivElement | null>(null);
  const [expandedPx, setExpandedPx] = useState(() =>
    typeof window === 'undefined'
      ? EXPANDED_MAX_PX
      : Math.min(Math.round(window.innerHeight * EXPANDED_VH), EXPANDED_MAX_PX),
  );
  const [sheetHeight, setSheetHeight] = useState<number>(COLLAPSED_PX);
  const [isDragging, setIsDragging] = useState(false);

  // Prevent click-toggle after a drag
  const dragMovedRef = useRef(false);

  // Controlled viewState for the map
  const [viewState, setViewState] = useState({
    longitude: 21.0122, // Warsaw, Poland
    latitude: 52.2297,
    zoom: 13,
  });

  // Loading state for geolocation requests
  const [isGeolocating, setIsGeolocating] = useState(false);

  // Geolocation trigger from Mapbox control
  const geolocateTriggerRef = useRef<null | (() => boolean)>(null);

  // Stable callback for registering geolocate trigger
  const registerGeolocateTrigger = useCallback((fn: (() => boolean) | null) => {
    geolocateTriggerRef.current = fn;
  }, []);

  // Helper to reload map with new filters
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

  // Manual location picking state
  const [isPickingLocation, setIsPickingLocation] = useState(false);
  const [manualOpen, setManualOpen] = useState(false);
  const [manualLat, setManualLat] = useState<string>('');
  const [manualLng, setManualLng] = useState<string>('');

  // Collapsible overlay states (collapsed by default)
  const [controlsOpen, setControlsOpen] = useState(false);
  const [radiusOpen, setRadiusOpen] = useState(false);

  // If the controls panel is closed, also close manual input + pick mode
  useEffect(() => {
    if (!controlsOpen) {
      setManualOpen(false);
      setIsPickingLocation(false);
    }
  }, [controlsOpen]);

  const collapseAllOverlay = () => {
    setControlsOpen(false);
    setRadiusOpen(false);
    setManualOpen(false);
    setIsPickingLocation(false);
    setLocationError(null);
  };

  // Validate API key on mount
  useEffect(() => {
    if (!mapboxPublicKey) {
      console.error('MAPBOX_PUBLIC_KEY is not configured in .env file');
    } else if (!mapboxPublicKey.startsWith('pk.')) {
      console.error(
        'MAPBOX_PUBLIC_KEY must be a public key starting with "pk.", not a secret key starting with "sk."',
      );
    }
  }, [mapboxPublicKey]);

  // Set initial center based on user location (from filters) or first restaurant
  useEffect(() => {
    if (filters.lat !== null && filters.lng !== null) {
      setViewState((prev) => ({
        ...prev,
        longitude: filters.lng!,
        latitude: filters.lat!,
      }));
    } else if (restaurants.length > 0) {
      const coords = getLatLng(restaurants[0]);
      if (coords) {
        setViewState((prev) => ({
          ...prev,
          longitude: coords[1],
          latitude: coords[0],
        }));
      }
    }
  }, [filters.lat, filters.lng, restaurants]);

  // Handle window resize for sheet height
  useEffect(() => {
    const onResize = () => {
      const nextExpanded = Math.min(
        Math.round(window.innerHeight * EXPANDED_VH),
        EXPANDED_MAX_PX,
      );
      setExpandedPx(nextExpanded);

      // Clamp current height into new bounds
      setSheetHeight((h) => Math.max(COLLAPSED_PX, Math.min(h, nextExpanded)));
    };

    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

  const isExpanded = sheetHeight > (COLLAPSED_PX + expandedPx) / 2;

  const toggleSheet = () => {
    // Ignore click if we just dragged
    if (dragMovedRef.current) {
      dragMovedRef.current = false;
      return;
    }
    setSheetHeight((h) => (h <= COLLAPSED_PX + 2 ? expandedPx : COLLAPSED_PX));
  };

  // Calculate offset for transform animation (keep cards at natural size)
  const sheetOffsetPx = Math.max(0, expandedPx - sheetHeight);

  const onHandlePointerDown = (e: React.PointerEvent<HTMLButtonElement>) => {
    e.preventDefault(); // helps on some browsers to avoid accidental scroll/tap behaviors

    const pointerId = e.pointerId;
    e.currentTarget.setPointerCapture(pointerId); // keep receiving events

    dragMovedRef.current = false;

    const startY = e.clientY;
    const startH = sheetHeight;

    setIsDragging(true);

    const onMove = (ev: PointerEvent) => {
      if (ev.pointerId !== pointerId) return; // IMPORTANT: only respond to the active pointer

      const dy = ev.clientY - startY; // Dragging down => dy positive => height decreases
      const next = Math.max(COLLAPSED_PX, Math.min(expandedPx, startH - dy));

      if (Math.abs(dy) > 6) dragMovedRef.current = true;
      setSheetHeight(next);
    };

    const onUp = (ev?: PointerEvent) => {
      if (ev && ev.pointerId !== pointerId) return; // IMPORTANT: only respond to the active pointer

      setIsDragging(false);

      // Snap to nearest state
      setSheetHeight((h) =>
        h > (COLLAPSED_PX + expandedPx) / 2 ? expandedPx : COLLAPSED_PX,
      );

      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerup', onUp as EventListener);
      window.removeEventListener('pointercancel', onUp as EventListener);
    };

    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp as EventListener);
    window.addEventListener('pointercancel', onUp as EventListener);
  };

  // Trigger geolocation via Mapbox control
  const triggerGeolocate = () => {
    const ok = geolocateTriggerRef.current?.();
    if (!ok) {
      setLocationError(
        'Geolocation control not ready yet. Refresh and try again.',
      );
      return;
    }
    setIsGeolocating(true);
  };

  // Commit radius change (called on pointer-up / key-up)
  const commitRadius = useCallback(
    (e: React.SyntheticEvent<HTMLInputElement>) => {
      if (filters.lat == null || filters.lng == null) return;

      const sliderValue = Number((e.currentTarget as HTMLInputElement).value);
      const radius = sliderToRadius(sliderValue);

      reloadMap(filters.lat, filters.lng, radius);
    },
    [filters.lat, filters.lng, reloadMap],
  );

  // Apply manual coordinates
  const applyManualCoords = () => {
    const lat = Number(manualLat);
    const lng = Number(manualLng);

    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      setLocationError('Please enter valid numeric latitude/longitude.');
      return;
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      setLocationError(
        'Latitude must be -90..90 and longitude must be -180..180.',
      );
      return;
    }

    setManualOpen(false);
    setIsPickingLocation(false);
    setLocationError(null);
    handleMapGeolocate(lat, lng);
  };

  // Handle geolocation success
  const handleMapGeolocate = (latitude: number, longitude: number) => {
    setLocationError(null);
    setViewState((prev) => ({ ...prev, longitude, latitude, zoom: 14 }));

    // Stop loading
    setIsGeolocating(false);

    reloadMap(latitude, longitude, radiusKm);
  };

  // Handle geolocation errors
  const handleGeolocateError = (error: string) => {
    setIsGeolocating(false);
    setLocationError(error);
  };

  // When user picks on map
  const handlePickLocation = (lat: number, lng: number) => {
    setIsPickingLocation(false);
    setLocationError(null);
    handleMapGeolocate(lat, lng);
  };

  // Unified selection handler for map/list interaction
  const selectRestaurant = (id: number | null) => {
    setSelectedRestaurantId((prev) => (prev === id ? null : id));
  };

  useLayoutEffect(() => {
    if (selectedRestaurantId == null) return;

    let cancelled = false;

    const id = selectedRestaurantId;
    const el = cardRefs.current[id];
    const container = sheetContentRef.current;

    if (!el || !container) return;

    // +-------------+
    // | STEP 1: WAIT |
    // +-------------+

    // Promise that resolves after the CSS transition end
    const waitForTransition = new Promise<void>((resolve) => {
      const handler = (event: TransitionEvent) => {
        // Only respond to padding/min-height/gap transitions
        if (
          event.propertyName.startsWith('padding') ||
          event.propertyName === 'min-height' ||
          event.propertyName === 'gap'
        ) {
          el.removeEventListener('transitionend', handler);
          if (!cancelled) resolve();
        }
      };
      el.addEventListener('transitionend', handler);

      // Fallback timeout (in case no transitionend fires for some reason)
      const timeoutId = setTimeout(() => {
        el.removeEventListener('transitionend', handler);
        if (!cancelled) resolve();
      }, 300); // slightly longer than our CSS duration (250ms)

      return () => {
        cancelled = true;
        clearTimeout(timeoutId);
        el.removeEventListener('transitionend', handler);
      };
    });

    waitForTransition.then(() => {
      if (cancelled) return;

      // +------------------------+
      // | STEP 2: SCROLL TO VIEW |
      // +------------------------+

      const containerRect = container.getBoundingClientRect();
      const elRect = el.getBoundingClientRect();

      const currentScroll = container.scrollTop;
      const offsetTop = elRect.top - containerRect.top;

      const targetScroll =
        currentScroll +
        offsetTop -
        (containerRect.height / 2 - elRect.height / 2);

      const clamped = Math.max(
        0,
        Math.min(targetScroll, container.scrollHeight - container.clientHeight),
      );

      container.scrollTo({
        top: clamped,
        behavior: 'smooth',
      });
    });

    return () => {
      cancelled = true;
    };
  }, [selectedRestaurantId]);

  // Restaurants already have distance calculated by backend when filters.lat/lng are present
  // Just use filteredRestaurants directly (Fuse search on the already-nearby list)

  const mapMarkers = useMemo(() => {
    const restaurantMarkers = filteredRestaurants
      .map((r) => {
        const coords = getLatLng(r);
        if (!coords) return null;

        const primaryImage =
          r.images?.find((img) => img.is_primary_for_restaurant) ??
          r.images?.[0];

        return {
          id: r.id,
          lat: coords[0],
          lng: coords[1],
          name: r.name,
          address: r.address,
          openingHours: r.opening_hours,
          rating: r.rating,
          distanceKm: r.distance ?? null,
          imageUrl: primaryImage?.url ?? null,
        };
      })
      .filter(Boolean) as MapMarker[];

    // user marker unchanged
    const userMarker =
      filters.lat !== null && filters.lng !== null
        ? [{ id: -1, lat: filters.lat, lng: filters.lng, name: 'You are here' }]
        : [];

    return [...restaurantMarkers, ...userMarker];
  }, [filteredRestaurants, filters.lat, filters.lng]);

  return (
    <MapLayout>
      <Head title="Restaurant Map" />
      <div className="map-page">
        {locationError && (
          <div className="location-error-banner">
            <div style={{ flex: 1 }}>
              <p className="location-error-message">{locationError}</p>
            </div>

            <div className="location-error-actions">
              <button
                className="location-error-native"
                disabled={isGeolocating}
                onClick={triggerGeolocate}
                aria-label="Try GPS"
              >
                {isGeolocating ? 'Getting Location...' : 'Try GPS'}
              </button>

              <button
                className="location-error-dismiss"
                onClick={() => {
                  setLocationError(null);
                  setManualOpen(false);
                  setIsPickingLocation(false);
                }}
                aria-label="Dismiss location error"
              >
                ×
              </button>
            </div>
          </div>
        )}
        <div className="map-container-box">
          <div className="map-overlay">
            <div className="map-controls-card">
              <div className="map-controls-header">
                <SearchInput
                  value={query}
                  onChange={setQuery}
                  placeholder="Search restaurants..."
                  className="map-search-input map-search-input--transparent"
                />

                <div className="map-controls-header-actions">
                  {/* Radius toggle only makes sense when we actually have coords */}
                  {filters.lat !== null && filters.lng !== null && (
                    <button
                      type="button"
                      className={`map-overlay-toggle ${radiusOpen ? 'is-active' : ''}`}
                      onClick={() => setRadiusOpen((v) => !v)}
                      aria-label={
                        radiusOpen
                          ? 'Hide radius options'
                          : 'Show radius options'
                      }
                      aria-expanded={radiusOpen}
                      aria-controls="map-radius-panel"
                    >
                      📏
                    </button>
                  )}

                  <button
                    type="button"
                    className={`map-overlay-toggle ${controlsOpen ? 'is-active' : ''}`}
                    onClick={() => setControlsOpen((v) => !v)}
                    aria-label={
                      controlsOpen ? 'Hide map controls' : 'Show map controls'
                    }
                    aria-expanded={controlsOpen}
                    aria-controls="map-controls-panel"
                  >
                    ⚙️
                  </button>

                  {(controlsOpen || radiusOpen) && (
                    <button
                      type="button"
                      className="map-overlay-toggle map-overlay-toggle--close"
                      onClick={collapseAllOverlay}
                      aria-label="Collapse overlay"
                    >
                      ✕
                    </button>
                  )}
                </div>
              </div>

              {/* Collapsible map controls panel */}
              <div
                id="map-controls-panel"
                className={`map-collapsible ${controlsOpen ? 'is-open' : ''}`}
              >
                <div className="map-collapsible__inner">
                  <div className="map-location-controls">
                    <button
                      className="location-control-btn"
                      disabled={isGeolocating}
                      onClick={triggerGeolocate}
                      aria-label="Find my location"
                    >
                      {isGeolocating ? 'Locating...' : '📍 My Location'}
                    </button>

                    <button
                      className="location-control-btn"
                      onClick={() => {
                        setManualOpen((v) => !v);
                        setIsPickingLocation(false);
                      }}
                      aria-label="Enter coordinates"
                    >
                      📝 Enter Coords
                    </button>

                    <button
                      className="location-control-btn"
                      onClick={() => {
                        setIsPickingLocation((v) => !v);
                        setManualOpen(false);
                      }}
                      aria-label="Pick location on map"
                    >
                      🖱️ Pick on Map
                    </button>
                  </div>

                  {manualOpen && (
                    <div className="map-manual-input">
                      <input
                        type="number"
                        step="0.000001"
                        placeholder="Latitude (e.g. 52.2297)"
                        value={manualLat}
                        onChange={(e) => setManualLat(e.target.value)}
                      />
                      <input
                        type="number"
                        step="0.000001"
                        placeholder="Longitude (e.g. 21.0122)"
                        value={manualLng}
                        onChange={(e) => setManualLng(e.target.value)}
                      />
                      <button onClick={applyManualCoords}>Apply</button>
                      <button onClick={() => setManualOpen(false)}>×</button>
                    </div>
                  )}

                  {isPickingLocation && (
                    <div className="map-pick-instruction">
                      <small>Click on the map to set your location</small>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Collapsible radius panel (separate from controls card) */}
            {filters.lat !== null && filters.lng !== null && (
              <div
                id="map-radius-panel"
                className={`map-collapsible ${radiusOpen ? 'is-open' : ''}`}
              >
                <div className="map-collapsible__inner">
                  <div className="map-radius">
                    <div className="map-radius__top">
                      <span className="map-radius__label">Radius</span>
                      <span className="map-radius__value">{radiusLabel}</span>
                    </div>

                    <div className="map-radius__slider">
                      <input
                        className="radius-slider"
                        type="range"
                        min={MIN_RADIUS}
                        max={NO_RANGE_SLIDER_VALUE}
                        step={1}
                        value={radiusSliderValue}
                        onChange={(e) =>
                          setRadiusSliderValue(Number(e.target.value))
                        }
                        onMouseUp={commitRadius}
                        onTouchEnd={commitRadius}
                        onKeyUp={(e) => {
                          if (
                            e.key === 'ArrowLeft' ||
                            e.key === 'ArrowRight' ||
                            e.key === 'ArrowUp' ||
                            e.key === 'ArrowDown' ||
                            e.key === 'Home' ||
                            e.key === 'End'
                          ) {
                            commitRadius(e);
                          }
                        }}
                        style={
                          {
                            ['--pct' as any]: `${
                              ((radiusSliderValue - MIN_RADIUS) /
                                (NO_RANGE_SLIDER_VALUE - MIN_RADIUS)) *
                              100
                            }%`,
                          } as React.CSSProperties
                        }
                        aria-label="Radius"
                        aria-valuetext={
                          radiusSliderValue === NO_RANGE_SLIDER_VALUE
                            ? 'No range'
                            : `${radiusSliderValue} kilometers`
                        }
                      />

                      <div className="radius-ruler" aria-hidden="true" />

                      <div className="radius-ends" aria-hidden="true">
                        <span>{MIN_RADIUS}</span>
                        <span>25</span>
                        <span>No range</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
          <Map
            viewState={viewState}
            onMove={setViewState}
            markers={mapMarkers}
            mapboxAccessToken={mapboxPublicKey || ''}
            onGeolocate={handleMapGeolocate}
            onGeolocateError={handleGeolocateError}
            enableGeolocation={true}
            trackUserLocation={false}
            selectedRestaurantId={selectedRestaurantId}
            onSelectRestaurant={selectRestaurant}
            registerGeolocateTrigger={registerGeolocateTrigger}
            isPickingLocation={isPickingLocation}
            onPickLocation={handlePickLocation}
            showGeolocateControlUi={false}
          />
          <div
            className={`map-bottom-sheet ${isDragging ? 'is-dragging' : ''} ${isExpanded ? 'is-expanded' : 'is-collapsed'}`}
            style={
              {
                height: `${expandedPx}px`, // constant physical height
                ['--sheet-offset' as any]: `${sheetOffsetPx}px`, // slide down to "collapse"
              } as React.CSSProperties
            }
          >
            <button
              type="button"
              className="sheet-handle"
              aria-label={
                isExpanded
                  ? 'Collapse restaurant list'
                  : 'Expand restaurant list'
              }
              aria-expanded={isExpanded}
              aria-controls="restaurants-sheet"
              onClick={toggleSheet}
              onPointerDown={onHandlePointerDown}
            >
              <span className="sheet-handle-bar" aria-hidden="true" />
            </button>

            <div
              id="restaurants-sheet"
              className="sheet-content"
              ref={sheetContentRef}
            >
              {filteredRestaurants.map((restaurant) => (
                <RestaurantCard
                  key={restaurant.id}
                  restaurant={restaurant}
                  selected={restaurant.id === selectedRestaurantId}
                  onSelect={() => selectRestaurant(restaurant.id)}
                  containerRef={(el) => (cardRefs.current[restaurant.id] = el)}
                />
              ))}
            </div>
          </div>
        </div>
      </div>
    </MapLayout>
  );
}
