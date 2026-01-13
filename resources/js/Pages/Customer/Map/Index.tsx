import * as React from 'react';
import { Head } from '@inertiajs/react';
import MapLayout from '@/Layouts/MapLayout';
import Map from '@/Components/Shared/Map';
import { PageProps } from '@/types';

/**
 * MapIndex (Controller View)
 *
 * Responsibilities:
 * - Acts as the main entry point for the Map page.
 * - Orchestrates data flow by connecting the `useMapPage` hook to UI components.
 * - Composes the layout: MapLayout > MapOverlay + Map + BottomSheet.
 * - Does NOT contain complex logic (delegated to useMapPage) or complex UI (delegated to Partials).
 *
 * ARCHITECTURE CHANGE (Vector Tiles):
 * - Restaurants are now loaded from Mapbox Vector Tiles (not Inertia props)
 * - Only receives tileset configuration and initial viewport
 * - Frontend fetches restaurant details on-demand when user clicks points
 */
interface MapIndexProps extends PageProps {
  mapboxToken: string;
  tilesetId?: string; // Mapbox tileset URL (e.g., mapbox://username.tileset-id)
  initialViewport: {
    latitude: number;
    longitude: number;
    zoom: number;
  };
  userGeo?: {
    lat: number;
    lng: number;
  } | null;
}

export default function MapIndex({
  mapboxToken,
  tilesetId,
  initialViewport,
  userGeo,
}: MapIndexProps) {
  // Simplified state management for vector tile approach
  const [viewState, setViewState] = React.useState(initialViewport);
  const [selectedRestaurantId, setSelectedRestaurantId] = React.useState<
    number | null
  >(null);
  const [locationError, setLocationError] = React.useState<string | null>(null);
  const [isGeolocating, setIsGeolocating] = React.useState(false);
  const [isPickingLocation, setIsPickingLocation] = React.useState(false);

  // Geolocation trigger callback
  const geolocateTriggerRef = React.useRef<(() => boolean) | null>(null);
  const registerGeolocateTrigger = React.useCallback(
    (fn: (() => boolean) | null) => {
      geolocateTriggerRef.current = fn;
    },
    [],
  );

  const triggerGeolocate = React.useCallback(() => {
    if (geolocateTriggerRef.current) {
      setIsGeolocating(true);
      const success = geolocateTriggerRef.current();
      if (!success) {
        setIsGeolocating(false);
      }
    }
  }, []);

  const handleMapGeolocate = React.useCallback((lat: number, lng: number) => {
    setIsGeolocating(false);
    setLocationError(null);
    setIsPickingLocation(false);

    // Reload page with new coordinates
    window.location.href = `/?lat=${lat}&lng=${lng}`;
  }, []);

  const handleGeolocateError = React.useCallback((error: string) => {
    setIsGeolocating(false);
    setLocationError(error);
  }, []);

  const handlePickLocation = React.useCallback(
    (lat: number, lng: number) => {
      handleMapGeolocate(lat, lng);
    },
    [handleMapGeolocate],
  );

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
          {/* MapOverlay removed - simplified version without search/filter UI */}
          {/* Can be re-added later with API-based search */}

          <Map
            viewState={viewState}
            onMove={setViewState}
            tilesetId={tilesetId}
            mapboxAccessToken={mapboxToken}
            onGeolocate={handleMapGeolocate}
            onGeolocateError={handleGeolocateError}
            enableGeolocation={true}
            trackUserLocation={false}
            selectedRestaurantId={selectedRestaurantId}
            onSelectRestaurant={setSelectedRestaurantId}
            registerGeolocateTrigger={registerGeolocateTrigger}
            isPickingLocation={isPickingLocation}
            onPickLocation={handlePickLocation}
            showGeolocateControlUi={true}
            userGeo={userGeo}
          />

          {/* BottomSheet removed - popup now shows restaurant details */}
          {/* Can be re-added later with API-based restaurant list */}
        </div>
      </div>
    </MapLayout>
  );
}
