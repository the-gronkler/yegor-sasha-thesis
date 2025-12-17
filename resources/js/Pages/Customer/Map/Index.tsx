import { useEffect, useMemo, useState } from 'react';
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

const RADIUS_OPTIONS = [2, 5, 10, 25, 50] as const;
const DEFAULT_RADIUS = 10;

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
  const [selectedRadius, setSelectedRadius] = useState<number>(
    filters.radius || DEFAULT_RADIUS,
  );

  // Controlled viewState for the map
  const [viewState, setViewState] = useState({
    longitude: 21.0122, // Warsaw, Poland
    latitude: 52.2297,
    zoom: 13,
  });

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

  // Handle geolocation from Mapbox native control
  const handleMapGeolocate = (latitude: number, longitude: number) => {
    // Update map center immediately
    setViewState((prev) => ({
      ...prev,
      longitude,
      latitude,
      zoom: 14, // Zoom in when user location is found
    }));

    // Trigger Inertia reload with new location and radius
    router.get(
      route('map.index'),
      { lat: latitude, lng: longitude, radius: selectedRadius },
      {
        replace: true,
        preserveState: true,
        preserveScroll: true,
        only: ['restaurants', 'filters'],
      },
    );
  };

  // Handle geolocation errors
  const handleGeolocateError = (error: string) => {
    setLocationError(error);
  };

  // Handle radius change
  const handleRadiusChange = (newRadius: number) => {
    setSelectedRadius(newRadius);

    // If we have user location, reload with new radius
    if (filters.lat !== null && filters.lng !== null) {
      router.get(
        route('map.index'),
        { lat: filters.lat, lng: filters.lng, radius: newRadius },
        {
          replace: true,
          preserveState: true,
          preserveScroll: true,
          only: ['restaurants', 'filters'],
        },
      );
    }
  };

  // Debug function to test native geolocation (for development only)
  const debugRequestLocation = () => {
    if (!navigator.geolocation) {
      setLocationError('Geolocation is not supported by this browser.');
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (pos) => {
        console.log('Native geolocation success:', pos);
        handleMapGeolocate(pos.coords.latitude, pos.coords.longitude);
      },
      (err) => {
        console.warn('Native geolocation error:', err);
        // err.code will be 1/2/3 with real message
        let errorMessage = `${err.code}: ${err.message}`;
        setLocationError(errorMessage);
      },
      { enableHighAccuracy: true, timeout: 6000, maximumAge: 0 },
    );
  };

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
            <p className="location-error-message">{locationError}</p>
            <div className="location-error-actions">
              <button
                className="location-error-native"
                onClick={() => {
                  if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(
                      (pos) => {
                        console.log('Native geolocation success:', pos);
                        handleMapGeolocate(
                          pos.coords.latitude,
                          pos.coords.longitude,
                        );
                        setLocationError(null); // Clear error on success
                      },
                      (err) => {
                        console.warn('Native geolocation error:', err);
                        setLocationError(`Native: ${err.code}: ${err.message}`);
                      },
                      {
                        enableHighAccuracy: true,
                        timeout: 6000,
                        maximumAge: 0,
                      },
                    );
                  }
                }}
                aria-label="Try native geolocation"
              >
                Try Native GPS
              </button>
              <button
                className="location-error-debug"
                onClick={debugRequestLocation}
                aria-label="Try requesting location again"
              >
                Try Again
              </button>
              <button
                className="location-error-dismiss"
                onClick={() => setLocationError(null)}
                aria-label="Dismiss location error"
              >
                ×
              </button>
            </div>
          </div>
        )}
        <div className="map-container-box">
          <div className="map-overlay">
            <SearchInput
              value={query}
              onChange={setQuery}
              placeholder="Search restaurants..."
              className="map-search-input"
            />
            {filters.lat !== null && filters.lng !== null && (
              <div className="map-radius-selector">
                <label htmlFor="radius-select">Radius:</label>
                <select
                  id="radius-select"
                  value={selectedRadius}
                  onChange={(e) => handleRadiusChange(Number(e.target.value))}
                  className="radius-select"
                >
                  {RADIUS_OPTIONS.map((radius) => (
                    <option key={radius} value={radius}>
                      {radius} km
                    </option>
                  ))}
                </select>
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
          />
          <div className="map-bottom-sheet">
            {filteredRestaurants.map((restaurant) => (
              <RestaurantCard key={restaurant.id} restaurant={restaurant} />
            ))}
          </div>
        </div>
      </div>
    </MapLayout>
  );
}
