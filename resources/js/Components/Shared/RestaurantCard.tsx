import { Link } from '@inertiajs/react';
import StarRating from '@/Components/Shared/StarRating';
import { Restaurant } from '@/types/models';

interface RestaurantCardProps {
  restaurant: Restaurant;
}

export default function RestaurantCard({ restaurant }: RestaurantCardProps) {
  const primaryImage =
    restaurant.images?.find((img) => img.is_primary_for_restaurant) ||
    restaurant.images?.[0];
  const imageUrl = primaryImage
    ? primaryImage.url
    : '/images/placeholder-restaurant.jpg';

  return (
    <Link
      href={route('restaurants.show', restaurant.id)}
      className="restaurant-card-link"
    >
      <div className="restaurant-card">
        {/* Restaurant Image */}
        <div className="restaurant-image-wrapper">
          <img
            src={imageUrl}
            alt={restaurant.name}
            className="restaurant-image"
          />
        </div>

        {/* Restaurant Info */}
        <div className="restaurant-info">
          <div className="restaurant-header">
            <h3 className="restaurant-name">{restaurant.name}</h3>
            <StarRating rating={restaurant.rating || 0} />
          </div>

          <div className="restaurant-meta">
            {restaurant.opening_hours ? (
              <span className="meta-item">{restaurant.opening_hours}</span>
            ) : (
              <span className="meta-item">Hours not available</span>
            )}
            <span className="meta-separator">•</span>
            <span className="meta-item">~3km</span>
          </div>

          <p className="restaurant-description">
            {restaurant.description ||
              'The best food in the world please buy it ASAP'}
          </p>
        </div>
      </div>
    </Link>
  );
}
