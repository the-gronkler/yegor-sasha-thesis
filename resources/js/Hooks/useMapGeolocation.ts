import * as React from 'react';
import type mapboxgl from 'mapbox-gl';
import type { GeolocateResultEvent } from 'react-map-gl/mapbox';

interface UseMapGeolocationProps {
  onGeolocate?: (latitude: number, longitude: number) => void;
  onGeolocateError?: (error: string) => void;
  registerGeolocateTrigger?: (fn: (() => boolean) | null) => void;
}

export function useMapGeolocation({
  onGeolocate,
  onGeolocateError,
  registerGeolocateTrigger,
}: UseMapGeolocationProps) {
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

  return {
    geolocateControlRef,
    handleGeolocate,
    handleGeolocateError,
  };
}
