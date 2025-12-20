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
          {/* TODO: Use the restaurant's actual props here. */}
          <div className="restaurant-meta">
            {restaurant.opening_hours ? (
              <span className="meta-item">{restaurant.opening_hours}</span>
            ) : (
              <span className="meta-item">Hours not available</span>
            )}
            {restaurant.distance !== undefined &&
              restaurant.distance !== null && (
                <>
                  <span className="meta-separator">•</span>
                  <span className="meta-item">{restaurant.distance} km</span>
                </>
              )}
          </div>
          <p className="restaurant-description">
            {restaurant.description || 'No description available'}
          </p>
        </div>
      </div>
    </Link>
  );
}
