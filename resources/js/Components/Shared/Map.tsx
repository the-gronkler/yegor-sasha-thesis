import * as React from 'react';
import Map, {
  Marker,
  Popup,
  GeolocateControl,
  NavigationControl,
  type GeolocateResultEvent,
} from 'react-map-gl/mapbox';
import { MapPinIcon, UserCircleIcon } from '@heroicons/react/24/solid';
import 'mapbox-gl/dist/mapbox-gl.css';

interface MapMarker {
  id: number;
  lat: number;
  lng: number;
  name: string;
}

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
}: Props) {
  const [popupId, setPopupId] = React.useState<number | null>(null);
  const geolocateControlRef = React.useRef<mapboxgl.GeolocateControl | null>(
    null,
  );

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

    // TODO: Extract code and message from the event, falling back to nested error if needed
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
        // TODO: select style for the map in general, beyond the scope of the currnet pr since its big already
        mapStyle="mapbox://styles/mapbox/dark-v10"
        mapboxAccessToken={mapboxAccessToken}
        style={{ height: '100%', width: '100%' }}
        onClick={() => setPopupId(null)}
      >
        {/* Navigation Controls (Zoom +/-, Compass) */}
        <NavigationControl position="top-right" />

        {/* Geolocation Control - Native Mapbox UI for user location */}
        {enableGeolocation && (
          <GeolocateControl
            ref={geolocateControlRef}
            position="top-right"
            positionOptions={{
              enableHighAccuracy: true,
              timeout: 6000,
              maximumAge: 0,
            }}
            trackUserLocation={trackUserLocation}
            showUserHeading={trackUserLocation}
            showUserLocation={true}
            onGeolocate={handleGeolocate}
            onError={handleGeolocateError}
          />
        )}

        {/* Restaurant and User Markers */}
        {markers.map((marker) => {
          const isUserLocation = marker.id === -1;
          return (
            <Marker
              key={marker.id}
              longitude={marker.lng}
              latitude={marker.lat}
              anchor="bottom"
              onClick={(e) => {
                e.originalEvent.stopPropagation();
                setPopupId(marker.id);
              }}
            >
              {isUserLocation ? (
                <UserCircleIcon className="map-marker map-marker-user" />
              ) : (
                <MapPinIcon className="map-marker map-marker-restaurant" />
              )}
            </Marker>
          );
        })}

        {/* Marker Popups */}
        {markers.map((marker) =>
          popupId === marker.id ? (
            <Popup
              key={marker.id}
              longitude={marker.lng}
              latitude={marker.lat}
              anchor="bottom"
              offset={25}
              onClose={() => setPopupId(null)}
              closeButton={true}
              closeOnClick={false}
            >
              <div>{marker.name}</div>
            </Popup>
          ) : null,
        )}
      </Map>
    </div>
  );
}
