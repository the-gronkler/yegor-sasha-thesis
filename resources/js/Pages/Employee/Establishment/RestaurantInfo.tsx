import { FormEventHandler, useEffect, useRef, useState } from 'react';
import AppLayout from '@/Layouts/AppLayout';
import { Head, Link, useForm } from '@inertiajs/react';
import { ArrowLeftIcon, MapPinIcon } from '@heroicons/react/24/outline';
import { Restaurant, MapMarker } from '@/types/models';
import { PageProps } from '@/types';
import Button from '@/Components/UI/Button';
import Map from '@/Components/Shared/Map';

interface RestaurantInfoProps extends PageProps {
  restaurant: Restaurant;
  mapboxPublicKey?: string;
}

export default function RestaurantInfo({
  restaurant,
  mapboxPublicKey,
}: RestaurantInfoProps) {
  const { data, setData, put, processing, errors } = useForm({
    name: restaurant.name,
    address: restaurant.address,
    description: restaurant.description || '',
    opening_hours: restaurant.opening_hours || '',
    latitude: restaurant.latitude || null,
    longitude: restaurant.longitude || null,
  });

  const openingHoursRef = useRef<HTMLTextAreaElement>(null);
  const descriptionRef = useRef<HTMLTextAreaElement>(null);
  const [showMap, setShowMap] = useState(false);

  // Initialize viewState based on restaurant coordinates or default
  const [viewState, setViewState] = useState({
    latitude: restaurant.latitude || 40.7128,
    longitude: restaurant.longitude || -74.006,
    zoom: restaurant.latitude && restaurant.longitude ? 10 : 8,
  });

  // Create marker for selected location
  const markers: MapMarker[] =
    data.latitude && data.longitude
      ? [
          {
            id: restaurant.id,
            lat: data.latitude,
            lng: data.longitude,
            name: data.name,
            address: data.address,
          },
        ]
      : [];

  // Auto-resize textarea function
  const autoResize = (textarea: HTMLTextAreaElement | null) => {
    if (textarea) {
      textarea.style.height = 'auto';
      textarea.style.height = textarea.scrollHeight + 'px';
    }
  };

  // Auto-resize on mount and when data changes
  useEffect(() => {
    autoResize(openingHoursRef.current);
    autoResize(descriptionRef.current);
  }, [data.opening_hours, data.description]);

  const handlePickLocation = (lat: number, lng: number) => {
    setData({
      ...data,
      latitude: lat,
      longitude: lng,
    });
    setViewState({
      latitude: lat,
      longitude: lng,
      zoom: 15,
    });
  };

  const handleSubmit: FormEventHandler = (e) => {
    e.preventDefault();
    put(route('employee.establishment.restaurant.update'));
  };

  return (
    <AppLayout>
      <Head title="Restaurant Information" />

      <div className="profile-page">
        {/* Header */}
        <div className="profile-header">
          <Link
            href={route('employee.establishment.index')}
            className="back-button-link"
          >
            <ArrowLeftIcon className="icon" />
            <span>Back</span>
          </Link>
          <h1 className="profile-title">Restaurant Information</h1>
        </div>

        {/* Restaurant Form */}
        <div className="profile-card">
          <form onSubmit={handleSubmit} className="profile-form">
            <div className="form-group">
              <label htmlFor="name">Restaurant Name</label>
              <input
                id="name"
                type="text"
                className="form-input"
                value={data.name}
                onChange={(e) => setData('name', e.target.value)}
                required
              />
              {errors.name && <p className="error-message">{errors.name}</p>}
            </div>

            <div className="form-group">
              <label htmlFor="address">Address</label>
              <input
                id="address"
                type="text"
                className="form-input"
                value={data.address}
                onChange={(e) => setData('address', e.target.value)}
                required
              />
              {errors.address && (
                <p className="error-message">{errors.address}</p>
              )}
            </div>

            <div className="form-group">
              <label htmlFor="opening_hours">Opening Hours</label>
              <textarea
                ref={openingHoursRef}
                id="opening_hours"
                className="form-input auto-resize-textarea"
                value={data.opening_hours}
                onChange={(e) => setData('opening_hours', e.target.value)}
                onInput={(e) => autoResize(e.currentTarget)}
                placeholder="e.g., Mon-Fri: 9AM-10PM, Sat-Sun: 10AM-11PM"
                rows={3}
              />
              {errors.opening_hours && (
                <p className="error-message">{errors.opening_hours}</p>
              )}
            </div>

            <div className="form-group">
              <label htmlFor="description">Description</label>
              <textarea
                ref={descriptionRef}
                id="description"
                className="form-input auto-resize-textarea"
                value={data.description}
                onChange={(e) => setData('description', e.target.value)}
                onInput={(e) => autoResize(e.currentTarget)}
                placeholder="Tell customers about your restaurant..."
                rows={4}
              />
              {errors.description && (
                <p className="error-message">{errors.description}</p>
              )}
            </div>

            {/* Location Picker */}
            <div className="form-group">
              <label htmlFor="location">Location</label>
              <div className="location-picker">
                <button
                  type="button"
                  onClick={() => setShowMap(!showMap)}
                  className="location-toggle-btn"
                >
                  <MapPinIcon className="icon" />
                  <span>
                    {data.latitude && data.longitude
                      ? `Location: ${data.latitude.toFixed(6)}, ${data.longitude.toFixed(6)}`
                      : 'Click to select location on map'}
                  </span>
                </button>

                {showMap && mapboxPublicKey && (
                  <div className="map-container">
                    <p className="map-instruction">
                      Click on the map to set your restaurant's location
                    </p>
                    <Map
                      viewState={viewState}
                      onMove={setViewState}
                      mapboxAccessToken={mapboxPublicKey}
                      isPickingLocation={true}
                      onPickLocation={handlePickLocation}
                      markers={markers}
                      className="location-map"
                      enableGeolocation={true}
                      showGeolocateControlUi={true}
                    />
                    {data.latitude && data.longitude && (
                      <p className="map-coordinates">
                        Selected: {data.latitude.toFixed(6)},{' '}
                        {data.longitude.toFixed(6)}
                      </p>
                    )}
                  </div>
                )}

                {errors.latitude && (
                  <p className="error-message">{errors.latitude}</p>
                )}
                {errors.longitude && (
                  <p className="error-message">{errors.longitude}</p>
                )}
              </div>
            </div>

            <div className="section-divider">
              <Button
                type="submit"
                disabled={processing}
                className="btn-submit"
              >
                Save Changes
              </Button>
            </div>
          </form>
        </div>
      </div>
    </AppLayout>
  );
}
