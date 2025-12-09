import { useEffect, useMemo, useState } from 'react';
import { Head } from '@inertiajs/react';
import MapLayout from '@/Layouts/MapLayout';
import Map from '@/Components/Shared/Map';
import SearchInput from '@/Components/UI/SearchInput';
import RestaurantCard from '@/Components/Shared/RestaurantCard';
import { useSearch } from '@/Hooks/useSearch';
import { IFuseOptions } from 'fuse.js';
import { Restaurant } from '@/types/models';

const SEARCH_OPTIONS: IFuseOptions<Restaurant> = {
  keys: [
    { name: 'name', weight: 2 },
    { name: 'description', weight: 1.5 },
    { name: 'food_types.name', weight: 1 },
    { name: 'food_types.menu_items.name', weight: 0.5 },
  ],
};

const EMPTY_KEYS: any[] = [];

interface Props {
  restaurants: Restaurant[];
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

export default function MapIndex({ restaurants }: Props) {
  const {
    query,
    setQuery,
    filteredItems: filteredRestaurants,
  } = useSearch(restaurants, EMPTY_KEYS, SEARCH_OPTIONS);

  const [userLocation, setUserLocation] = useState<[number, number] | null>(
    null,
  );
  const [center, setCenter] = useState<[number, number]>([51.505, -0.09]);

  useEffect(() => {
    if (restaurants.length > 0) {
      const coords = getLatLng(restaurants[0]);
      if (coords) {
        setCenter(coords);
      }
    }

    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          setUserLocation([latitude, longitude]);
          setCenter([latitude, longitude]);
        },
        () => {
          // Silently fail - user denied location or browser blocked it
        },
        {
          timeout: 5000,
          maximumAge: 60000,
        },
      );
    }
  }, [restaurants]);

  useEffect(() => {
    if (!userLocation && filteredRestaurants.length > 0) {
      const coords = getLatLng(filteredRestaurants[0]);
      if (coords) {
        setCenter(coords);
      }
    }
  }, [filteredRestaurants, userLocation]);

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
        <div className="map-container-box">
          <div className="map-overlay">
            <SearchInput
              value={query}
              onChange={setQuery}
              placeholder="Search restaurants..."
              className="map-search-input"
            />
          </div>

          <Map center={center} zoom={13} markers={mapMarkers} />

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
