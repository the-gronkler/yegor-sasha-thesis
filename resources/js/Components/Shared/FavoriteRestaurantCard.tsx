import { DragEvent } from 'react';
import { router } from '@inertiajs/react';
import {
  Bars3Icon,
  HeartIcon as HeartIconSolid,
  StarIcon,
} from '@heroicons/react/24/solid';
import { Restaurant } from '@/types/models';

interface FavoriteRestaurantCardProps {
  restaurant: Restaurant;
  onRemove: (id: number) => void;
  isRemoving: boolean;
  onDragStart: (e: DragEvent<HTMLDivElement>, id: number) => void;
  onDragOver: (e: DragEvent<HTMLDivElement>) => void;
  onDrop: (e: DragEvent<HTMLDivElement>, id: number) => void;
  isDragging: boolean;
  isSavingOrder?: boolean;
}

export default function FavoriteRestaurantCard({
  restaurant,
  onRemove,
  isRemoving,
  onDragStart,
  onDragOver,
  onDrop,
  isDragging,
  isSavingOrder,
}: FavoriteRestaurantCardProps) {
  const primaryImage =
    restaurant.images?.find((img) => img.is_primary_for_restaurant) ||
    restaurant.images?.[0];
  const imageUrl = primaryImage
    ? primaryImage.url
    : '/images/placeholder-restaurant.jpg';

  const handleCardClick = () => {
    router.visit(route('restaurants.show', restaurant.id));
  };

  const handleRemoveClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    onRemove(restaurant.id);
  };

  return (
    <div
      className={`favorite-restaurant-card ${isDragging ? 'is-dragging' : ''}`}
      draggable={!isSavingOrder}
      onDragStart={(e) => onDragStart(e, restaurant.id)}
      onDragOver={onDragOver}
      onDrop={(e) => onDrop(e, restaurant.id)}
    >
      {/* Drag Handle */}
      <div className="drag-handle" title="Drag to reorder">
        <Bars3Icon className="drag-icon" />
      </div>

      {/* Rank Badge */}
      <div className="rank-badge">#{restaurant.rank}</div>

      {/* Restaurant Content - Clickable */}
      <div className="restaurant-card-content" onClick={handleCardClick}>
        {/* Image */}
        <div className="restaurant-image-wrapper">
          <img
            src={imageUrl}
            alt={restaurant.name}
            className="restaurant-image"
          />
        </div>

        {/* Info */}
        <div className="restaurant-info">
          <div className="restaurant-header">
            <h3 className="restaurant-name">{restaurant.name}</h3>

            {restaurant.rating && (
              <span className="rating-badge">
                <StarIcon className="star-icon" />
                <span className="rating-text">
                  {restaurant.rating.toFixed(1)}
                </span>
              </span>
            )}
          </div>

          <div className="restaurant-meta">
            {restaurant.opening_hours ? (
              <span className="meta-item">{restaurant.opening_hours}</span>
            ) : (
              <span className="meta-item">Hours not available</span>
            )}
          </div>

          {restaurant.description && (
            <p className="restaurant-description">{restaurant.description}</p>
          )}

          {restaurant.address && (
            <p className="restaurant-address">{restaurant.address}</p>
          )}
        </div>
      </div>

      {/* Remove Button */}
      <button
        className="remove-favorite-btn"
        onClick={handleRemoveClick}
        disabled={isRemoving || isSavingOrder}
        aria-label="Remove from favorites"
        title="Remove from favorites"
      >
        <HeartIconSolid className="heart-icon" />
      </button>
    </div>
  );
}
