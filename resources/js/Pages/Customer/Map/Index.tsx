import { useEffect, useMemo, useState } from 'react';
import { Head } from '@inertiajs/react';
import MapLayout from '@/Layouts/MapLayout';
import Map from '@/Components/Shared/Map';
import SearchInput from '@/Components/UI/SearchInput';
import RestaurantCard from '@/Components/Shared/RestaurantCard';
import { useSearch } from '@/Hooks/useSearch';
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

  const [userLocation, setUserLocation] = useState<[number, number] | null>(
    null,
  );
  const [locationError, setLocationError] = useState<string | null>(null);
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

  useEffect(() => {
    if (restaurants.length > 0) {
      const coords = getLatLng(restaurants[0]);
      if (coords) {
        // Convert [lat, lng] to [lng, lat] for Mapbox
        setCenter([coords[1], coords[0]]);
      }
    }
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          setUserLocation([latitude, longitude]);
          // Convert [lat, lng] to [lng, lat] for Mapbox
          setCenter([longitude, latitude]);
          setLocationError(null);
        },
        (error) => {
          let errorMessage = 'Unable to access your location';

          switch (error.code) {
            case error.PERMISSION_DENIED:
              errorMessage =
                'Location access denied. Enable location permissions to see nearby restaurants.';
              break;
            case error.POSITION_UNAVAILABLE:
              errorMessage =
                'Location information unavailable. Showing default map view.';
              break;
            case error.TIMEOUT:
              errorMessage =
                'Location request timed out. Showing default map view.';
              break;
          }

          setLocationError(errorMessage);
          console.warn('Geolocation error:', error.message);
        },
        {
          timeout: 5000,
          maximumAge: 60000,
        },
      );
    } else {
      setLocationError('Geolocation is not supported by your browser.');
    }
  }, [restaurants]);

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

  const mapMarkers = useMemo(() => {
    const restaurantMarkers = filteredRestaurants
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

    const userMarker = userLocation
      ? [
          {
            id: -1,
            lat: userLocation[0],
            lng: userLocation[1],
            name: 'You are here',
          },
        ]
      : [];

    return [...restaurantMarkers, ...userMarker];
  }, [filteredRestaurants, userLocation]);

  return (
    <MapLayout>
      <Head title="Restaurant Map" />
      <div className="map-page">
        {locationError && (
          <div className="location-error-banner">
            <p className="location-error-message">{locationError}</p>
            <button
              className="location-error-dismiss"
              onClick={() => setLocationError(null)}
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
