import { useState, MouseEvent, KeyboardEvent } from 'react';
import { router } from '@inertiajs/react';
import StarRating from '@/Components/Shared/StarRating';
import { Restaurant } from '@/types/models';

interface RestaurantCardProps {
  restaurant: Restaurant;
  selected?: boolean;
  onSelect?: () => void;
  containerRef?: (el: HTMLDivElement | null) => void;
}

export default function RestaurantCard({
  restaurant,
  selected = false,
  onSelect,
  containerRef,
}: RestaurantCardProps) {
  const [focused, setFocused] = useState(false);

  const primaryImage =
    restaurant.images?.find((img) => img.is_primary_for_restaurant) ||
    restaurant.images?.[0];
  const imageUrl = primaryImage
    ? primaryImage.url
    : '/images/placeholder-restaurant.jpg';

  // --- Handlers (Extracted for Readability) ---

  const handleCardClick = () => {
    onSelect?.();
  };

  const handleViewDetails = (e: MouseEvent) => {
    // Stop the click from bubbling up to the card's onSelect handler
    e.stopPropagation();
    router.visit(route('restaurants.show', restaurant.id));
  };

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Enter') {
      router.visit(route('restaurants.show', restaurant.id));
    } else if (e.key === ' ') {
      e.preventDefault(); // Prevent page scroll
      onSelect?.();
    }
  };

  return (
    <div
      ref={containerRef}
      className={`restaurant-card ${selected ? 'is-selected' : ''} ${
        focused ? 'is-focused' : ''
      }`}
      role="button"
      tabIndex={0}
      aria-expanded={selected}
      onClick={handleCardClick}
      onKeyDown={handleKeyDown}
      onFocus={() => setFocused(true)}
      onBlur={() => setFocused(false)}
    >
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

        {/* Collapsible details section */}
        <div className="restaurant-details">
          <div>
            <p className="restaurant-description">
              {restaurant.description || 'No description available'}
            </p>
            <div className="restaurant-actions">
              {/* Added onClick handler directly to the button */}
              <button
                type="button"
                className="restaurant-view-btn"
                tabIndex={-1}
                onClick={handleViewDetails}
              >
                View details
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
