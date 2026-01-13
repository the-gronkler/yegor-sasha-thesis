import * as React from 'react';
import Map, {
  Marker,
  GeolocateControl,
  NavigationControl,
  Source,
  Layer,
} from 'react-map-gl/mapbox';
import { UserCircleIcon } from '@heroicons/react/24/solid';
import 'mapbox-gl/dist/mapbox-gl.css';
import type { MapRef } from 'react-map-gl/mapbox';
import type { MapLayerMouseEvent } from 'mapbox-gl';
import type { RestaurantMapCard } from '@/types/models';
import { createTheme } from '@/Utils/css';
import MapPopup from './MapPopup';
import {
  getClusterLayer,
  getClusterCountLayer,
  getSelectedPointLayer,
  getUnclusteredPointLayer,
  MapTheme,
} from './mapStyles';
import { useMapGeolocation } from '@/Hooks/useMapGeolocation';

interface Props {
  viewState: {
    longitude: number;
    latitude: number;
    zoom: number;
  };
  onMove: (viewState: {
    longitude: number;
    latitude: number;
    zoom: number;
  }) => void;
  tilesetId?: string; // Mapbox tileset URL (e.g., mapbox://username.tileset-id)
  className?: string;
  mapboxAccessToken: string;
  onGeolocate?: (latitude: number, longitude: number) => void;
  onGeolocateError?: (error: string) => void;
  enableGeolocation?: boolean;
  trackUserLocation?: boolean;
  selectedRestaurantId?: number | null;
  onSelectRestaurant?: (id: number | null, opts?: { scroll?: boolean }) => void;
  registerGeolocateTrigger?: (fn: (() => boolean) | null) => void;
  isPickingLocation?: boolean;
  onPickLocation?: (lat: number, lng: number) => void;
  showGeolocateControlUi?: boolean;
  userGeo?: { lat: number; lng: number } | null;
}

export default function MapComponent({
  viewState,
  onMove,
  tilesetId,
  className = '',
  mapboxAccessToken,
  onGeolocate,
  onGeolocateError,
  enableGeolocation = true,
  trackUserLocation = false,
  selectedRestaurantId,
  onSelectRestaurant,
  registerGeolocateTrigger,
  isPickingLocation,
  onPickLocation,
  showGeolocateControlUi = true,
  userGeo,
}: Props) {
  const mapRef = React.useRef<MapRef>(null);

  const { geolocateControlRef, handleGeolocate, handleGeolocateError } =
    useMapGeolocation({
      onGeolocate,
      onGeolocateError,
      registerGeolocateTrigger,
    });

  // Theme constants for consistent colors (synced with CSS)
  const THEME = React.useMemo(() => {
    const themeVars = [
      { key: 'brandPrimary', cssVar: '--brand-primary' },
      { key: 'brandPrimaryHover', cssVar: '--brand-primary-hover' },
      { key: 'accentWarm', cssVar: '--accent-warm' },
      { key: 'textInverse', cssVar: '--text-inverse' },
    ] as const;

    return createTheme<MapTheme>(themeVars);
  }, []);

  // State for selected restaurant data (fetched from API)
  const [selectedRestaurant, setSelectedRestaurant] =
    React.useState<RestaurantMapCard | null>(null);
  const [isLoadingRestaurant, setIsLoadingRestaurant] = React.useState(false);

  // Cache for fetched restaurant data (avoid refetching on repeated clicks)
  const restaurantCache = React.useRef<
    globalThis.Map<number, RestaurantMapCard>
  >(new globalThis.Map());

  // AbortController for cancelling in-flight requests
  const abortControllerRef = React.useRef<AbortController | null>(null);

  // Fetch restaurant details from API
  const fetchRestaurantDetails = React.useCallback(
    async (restaurantId: number, signal: AbortSignal) => {
      // Check cache first
      const cached = restaurantCache.current.get(restaurantId);
      if (cached) {
        setSelectedRestaurant(cached);
        return cached;
      }

      setIsLoadingRestaurant(true);
      try {
        const response = await fetch(
          `/api/restaurants/${restaurantId}/map-card`,
          { signal },
        );

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }

        const data: RestaurantMapCard = await response.json();

        // Cache the result
        restaurantCache.current.set(restaurantId, data);
        setSelectedRestaurant(data);

        return data;
      } catch (error) {
        if (error instanceof Error && error.name === 'AbortError') {
          // Request was cancelled, ignore
          return null;
        }
        console.error('Failed to fetch restaurant details:', error);
        setSelectedRestaurant(null);
        return null;
      } finally {
        setIsLoadingRestaurant(false);
      }
    },
    [],
  );

  // Handle map click for clustering and location picking
  const handleMapClick = React.useCallback(
    (event: MapLayerMouseEvent) => {
      // Manual pick mode: click anywhere to set user location
      if (isPickingLocation) {
        const { lng, lat } = event.lngLat;
        onPickLocation?.(lat, lng);
        return;
      }

      const map = mapRef.current?.getMap();
      if (!map) return;

      const features = event.features;

      if (features && features.length > 0) {
        const feature = features[0];

        // Handle cluster click (zoom into cluster)
        if (
          feature.properties?.cluster &&
          feature.source === 'restaurants' &&
          feature.geometry.type === 'Point'
        ) {
          // For vector sources, we can't use getClusterExpansionZoom
          // Instead, just zoom in to the cluster location
          const coordinates = feature.geometry.coordinates as [number, number];
          map.easeTo({
            center: coordinates,
            zoom: Math.min(map.getZoom() + 2, 18),
            duration: 500,
          });
        }
        // Handle unclustered point click (fetch restaurant details)
        else if (
          !feature.properties?.cluster &&
          feature.source === 'restaurants'
        ) {
          // Vector tile properties are often strings - convert to number
          const raw = feature.properties?.restaurant_id;
          const restaurantId = raw != null ? Number(raw) : null;

          if (restaurantId && Number.isFinite(restaurantId)) {
            onSelectRestaurant?.(restaurantId);

            // Cancel any in-flight request
            if (abortControllerRef.current) {
              abortControllerRef.current.abort();
            }

            // Create new AbortController for this request
            const abortController = new AbortController();
            abortControllerRef.current = abortController;

            // Fetch restaurant details
            fetchRestaurantDetails(restaurantId, abortController.signal);
          }
        }
      } else {
        // Clicked on empty space - deselect
        onSelectRestaurant?.(null);
        setSelectedRestaurant(null);
      }
    },
    [
      isPickingLocation,
      onPickLocation,
      onSelectRestaurant,
      fetchRestaurantDetails,
    ],
  );

  // Animate to selected restaurant
  React.useEffect(() => {
    if (!selectedRestaurant) return;

    const map = mapRef.current?.getMap();
    if (!map) return;

    // Smoothly center + zoom to selected restaurant
    map.flyTo({
      center: [selectedRestaurant.longitude, selectedRestaurant.latitude],
      zoom: Math.max(viewState.zoom, 14),
      duration: 900,
      essential: true,
      padding: { top: 240, bottom: 280, left: 40, right: 40 },
    });
  }, [selectedRestaurant?.id]);

  // Cleanup abort controller on unmount
  React.useEffect(() => {
    return () => {
      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
      }
    };
  }, []);

  // Handle map mouse move for cursor changes
  const handleMapMouseMove = React.useCallback((event: MapLayerMouseEvent) => {
    const map = mapRef.current?.getMap();
    if (!map) return;

    // When interactiveLayerIds is set, event.features contains hovered features
    const hasFeatures = (event.features?.length ?? 0) > 0;
    map.getCanvas().style.cursor = hasFeatures ? 'pointer' : '';
  }, []);

  // Validate API key
  if (!mapboxAccessToken) {
    return (
      <div className={`map-wrapper map-error ${className}`}>
        <div className="map-error-content">
          <h3 className="map-error-title">Map Error</h3>
          <p className="map-error-message">Mapbox API key is not configured.</p>
          <p className="map-error-hint">
            Please set MAPBOX_PUBLIC_KEY in your .env file.
          </p>
        </div>
      </div>
    );
  }

  if (!mapboxAccessToken.startsWith('pk.')) {
    return (
      <div className={`map-wrapper map-error ${className}`}>
        <div className="map-error-content">
          <h3 className="map-error-title">Map Error</h3>
          <p className="map-error-message">Invalid Mapbox API key type.</p>
          <p className="map-error-hint">
            Public keys must start with "pk.", not "sk."
          </p>
          <p className="map-error-hint">
            Secret keys cannot be used in the frontend.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className={`map-wrapper ${className}`}>
      <Map
        {...viewState}
        onMove={(evt) => onMove(evt.viewState)}
        // TODO: select style for the map in general, beyond the scope of the current PR since its big already
        mapStyle="mapbox://styles/mapbox/dark-v10"
        mapboxAccessToken={mapboxAccessToken}
        style={{ height: '100%', width: '100%' }}
        projection="globe"
        interactiveLayerIds={
          isPickingLocation ? undefined : ['clusters', 'unclustered-point']
        }
        onLoad={(e) => {
          const map = e.target; // Mapbox GL JS map instance

          map.setFog({
            // make "space" opaque so DOM behind can't show through
            'space-color': '#0b1020',
            'star-intensity': 0.25,
            'horizon-blend': 0.15,
          });
        }}
        ref={mapRef}
        onClick={handleMapClick}
        onMouseMove={handleMapMouseMove}
      >
        {/* Navigation Controls (Zoom +/-, Compass) */}
        <NavigationControl position="top-right" />

        {/* Geolocation Control - Native Mapbox UI for user location */}
        {enableGeolocation && (
          <GeolocateControl
            ref={geolocateControlRef}
            position="top-right"
            style={showGeolocateControlUi ? undefined : { display: 'none' }}
            positionOptions={{
              // More forgiving defaults (timeouts are common on Windows laptops)
              enableHighAccuracy: false,
              timeout: 20000,
              maximumAge: 600000, // 10 minutes
            }}
            trackUserLocation={trackUserLocation}
            showUserHeading={trackUserLocation}
            showUserLocation={true}
            onGeolocate={handleGeolocate}
            onError={handleGeolocateError}
          />
        )}

        {/* User Marker (if userGeo is provided) */}
        {userGeo && (
          <Marker
            longitude={userGeo.lng}
            latitude={userGeo.lat}
            anchor="bottom"
          >
            <UserCircleIcon className="map-marker map-marker-user" />
          </Marker>
        )}

        {/* Restaurant Popup */}
        {selectedRestaurant && !isLoadingRestaurant && (
          <MapPopup
            restaurant={{
              id: selectedRestaurant.id,
              name: selectedRestaurant.name,
              lat: selectedRestaurant.latitude,
              lng: selectedRestaurant.longitude,
              address: selectedRestaurant.address,
              openingHours: selectedRestaurant.opening_hours,
              rating: selectedRestaurant.rating,
              distanceKm: selectedRestaurant.distance
                ? parseFloat(selectedRestaurant.distance)
                : null,
              imageUrl: selectedRestaurant.primary_image_url ?? undefined,
            }}
            onClose={() => {
              onSelectRestaurant?.(null);
              setSelectedRestaurant(null);
            }}
          />
        )}

        {/* Vector Tile Source - Restaurant clusters and points */}
        {tilesetId && (
          <Source id="restaurants" type="vector" url={tilesetId}>
            <Layer {...getClusterLayer(THEME)} />
            <Layer {...getClusterCountLayer()} />
            <Layer {...getSelectedPointLayer(THEME, selectedRestaurantId)} />
            <Layer {...getUnclusteredPointLayer(THEME)} />
          </Source>
        )}
      </Map>
    </div>
  );
}
