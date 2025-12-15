import { useState, useEffect } from 'react';

/**
 * Geolocation coordinates in [latitude, longitude] format.
 */
export type GeolocationCoordinates = [number, number];

/**
 * Geolocation error types based on the Geolocation API error codes.
 */
export enum GeolocationErrorType {
  PERMISSION_DENIED = 'PERMISSION_DENIED',
  POSITION_UNAVAILABLE = 'POSITION_UNAVAILABLE',
  TIMEOUT = 'TIMEOUT',
  NOT_SUPPORTED = 'NOT_SUPPORTED',
}

/**
 * Configuration options for the geolocation hook.
 */
interface UseGeolocationOptions {
  /**
   * Whether to enable high accuracy GPS positioning.
   * @default false
   */
  enableHighAccuracy?: boolean;
  /**
   * Maximum time (in milliseconds) to wait for position.
   * @default 5000
   */
  timeout?: number;
  /**
   * Maximum age (in milliseconds) of a cached position.
   * @default 60000
   */
  maximumAge?: number;
  /**
   * Whether to automatically request location on mount.
   * @default true
   */
  immediate?: boolean;
}

/**
 * Return type for the useGeolocation hook.
 */
interface UseGeolocationReturn {
  /**
   * Current user location as [latitude, longitude], or null if not available.
   */
  location: GeolocationCoordinates | null;
  /**
   * Error message if geolocation failed, or null if no error.
   */
  error: string | null;
  /**
   * Error type for programmatic handling.
   */
  errorType: GeolocationErrorType | null;
  /**
   * Whether the geolocation is currently being requested.
   */
  loading: boolean;
  /**
   * Function to manually request the user's location.
   */
  requestLocation: () => void;
  /**
   * Function to clear the error state.
   */
  clearError: () => void;
}

/**
 * A custom React hook that manages user geolocation using the browser's Geolocation API.
 * It handles permission requests, error states, and provides a clean interface for accessing
 * the user's current location.
 *
 * @param options - Configuration options for geolocation behavior.
 * @returns An object containing location data, error state, loading state, and control functions.
 *
 * @example
 * ```tsx
 * function MapComponent() {
 *   const { location, error, loading, requestLocation, clearError } = useGeolocation({
 *     enableHighAccuracy: true,
 *     timeout: 10000,
 *   });
 *
 *   if (loading) return <div>Getting your location...</div>;
 *   if (error) return <div>Error: {error} <button onClick={requestLocation}>Retry</button></div>;
 *   if (location) return <div>Your location: {location[0]}, {location[1]}</div>;
 *
 *   return <button onClick={requestLocation}>Get Location</button>;
 * }
 * ```
 */
export function useGeolocation(
  options: UseGeolocationOptions = {},
): UseGeolocationReturn {
  const {
    enableHighAccuracy = false,
    timeout = 5000,
    maximumAge = 60000,
    immediate = true,
  } = options;

  const [location, setLocation] = useState<GeolocationCoordinates | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [errorType, setErrorType] = useState<GeolocationErrorType | null>(null);
  const [loading, setLoading] = useState<boolean>(false);

  const clearError = () => {
    setError(null);
    setErrorType(null);
  };

  const handleSuccess = (position: GeolocationPosition) => {
    const { latitude, longitude } = position.coords;
    setLocation([latitude, longitude]);
    setError(null);
    setErrorType(null);
    setLoading(false);
  };

  const handleError = (err: GeolocationPositionError) => {
    let errorMessage: string;
    let type: GeolocationErrorType;

    switch (err.code) {
      case err.PERMISSION_DENIED:
        errorMessage =
          'Location access denied. Enable location permissions to see nearby restaurants.';
        type = GeolocationErrorType.PERMISSION_DENIED;
        break;
      case err.POSITION_UNAVAILABLE:
        errorMessage =
          'Location information unavailable. Showing default map view.';
        type = GeolocationErrorType.POSITION_UNAVAILABLE;
        break;
      case err.TIMEOUT:
        errorMessage = 'Location request timed out. Showing default map view.';
        type = GeolocationErrorType.TIMEOUT;
        break;
      default:
        errorMessage = 'An unknown error occurred while getting your location.';
        type = GeolocationErrorType.POSITION_UNAVAILABLE;
    }

    setError(errorMessage);
    setErrorType(type);
    setLoading(false);
    console.warn('Geolocation error:', err.message);
  };

  const requestLocation = () => {
    if (!navigator.geolocation) {
      setError('Geolocation is not supported by your browser.');
      setErrorType(GeolocationErrorType.NOT_SUPPORTED);
      setLoading(false);
      return;
    }

    // Check if running on HTTP (not HTTPS or localhost)
    const isSecureContext = window.isSecureContext;
    const isLocalhost =
      window.location.hostname === 'localhost' ||
      window.location.hostname === '127.0.0.1';

    if (!isSecureContext && !isLocalhost) {
      setError(
        'Geolocation requires HTTPS. The site must be served over HTTPS to access your location.',
      );
      setErrorType(GeolocationErrorType.NOT_SUPPORTED);
      setLoading(false);
      console.warn(
        'Geolocation API requires a secure context (HTTPS or localhost). Current URL:',
        window.location.href,
      );
      return;
    }

    setLoading(true);
    clearError();

    navigator.geolocation.getCurrentPosition(handleSuccess, handleError, {
      enableHighAccuracy,
      timeout,
      maximumAge,
    });
  };

  // Request location on mount if immediate is true
  useEffect(() => {
    if (immediate) {
      requestLocation();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []); // Empty dependency array ensures this runs only once on mount

  return {
    location,
    error,
    errorType,
    loading,
    requestLocation,
    clearError,
  };
}
