import { Link } from '@inertiajs/react';
import { Popup } from 'react-map-gl/mapbox';
import StarRating from '@/Components/Shared/StarRating';
import { MapMarker } from '@/types/models';

interface Props {
  restaurant: MapMarker;
  onClose: () => void;
}

export default function MapPopup({ restaurant, onClose }: Props) {
  return (
    <Popup
      className="restaurant-popup"
      longitude={restaurant.lng}
      latitude={restaurant.lat}
      anchor="bottom"
      offset={16}
      closeButton={false}
      closeOnClick={false}
      onClose={onClose}
      maxWidth="360px"
      focusAfterOpen={false}
    >
      <div className="map-popup-card" onClick={(e) => e.stopPropagation()}>
        <button
          type="button"
          className="map-popup-close"
          onClick={onClose}
          aria-label="Close popup"
        >
          <span aria-hidden="true">×</span>
        </button>

        {restaurant.imageUrl ? (
          <div className="map-popup-image">
            <img src={restaurant.imageUrl} alt={restaurant.name} />
          </div>
        ) : null}

        <div className="map-popup-header">
          <h3 className="map-popup-title">{restaurant.name}</h3>
          {typeof restaurant.rating === 'number' ? (
            <div className="map-popup-rating">
              <StarRating rating={restaurant.rating} />
            </div>
          ) : null}
        </div>

        <div className="map-popup-body">
          <div className="map-popup-meta">
            {restaurant.distanceKm != null ? (
              <span>{restaurant.distanceKm} km</span>
            ) : null}
            {restaurant.openingHours ? (
              <span>• {restaurant.openingHours}</span>
            ) : null}
          </div>

          {restaurant.address ? (
            <p className="map-popup-description">{restaurant.address}</p>
          ) : null}

          <Link
            href={route('restaurants.show', restaurant.id)}
            className="restaurant-view-btn"
          >
            View details
          </Link>
        </div>
      </div>
    </Popup>
  );
}
