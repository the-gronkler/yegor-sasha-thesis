import * as React from 'react';
import Map, {
  Marker,
  GeolocateControl,
  NavigationControl,
  Source,
  Layer,
} from 'react-map-gl/mapbox';
import { UserCircleIcon } from '@heroicons/react/24/solid';
import 'mapbox-gl/dist/mapbox-gl.css';
import type { MapRef } from 'react-map-gl/mapbox';
import type { MapMouseEvent, GeoJSONSource } from 'mapbox-gl';
import type { Point } from 'geojson';
import { MapMarker } from '@/types/models';
import { createTheme } from '@/Utils/css';
import MapPopup from './MapPopup';
import {
  getClusterLayer,
  getClusterCountLayer,
  getSelectedPointLayer,
  getUnclusteredPointLayer,
  MapTheme,
} from './mapStyles';
import { useMapGeolocation } from '@/Hooks/useMapGeolocation';

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
  selectedRestaurantId?: number | null;
  onSelectRestaurant?: (id: number | null, opts?: { scroll?: boolean }) => void;
  registerGeolocateTrigger?: (fn: (() => boolean) | null) => void;
  isPickingLocation?: boolean;
  onPickLocation?: (lat: number, lng: number) => void;
  showGeolocateControlUi?: boolean;
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
  selectedRestaurantId,
  onSelectRestaurant,
  registerGeolocateTrigger,
  isPickingLocation,
  onPickLocation,
  showGeolocateControlUi = true,
}: Props) {
  const mapRef = React.useRef<MapRef>(null);

  const { geolocateControlRef, handleGeolocate, handleGeolocateError } =
    useMapGeolocation({
      onGeolocate,
      onGeolocateError,
      registerGeolocateTrigger,
    });

  // Theme constants for consistent colors (synced with CSS)
  const THEME = React.useMemo(() => {
    const themeVars = [
      { key: 'brandPrimary', cssVar: '--brand-primary' },
      { key: 'brandPrimaryHover', cssVar: '--brand-primary-hover' },
      { key: 'accentWarm', cssVar: '--accent-warm' },
      { key: 'textInverse', cssVar: '--text-inverse' },
    ] as const;

    return createTheme<any>(themeVars) as MapTheme;
  }, []);

  // Separate restaurant markers from user marker
  const restaurantMarkers = markers.filter((m) => m.id !== -1);
  const userMarker = markers.find((m) => m.id === -1);

  // Create GeoJSON for clustering
  const restaurantGeoJson = React.useMemo(
    () => ({
      type: 'FeatureCollection' as const,
      features: restaurantMarkers.map((marker) => ({
        type: 'Feature' as const,
        geometry: {
          type: 'Point' as const,
          coordinates: [marker.lng, marker.lat],
        },
        properties: {
          id: marker.id,
          name: marker.name,
          address: marker.address,
          openingHours: marker.openingHours,
          rating: marker.rating,
          distanceKm: marker.distanceKm,
          imageUrl: marker.imageUrl,
        },
      })),
    }),
    [restaurantMarkers],
  );

  // Handle map click for clustering and location picking
  const handleMapClick = React.useCallback(
    (event: MapMouseEvent) => {
      // Manual pick mode: click anywhere to set user location
      if (isPickingLocation) {
        const { lng, lat } = event.lngLat;
        onPickLocation?.(lat, lng);
        return;
      }

      // Existing clustering / restaurant selection logic
      const map = mapRef.current?.getMap();
      if (!map) return;

      const features = map.queryRenderedFeatures(event.point, {
        layers: ['clusters', 'unclustered-point'],
      });

      if (features.length > 0) {
        const feature = features[0];
        if (feature.layer?.id === 'clusters') {
          // Zoom into cluster
          const clusterId = feature.properties?.cluster_id;
          const source = map.getSource('restaurants') as GeoJSONSource;
          if (source && clusterId) {
            source.getClusterExpansionZoom(
              clusterId,
              (err?: Error | null, zoom?: number | null) => {
                if (err || zoom == null) return;
                map.easeTo({
                  center: (feature.geometry as Point).coordinates as [
                    number,
                    number,
                  ],
                  zoom: zoom,
                });
              },
            );
          }
        } else if (feature.layer?.id === 'unclustered-point') {
          // Open popup for restaurant
          const properties = feature.properties;
          if (!properties || feature.geometry.type !== 'Point') return;
          const coordinates = (feature.geometry as Point).coordinates;
          const restaurant: MapMarker = {
            id: properties.id,
            lat: coordinates[1],
            lng: coordinates[0],
            name: properties.name,
            address: properties.address,
            openingHours: properties.openingHours,
            rating: properties.rating,
            distanceKm: properties.distanceKm,
            imageUrl: properties.imageUrl,
          };
          onSelectRestaurant?.(restaurant.id);
        }
      } else {
        onSelectRestaurant?.(null);
      }
    },
    [isPickingLocation, onPickLocation, onSelectRestaurant],
  );

  // Get selected restaurant from markers
  const selectedRestaurant = React.useMemo(() => {
    if (selectedRestaurantId == null) return null;
    return restaurantMarkers.find((m) => m.id === selectedRestaurantId) ?? null;
  }, [restaurantMarkers, selectedRestaurantId]);

  // Animate to selected restaurant
  React.useEffect(() => {
    if (!selectedRestaurant) return;

    const map = mapRef.current?.getMap();
    if (!map) return;

    // Smoothly center + zoom to selected restaurant
    map.flyTo({
      center: [selectedRestaurant.lng, selectedRestaurant.lat],
      zoom: Math.max(viewState.zoom, 15),
      duration: 900,
      essential: true,
      padding: { top: 180, bottom: 320, left: 40, right: 40 },
    });
  }, [selectedRestaurant?.id]);

  // Handle map mouse move for cursor changes
  const handleMapMouseMove = React.useCallback((event: MapMouseEvent) => {
    const map = mapRef.current?.getMap();
    if (!map) return;

    // When interactiveLayerIds is set, event.features contains hovered features
    const hasFeatures = (event.features?.length ?? 0) > 0;
    map.getCanvas().style.cursor = hasFeatures ? 'pointer' : '';
  }, []);

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
        // TODO: select style for the map in general, beyond the scope of the current PR since its big already
        mapStyle="mapbox://styles/mapbox/dark-v10"
        mapboxAccessToken={mapboxAccessToken}
        style={{ height: '100%', width: '100%' }}
        projection="globe"
        interactiveLayerIds={
          isPickingLocation ? undefined : ['clusters', 'unclustered-point']
        }
        onLoad={(e) => {
          const map = e.target; // Mapbox GL JS map instance

          map.setFog({
            // make "space" opaque so DOM behind can't show through
            'space-color': '#0b1020',
            'star-intensity': 0.25,
            'horizon-blend': 0.15,
          });
        }}
        ref={mapRef}
        onClick={handleMapClick}
        onMouseMove={handleMapMouseMove}
      >
        {/* Navigation Controls (Zoom +/-, Compass) */}
        <NavigationControl position="top-right" />

        {/* Geolocation Control - Native Mapbox UI for user location */}
        {enableGeolocation && (
          <GeolocateControl
            ref={geolocateControlRef}
            position="top-right"
            style={showGeolocateControlUi ? undefined : { display: 'none' }}
            positionOptions={{
              // More forgiving defaults (timeouts are common on Windows laptops)
              enableHighAccuracy: false,
              timeout: 20000,
              maximumAge: 600000, // 10 minutes
            }}
            trackUserLocation={trackUserLocation}
            showUserHeading={trackUserLocation}
            showUserLocation={true}
            onGeolocate={handleGeolocate}
            onError={handleGeolocateError}
          />
        )}

        {/* User Marker */}
        {userMarker && (
          <Marker
            key={userMarker.id}
            longitude={userMarker.lng}
            latitude={userMarker.lat}
            anchor="bottom"
          >
            <UserCircleIcon className="map-marker map-marker-user" />
          </Marker>
        )}

        {/* Restaurant Popup */}
        {selectedRestaurant && (
          <MapPopup
            restaurant={selectedRestaurant}
            onClose={() => onSelectRestaurant?.(null)}
          />
        )}

        {/* Clustering Layer - Restaurant markers */}
        <Source
          id="restaurants"
          type="geojson"
          data={restaurantGeoJson}
          cluster={true}
          clusterMaxZoom={14}
          clusterRadius={50}
        >
          <Layer {...getClusterLayer(THEME)} />
          <Layer {...getClusterCountLayer()} />
          <Layer {...getSelectedPointLayer(THEME, selectedRestaurantId)} />
          <Layer {...getUnclusteredPointLayer(THEME)} />
        </Source>
      </Map>
    </div>
  );
}
