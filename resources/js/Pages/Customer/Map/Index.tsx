import { useEffect, useMemo, useState } from 'react';
import { Head } from '@inertiajs/react';
import MapLayout from '@/Layouts/MapLayout';
import Map from '@/Components/Shared/Map';
import SearchInput from '@/Components/UI/SearchInput';
import RestaurantCard from '@/Components/Shared/RestaurantCard';
import { useSearch } from '@/Hooks/useSearch';
import { useGeolocation } from '@/Hooks/useGeolocation';
import { calculateDistance } from '@/Utils/distance';
import { Restaurant } from '@/types/models';
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

interface MapIndexProps extends PageProps {
  restaurants: Restaurant[];
  mapboxPublicKey: string;
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
  mapboxPublicKey,
}: MapIndexProps) {
  const {
    query,
    setQuery,
    filteredItems: filteredRestaurants,
  } = useSearch(restaurants, EMPTY_KEYS, SEARCH_OPTIONS);

  const {
    location: userLocation,
    error: locationError,
    clearError: clearLocationError,
  } = useGeolocation({
    enableHighAccuracy: true,
    timeout: 6000,
    maximumAge: 0,
    immediate: false, // Don't auto-trigger, let user click the Mapbox button
  });

  const [mapUserLocation, setMapUserLocation] = useState<
    [number, number] | null
  >(null);

  // Use Mapbox geolocation or fallback to custom hook
  const effectiveUserLocation = mapUserLocation || userLocation;

  // Default center coordinates correspond to Warsaw, Poland (longitude, latitude)
  const [center, setCenter] = useState<[number, number]>([21.0122, 52.2297]); // [lng, lat] for Mapbox

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

  // Handle geolocation from Mapbox native control
  const handleMapGeolocate = (position: GeolocationPosition) => {
    const { latitude, longitude } = position.coords;
    setMapUserLocation([latitude, longitude]);
    setCenter([longitude, latitude]); // Convert to [lng, lat] for Mapbox
  };

  // Set initial center based on first restaurant or user location
  useEffect(() => {
    if (effectiveUserLocation) {
      // Convert [lat, lng] to [lng, lat] for Mapbox
      setCenter([effectiveUserLocation[1], effectiveUserLocation[0]]);
    } else if (restaurants.length > 0) {
      const coords = getLatLng(restaurants[0]);
      if (coords) {
        // Convert [lat, lng] to [lng, lat] for Mapbox
        setCenter([coords[1], coords[0]]);
      }
    }
  }, [effectiveUserLocation, restaurants]);

  //   This code re-center the map on the first restaurant in the search results if user location is not available
  // whether or not it should be here is beyound the sope of the current task, leaving this here commented out for now
  //   useEffect(() => {
  //     if (!userLocation && filteredRestaurants.length > 0) {
  //       const coords = getLatLng(filteredRestaurants[0]);
  //       if (coords) {
  //         // Convert [lat, lng] to [lng, lat] for Mapbox
  //         setCenter([coords[1], coords[0]]);
  //       }
  //     }
  //   }, [filteredRestaurants, userLocation]);

  // Calculate distances for all restaurants when user location is available
  const restaurantsWithDistance = useMemo(() => {
    if (!effectiveUserLocation) return filteredRestaurants;

    return filteredRestaurants.map((restaurant) => {
      const coords = getLatLng(restaurant);
      if (!coords) return restaurant;

      const distance = calculateDistance(
        effectiveUserLocation[0],
        effectiveUserLocation[1],
        coords[0],
        coords[1],
      );

      return {
        ...restaurant,
        distance,
      };
    });
  }, [filteredRestaurants, effectiveUserLocation]);

  const mapMarkers = useMemo(() => {
    const restaurantMarkers = restaurantsWithDistance
      .map((restaurant) => {
        const coords = getLatLng(restaurant);
        if (!coords) return null;
        return {
          id: restaurant.id,
          lat: coords[0],
          lng: coords[1],
          name: restaurant.name,
        };
      })
      .filter(Boolean) as {
      id: number;
      lat: number;
      lng: number;
      name: string;
    }[];

    const userMarker = effectiveUserLocation
      ? [
          {
            id: -1,
            lat: effectiveUserLocation[0],
            lng: effectiveUserLocation[1],
            name: 'You are here',
          },
        ]
      : [];

    return [...restaurantMarkers, ...userMarker];
  }, [restaurantsWithDistance, effectiveUserLocation]);

  return (
    <MapLayout>
      <Head title="Restaurant Map" />
      <div className="map-page">
        {locationError && (
          <div className="location-error-banner">
            <p className="location-error-message">{locationError}</p>
            <button
              className="location-error-dismiss"
              onClick={clearLocationError}
              aria-label="Dismiss location error"
            >
              ×
            </button>
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
          </div>
          <Map
            center={center}
            zoom={13}
            markers={mapMarkers}
            mapboxAccessToken={mapboxPublicKey}
            onGeolocate={handleMapGeolocate}
            enableGeolocation={true}
            trackUserLocation={false}
          />
          <div className="map-bottom-sheet">
            {restaurantsWithDistance.map((restaurant) => (
              <RestaurantCard key={restaurant.id} restaurant={restaurant} />
            ))}
          </div>
        </div>
      </div>
    </MapLayout>
  );
}
