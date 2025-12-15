import * as React from 'react';
import Map, {
  Marker,
  Popup,
  GeolocateControl,
  NavigationControl,
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
  center?: [number, number]; // [lng, lat]
  zoom?: number;
  markers?: MapMarker[];
  className?: string;
  mapboxAccessToken: string;
  onGeolocate?: (position: GeolocationPosition) => void;
  enableGeolocation?: boolean;
  trackUserLocation?: boolean;
}

export default function MapComponent({
  center = [-0.09, 51.505], // [lng, lat]
  zoom = 13,
  markers = [],
  className = '',
  mapboxAccessToken,
  onGeolocate,
  enableGeolocation = true,
  trackUserLocation = false,
}: Props) {
  const [popupId, setPopupId] = React.useState<number | null>(null);
  const geolocateControlRef = React.useRef<any>(null);

  // Handle geolocation events from Mapbox control
  const handleGeolocate = React.useCallback(
    (e: any) => {
      if (onGeolocate && e.coords) {
        // Convert Mapbox event to standard GeolocationPosition
        const coords: GeolocationCoordinates = {
          latitude: e.coords.latitude,
          longitude: e.coords.longitude,
          accuracy: e.coords.accuracy,
          altitude: null,
          altitudeAccuracy: null,
          heading: e.coords.heading ?? null,
          speed: null,
          toJSON() {
            return {
              latitude: this.latitude,
              longitude: this.longitude,
              accuracy: this.accuracy,
              altitude: this.altitude,
              altitudeAccuracy: this.altitudeAccuracy,
              heading: this.heading,
              speed: this.speed,
            };
          },
        };

        const position: GeolocationPosition = {
          coords,
          timestamp: Date.now(),
          toJSON() {
            return {
              coords: this.coords.toJSON(),
              timestamp: this.timestamp,
            };
          },
        };
        onGeolocate(position);
      }
    },
    [onGeolocate],
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
        initialViewState={{ longitude: center[0], latitude: center[1], zoom }}
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
