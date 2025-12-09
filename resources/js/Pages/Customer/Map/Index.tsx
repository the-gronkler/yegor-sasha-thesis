import { useEffect, useState } from 'react';
import { Head } from '@inertiajs/react';
import MapLayout from '@/Layouts/MapLayout';
import Map from '@/Components/Shared/Map';

interface RestaurantLocation {
  id: number;
  name: string;
  lat: number;
  lng: number;
  address: string;
}

interface Props {
  restaurants: RestaurantLocation[];
}

export default function MapIndex({ restaurants }: Props) {
  const [userLocation, setUserLocation] = useState<[number, number] | null>(
    null,
  );
  const [center, setCenter] = useState<[number, number]>([51.505, -0.09]); // Default fallback

  useEffect(() => {
    // Fallback to first restaurant immediately if available
    if (restaurants.length > 0) {
      setCenter([restaurants[0].lat, restaurants[0].lng]);
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
          // Map already centers on first restaurant from above
        },
        {
          timeout: 5000,
          maximumAge: 60000,
        },
      );
    }
  }, []); // Run only once on mount

  const mapMarkers = [
    ...restaurants.map((r) => ({
      id: r.id,
      lat: r.lat,
      lng: r.lng,
      name: r.name,
    })),
    ...(userLocation
      ? [
          {
            id: -1, // Special ID for user
            lat: userLocation[0],
            lng: userLocation[1],
            name: 'You are here',
          },
        ]
      : []),
  ];

  return (
    <MapLayout>
      <Head title="Restaurant Map" />

      <div className="map-page">
        <div className="map-container-box">
          <div className="map-overlay">
            <h1 className="page-title">Find Restaurants Near You</h1>
            {import.meta.env.DEV && (
              <p className="debug-text">
                Debug: restaurants={restaurants.length}, center=({center[0]},
                {center[1]})
              </p>
            )}
          </div>

          <Map center={center} zoom={13} markers={mapMarkers} />
        </div>
      </div>
    </MapLayout>
  );
}
