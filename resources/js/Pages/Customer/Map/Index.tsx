import { Head } from '@inertiajs/react';
import MapLayout from '@/Layouts/MapLayout';
import Map from '@/Components/Shared/Map';
import BottomSheet from './Partials/BottomSheet';
import MapOverlay from './Partials/MapOverlay';
import { useMapPage } from '@/Hooks/useMapPage';
import { Restaurant } from '@/types/models';
import { PageProps } from '@/types';

/**
 * MapIndex (Controller View)
 *
 * Responsibilities:
 * - Acts as the main entry point for the Map page.
 * - Orchestrates data flow by connecting the `useMapPage` hook to UI components.
 * - Composes the layout: MapLayout > MapOverlay + Map + BottomSheet.
 * - Does NOT contain complex logic (delegated to useMapPage) or complex UI (delegated to Partials).
 */
interface MapIndexProps extends PageProps {
  restaurants: Restaurant[];
  filters: {
    lat: number | null;
    lng: number | null;
    radius: number;
  };
  mapboxPublicKey?: string;
}

export default function MapIndex({
  restaurants,
  filters,
  mapboxPublicKey,
}: MapIndexProps) {
  const {
    query,
    setQuery,
    filteredRestaurants,
    viewState,
    setViewState,
    selectedRestaurantId,
    selectRestaurant,
    locationError,
    setLocationError,
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
    handleMapReady,
  } = useMapPage({ restaurants, filters, mapboxPublicKey });

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
            onReady={handleMapReady}
          />
          <BottomSheet
            restaurants={filteredRestaurants}
            selectedRestaurantId={selectedRestaurantId}
            onSelectRestaurant={selectRestaurant}
          />
        </div>
      </div>
    </MapLayout>
  );
}
