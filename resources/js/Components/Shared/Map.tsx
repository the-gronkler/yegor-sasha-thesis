import * as React from 'react';
import { Link } from '@inertiajs/react';
import Map, {
  Marker,
  Popup,
  GeolocateControl,
  NavigationControl,
  Source,
  Layer,
  type GeolocateResultEvent,
} from 'react-map-gl/mapbox';
import type mapboxgl from 'mapbox-gl';
import { UserCircleIcon } from '@heroicons/react/24/solid';
import 'mapbox-gl/dist/mapbox-gl.css';
import StarRating from '@/Components/Shared/StarRating';
import { MapMarker } from '@/types/models';
import { createTheme } from '@/Utils/css';

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
  markers?: MapMarker[];
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
}

export default function MapComponent({
  viewState,
  onMove,
  markers = [],
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
}: Props) {
  const geolocateControlRef = React.useRef<mapboxgl.GeolocateControl | null>(
    null,
  );
  const mapRef = React.useRef<any>(null);

  // Theme constants for consistent colors (synced with CSS)
  const THEME = React.useMemo(() => {
    const themeVars = [
      { key: 'brandPrimary', cssVar: '--brand-primary' },
      { key: 'brandPrimaryHover', cssVar: '--brand-primary-hover' },
      { key: 'accentWarm', cssVar: '--accent-warm' },
      { key: 'textInverse', cssVar: '--text-inverse' },
    ] as const;

    return createTheme<{
      brandPrimary: string;
      brandPrimaryHover: string;
      accentWarm: string;
      textInverse: string;
    }>(themeVars);
  }, []);

  // Safe extraction helper for geolocation error events
  type MaybeErrorEvent = {
    code?: number;
    message?: string;
    error?: { code?: number; message?: string };
  };

  function extractGeolocateError(evt: unknown): {
    code?: number;
    message?: string;
  } {
    if (!evt || typeof evt !== 'object') return {};
    const e = evt as MaybeErrorEvent;

    return {
      code: e.code ?? e.error?.code,
      message: e.message ?? e.error?.message,
    };
  }

  // Handle geolocation success from Mapbox control
  const handleGeolocate = React.useCallback(
    (evt: GeolocateResultEvent) => {
      if (onGeolocate && evt.coords) {
        const { latitude, longitude } = evt.coords;
        onGeolocate(latitude, longitude);
      }
    },
    [onGeolocate],
  );

  // Handle geolocation errors from Mapbox control
  const handleGeolocateError = React.useCallback(
    (evt: unknown) => {
      if (onGeolocateError) {
        const { code, message } = extractGeolocateError(evt);

        let errorMessage =
          message ||
          'Unable to get your location. Please check browser/OS location permissions.';

        switch (code) {
          case 1:
            errorMessage =
              'Location access denied. Allow location permissions to see nearby restaurants.';
            break;
          case 2:
            errorMessage =
              'Location information unavailable. Check OS location services or try again.';
            break;
          case 3:
            errorMessage =
              'Location request timed out. Try again or disable high accuracy.';
            break;
        }

        onGeolocateError(errorMessage);
      }
    },
    [onGeolocateError],
  );

  // Expose a single "trigger geolocation" function to the parent
  React.useEffect(() => {
    if (!registerGeolocateTrigger) return;

    registerGeolocateTrigger(() => {
      if (!geolocateControlRef.current) return false;
      geolocateControlRef.current.trigger();
      return true;
    });

    return () => registerGeolocateTrigger(null);
  }, [registerGeolocateTrigger]);

  // Separate restaurant markers from user marker
  const restaurantMarkers = markers.filter((m) => m.id !== -1);
  const userMarker = markers.find((m) => m.id === -1);

  // Create GeoJSON for clustering
  const restaurantGeoJson = React.useMemo(
    () => ({
      type: 'FeatureCollection' as const,
      features: restaurantMarkers.map((marker) => ({
        type: 'Feature' as const,
        geometry: {
          type: 'Point' as const,
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
    }),
    [restaurantMarkers],
  );

  // Handle map click for clustering and location picking
  const handleMapClick = React.useCallback(
    (event: any) => {
      // Manual pick mode: click anywhere to set user location
      if (isPickingLocation) {
        const { lng, lat } = event.lngLat;
        onPickLocation?.(lat, lng);
        return;
      }

      // Existing clustering / restaurant selection logic
      const map = mapRef.current?.getMap();
      if (!map) return;

      const features = map.queryRenderedFeatures(event.point, {
        layers: ['clusters', 'unclustered-point'],
      });

      if (features.length > 0) {
        const feature = features[0];
        if (feature.layer.id === 'clusters') {
          // Zoom into cluster
          const clusterId = feature.properties.cluster_id;
          const source = map.getSource('restaurants');
          if (source) {
            source.getClusterExpansionZoom(
              clusterId,
              (err: any, zoom: number) => {
                if (err) return;
                map.easeTo({
                  center: feature.geometry.coordinates,
                  zoom: zoom,
                });
              },
            );
          }
        } else if (feature.layer.id === 'unclustered-point') {
          // Open popup for restaurant
          const properties = feature.properties;
          const restaurant: MapMarker = {
            id: properties.id,
            lat: feature.geometry.coordinates[1],
            lng: feature.geometry.coordinates[0],
            name: properties.name,
            address: properties.address,
            openingHours: properties.openingHours,
            rating: properties.rating,
            distanceKm: properties.distanceKm,
            imageUrl: properties.imageUrl,
          };
          onSelectRestaurant?.(restaurant.id);
        }
      } else {
        onSelectRestaurant?.(null);
      }
    },
    [isPickingLocation, onPickLocation, onSelectRestaurant],
  );

  // Get selected restaurant from markers
  const selectedRestaurant = React.useMemo(() => {
    if (selectedRestaurantId == null) return null;
    return restaurantMarkers.find((m) => m.id === selectedRestaurantId) ?? null;
  }, [restaurantMarkers, selectedRestaurantId]);

  // Animate to selected restaurant
  React.useEffect(() => {
    if (!selectedRestaurant) return;

    const map = mapRef.current?.getMap();
    if (!map) return;

    // Smoothly center + zoom to selected restaurant
    map.flyTo({
      center: [selectedRestaurant.lng, selectedRestaurant.lat],
      zoom: Math.max(viewState.zoom, 15),
      duration: 900,
      essential: true,
      padding: { top: 180, bottom: 320, left: 40, right: 40 },
    });
  }, [selectedRestaurant?.id]);

  // Handle map mouse move for cursor changes
  const handleMapMouseMove = React.useCallback((event: any) => {
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

        {/* User Marker */}
        {userMarker && (
          <Marker
            key={userMarker.id}
            longitude={userMarker.lng}
            latitude={userMarker.lat}
            anchor="bottom"
          >
            <UserCircleIcon className="map-marker map-marker-user" />
          </Marker>
        )}

        {/* Restaurant Popup */}
        {selectedRestaurant && (
          <Popup
            className="restaurant-popup"
            longitude={selectedRestaurant.lng}
            latitude={selectedRestaurant.lat}
            anchor="bottom"
            offset={16}
            closeButton={false}
            closeOnClick={false}
            onClose={() => onSelectRestaurant?.(null)}
            maxWidth="360px"
            focusAfterOpen={false}
          >
            <div
              className="map-popup-card"
              onClick={(e) => e.stopPropagation()}
            >
              <button
                type="button"
                className="map-popup-close"
                onClick={() => onSelectRestaurant?.(null)}
                aria-label="Close popup"
              >
                <span aria-hidden="true">×</span>
              </button>

              {selectedRestaurant.imageUrl ? (
                <div className="map-popup-image">
                  <img
                    src={selectedRestaurant.imageUrl}
                    alt={selectedRestaurant.name}
                  />
                </div>
              ) : null}

              <div className="map-popup-header">
                <h3 className="map-popup-title">{selectedRestaurant.name}</h3>
                {typeof selectedRestaurant.rating === 'number' ? (
                  <div className="map-popup-rating">
                    <StarRating rating={selectedRestaurant.rating} />
                  </div>
                ) : null}
              </div>

              <div className="map-popup-body">
                <div className="map-popup-meta">
                  {selectedRestaurant.distanceKm != null ? (
                    <span>{selectedRestaurant.distanceKm} km</span>
                  ) : null}
                  {selectedRestaurant.openingHours ? (
                    <span>• {selectedRestaurant.openingHours}</span>
                  ) : null}
                </div>

                {selectedRestaurant.address ? (
                  <p className="map-popup-description">
                    {selectedRestaurant.address}
                  </p>
                ) : null}

                <Link
                  href={route('restaurants.show', selectedRestaurant.id)}
                  className="restaurant-view-btn"
                >
                  View details
                </Link>
              </div>
            </div>
          </Popup>
        )}

        {/* Clustering Layer - Restaurant markers */}
        <Source
          id="restaurants"
          type="geojson"
          data={restaurantGeoJson}
          cluster={true}
          clusterMaxZoom={14}
          clusterRadius={50}
        >
          <Layer
            id="clusters"
            type="circle"
            source="restaurants"
            filter={['has', 'point_count']}
            paint={{
              'circle-color': [
                'step',
                ['get', 'point_count'],
                THEME.accentWarm,
                2,
                THEME.brandPrimary,
                10,
                THEME.brandPrimaryHover,
              ],
              'circle-radius': [
                'step',
                ['get', 'point_count'],
                20,
                10,
                30,
                20,
                40,
              ],
            }}
          />

          <Layer
            id="cluster-count"
            type="symbol"
            source="restaurants"
            filter={['has', 'point_count']}
            layout={{
              'text-field': '{point_count_abbreviated}',
              'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
              'text-size': 12,
            }}
            paint={{
              'text-color': '#ffffff',
            }}
          />

          <Layer
            id="selected-point"
            type="circle"
            source="restaurants"
            filter={['==', ['get', 'id'], selectedRestaurantId || -999]}
            paint={{
              'circle-color': THEME.brandPrimary,
              'circle-radius': 18,
              'circle-stroke-color': THEME.brandPrimaryHover,
              'circle-stroke-width': 3,
            }}
          />

          <Layer
            id="unclustered-point"
            type="circle"
            source="restaurants"
            filter={['!', ['has', 'point_count']]}
            paint={{
              'circle-color': THEME.brandPrimary,
              'circle-radius': 14,
            }}
          />
        </Source>
      </Map>
    </div>
  );
}
