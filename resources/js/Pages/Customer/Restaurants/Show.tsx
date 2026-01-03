import { Head, Link, router } from '@inertiajs/react';
import { ArrowLeftIcon, HeartIcon } from '@heroicons/react/24/outline';
import { HeartIcon as HeartIconSolid } from '@heroicons/react/24/solid';
import { useState } from 'react';
import AppLayout from '@/Layouts/AppLayout';
import StarRating from '@/Components/Shared/StarRating';
import RestaurantMenu from '@/Components/Shared/RestaurantMenu';
import RestaurantReviews from '@/Components/Shared/RestaurantReviews';
import { Restaurant } from '@/types/models';
import { PageProps } from '@/types';
import { useRestaurantCart } from '@/Hooks/useRestaurantCart';
import { useAuth } from '@/Hooks/useAuth';

interface RestaurantShowProps extends PageProps {
  restaurant: Restaurant;
  isFavorited: boolean;
}

export default function RestaurantShow({
  restaurant,
  isFavorited,
}: RestaurantShowProps) {
  const { requireAuth } = useAuth();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const primaryImage =
    restaurant.images?.find((img) => img.is_primary_for_restaurant) ||
    restaurant.images?.[0];
  const bannerUrl = primaryImage ? primaryImage.url : null;

  const { cartItemCount, cartTotal, handleGoToCart } = useRestaurantCart(
    restaurant.id,
  );

  const handleToggleFavorite = () => {
    requireAuth(() => {
      if (isSubmitting) return;

      setIsSubmitting(true);
      router.post(
        route('restaurants.toggleFavorite', restaurant.id),
        {},
        {
          preserveScroll: true,
          preserveState: false, // Force props refresh to update isFavorited
          onFinish: () => setIsSubmitting(false),
        },
      );
    });
  };

  return (
    <AppLayout>
      <Head title={restaurant.name} />

      <div className="restaurant-show-page">
        {/* Banner */}
        <div
          className="restaurant-banner"
          style={bannerUrl ? { backgroundImage: `url(${bannerUrl})` } : {}}
        >
          <div className="banner-actions">
            <Link href={route('map.index')} className="back-button">
              <ArrowLeftIcon className="icon" />
            </Link>
          </div>
        </div>

        {/* Info Card */}
        <div className="restaurant-info-card">
          <h1 className="restaurant-name">{restaurant.name}</h1>
          <button
            className="favorite-button"
            onClick={handleToggleFavorite}
            disabled={isSubmitting}
            aria-label={
              isFavorited ? 'Remove from favorites' : 'Add to favorites'
            }
          >
            {isFavorited ? (
              <HeartIconSolid className="icon" />
            ) : (
              <HeartIcon className="icon" />
            )}
          </button>

          <div className="rating-container">
            <StarRating rating={restaurant.rating || 0} />
          </div>

          <div className="info-row">
            {restaurant.opening_hours ? (
              <span>Open {restaurant.opening_hours}</span>
            ) : (
              <span>Hours not available</span>
            )}
            {restaurant.distance != null ? (
              <>
                <span className="meta-separator">•</span>
                <span>{restaurant.distance.toFixed(2)} km</span>
              </>
            ) : null}
          </div>

          <p className="restaurant-description">
            {restaurant.description ||
              'The best food in the world please buy it ASAP'}
          </p>
        </div>

        {/* Menu */}
        <RestaurantMenu restaurant={restaurant} />

        {/* Reviews Section */}
        <RestaurantReviews
          restaurantId={restaurant.id}
          reviews={restaurant.reviews || []}
        />

        {/* Floating Checkout Button */}
        {cartItemCount > 0 && (
          <div className="floating-checkout-container">
            <button className="checkout-fab" onClick={handleGoToCart}>
              <div className="fab-content">
                <div className="count-badge">{cartItemCount}</div>
                <span className="fab-label">View Order</span>
                <span className="fab-total">€{cartTotal.toFixed(2)}</span>
              </div>
            </button>
          </div>
        )}
      </div>
    </AppLayout>
  );
}
