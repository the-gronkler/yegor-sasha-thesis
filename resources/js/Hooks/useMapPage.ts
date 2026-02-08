import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { router } from '@inertiajs/react';
import { useSearch } from '@/Hooks/useSearch';
import { Restaurant, MapMarker } from '@/types/models';
import type { IFuseOptions } from 'fuse.js';

/**
 * useMapPage (Logic Hook)
 *
 * Responsibilities:
 * - Manages all state for the Map page (View state, Selection, Geolocation status).
 * - Handles business logic: Search filtering, Geolocation API calls, Navigation (Inertia).
 * - Computes derived data: Map markers from filtered restaurants.
 * - Provides handler functions to the view layer.
 */
const SEARCH_OPTIONS: IFuseOptions<Restaurant> = {
  keys: [
    { name: 'name', weight: 2 },
    { name: 'description', weight: 1.5 },
    { name: 'food_types.name', weight: 1 },
    { name: 'food_types.menu_items.name', weight: 0.5 },
  ],
};

const EMPTY_KEYS: (keyof Restaurant)[] = [];

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

interface UseMapPageProps {
  restaurants: Restaurant[];
  filters: {
    lat: number | null;
    lng: number | null;
    radius: number;
  };
  mapboxPublicKey?: string;
}

export function useMapPage({
  restaurants,
  filters,
  mapboxPublicKey,
}: UseMapPageProps) {
  // --- Search Logic ---
  const {
    query,
    setQuery,
    filteredItems: filteredRestaurants,
  } = useSearch(restaurants, EMPTY_KEYS, SEARCH_OPTIONS);

  // --- State ---
  const [locationError, setLocationError] = useState<string | null>(null);
  const [selectedRestaurantId, setSelectedRestaurantId] = useState<
    number | null
  >(null);
  const [viewState, setViewState] = useState({
    longitude: 21.0122, // Warsaw, Poland
    latitude: 52.2297,
    zoom: 13,
  });
  const [isGeolocating, setIsGeolocating] = useState(false);
  const [isPickingLocation, setIsPickingLocation] = useState(false);
  const [showSearchInArea, setShowSearchInArea] = useState(false);

  // --- Refs ---
  const geolocateTriggerRef = useRef<null | (() => boolean)>(null);
  const initialCenterRef = useRef<{ lat: number; lng: number } | null>(null);

  // --- Callbacks & Handlers ---

  const registerGeolocateTrigger = useCallback((fn: (() => boolean) | null) => {
    geolocateTriggerRef.current = fn;
  }, []);

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

  const triggerGeolocate = useCallback(() => {
    const ok = geolocateTriggerRef.current?.();
    if (!ok) {
      setLocationError(
        'Geolocation control not ready yet. Refresh and try again.',
      );
      return;
    }
    setIsGeolocating(true);
  }, []);

  const handleMapGeolocate = useCallback(
    (latitude: number, longitude: number) => {
      setLocationError(null);
      setViewState((prev) => ({ ...prev, longitude, latitude, zoom: 14 }));
      setIsGeolocating(false);
      reloadMap(latitude, longitude, filters.radius ?? 50);
    },
    [filters.radius, reloadMap],
  );

  const handleGeolocateError = useCallback((error: string) => {
    setIsGeolocating(false);
    setLocationError(error);
  }, []);

  const handlePickLocation = useCallback(
    (lat: number, lng: number) => {
      setIsPickingLocation(false);
      setLocationError(null);
      handleMapGeolocate(lat, lng);
    },
    [handleMapGeolocate],
  );

  const selectRestaurant = useCallback((id: number | null) => {
    setSelectedRestaurantId((prev) => (prev === id ? null : id));
  }, []);

  const searchInArea = useCallback(() => {
    const { latitude, longitude } = viewState;
    setShowSearchInArea(false);

    // Backend uses search_lat/search_lng as the new center point for distance calculations.
    // The radius comes from existing filters and is not automatically expanded.
    // Just send the search coordinates.
    router.get(
      route('map.index'),
      {
        search_lat: latitude,
        search_lng: longitude,
        // Preserve existing user location if any
        ...(filters.lat !== null && filters.lng !== null
          ? {
              lat: filters.lat,
              lng: filters.lng,
            }
          : {}),
      },
      {
        replace: true,
        preserveState: true,
        preserveScroll: true,
        only: ['restaurants', 'filters'],
      },
    );
  }, [viewState, filters]);

  const handleViewStateChange = useCallback(
    (newViewState: { longitude: number; latitude: number; zoom: number }) => {
      setViewState(newViewState);

      // Check if map has moved significantly from initial center
      if (initialCenterRef.current) {
        const { lat: initialLat, lng: initialLng } = initialCenterRef.current;
        const latDiff = Math.abs(newViewState.latitude - initialLat);
        const lngDiff = Math.abs(newViewState.longitude - initialLng);

        // Shows button if moved more than ~0.01 degrees (~1km)
        if (latDiff > 0.01 || lngDiff > 0.01) {
          setShowSearchInArea(true);
        }
      }
    },
    [],
  );

  // --- Effects ---

  // Validate API key
  useEffect(() => {
    if (!mapboxPublicKey) {
      console.error('MAPBOX_PUBLIC_KEY is not configured in .env file');
    } else if (!mapboxPublicKey.startsWith('pk.')) {
      console.error(
        'MAPBOX_PUBLIC_KEY must be a public key starting with "pk.", not a secret key starting with "sk."',
      );
    }
  }, [mapboxPublicKey]);

  // Initial Center
  useEffect(() => {
    if (filters.lat !== null && filters.lng !== null) {
      setViewState((prev) => ({
        ...prev,
        longitude: filters.lng!,
        latitude: filters.lat!,
      }));
      // Update initial center reference when user location changes
      initialCenterRef.current = { lat: filters.lat, lng: filters.lng };
      setShowSearchInArea(false); // Hide button when user location is updated
    } else if (restaurants.length > 0) {
      const coords = getLatLng(restaurants[0]);
      if (coords) {
        setViewState((prev) => ({
          ...prev,
          longitude: coords[1],
          latitude: coords[0],
        }));
        if (!initialCenterRef.current) {
          initialCenterRef.current = { lat: coords[0], lng: coords[1] };
        }
      }
    }
  }, [filters.lat, filters.lng, restaurants]);

  // --- Computed ---

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
          reviewsCount: r.reviews_count ?? null,
          distanceKm: r.distance ?? null,
          imageUrl: primaryImage?.url ?? null,
        };
      })
      .filter(Boolean) as MapMarker[];

    const userMarker =
      filters.lat !== null && filters.lng !== null
        ? [{ id: -1, lat: filters.lat, lng: filters.lng, name: 'You are here' }]
        : [];

    return [...restaurantMarkers, ...userMarker];
  }, [filteredRestaurants, filters.lat, filters.lng]);

  return {
    // Search
    query,
    setQuery,
    filteredRestaurants,
    // Map State
    viewState,
    setViewState: handleViewStateChange,
    // Selection
    selectedRestaurantId,
    selectRestaurant,
    // Geolocation / Location Picking
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
    // Search in area
    showSearchInArea,
    searchInArea,
    // Data / Actions
    mapMarkers,
    reloadMap,
  };
}
