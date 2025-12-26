import { Head, Link, usePage } from '@inertiajs/react';
import { ArrowLeftIcon, HeartIcon } from '@heroicons/react/24/outline';
import CustomerLayout from '@/Layouts/CustomerLayout';
import StarRating from '@/Components/Shared/StarRating';
import MenuItemCard from '@/Components/Shared/MenuItemCard';
import SearchInput from '@/Components/UI/SearchInput';
import { Restaurant } from '@/types/models';
import { PageProps } from '@/types';
import { useRestaurantCart } from '@/Hooks/useRestaurantCart';
import { useRestaurantMenu } from '@/Hooks/useRestaurantMenu';
import RestaurantReviews from '@/Components/Shared/RestaurantReviews';
import { useAuth } from '@/Hooks/useAuth';

interface RestaurantShowProps extends PageProps {
  restaurant: Restaurant;
}

export default function RestaurantShow({ restaurant }: RestaurantShowProps) {
  const { requireAuth } = useAuth();
  const primaryImage =
    restaurant.images?.find((img) => img.is_primary_for_restaurant) ||
    restaurant.images?.[0];
  const bannerUrl = primaryImage ? primaryImage.url : null;

  const { query, setQuery, displayedCategories } =
    useRestaurantMenu(restaurant);

  const { cartItemCount, cartTotal, handleGoToCart } = useRestaurantCart(
    restaurant.id,
  );

  const handleFavoriteClick = () => {
    requireAuth(() => {
      // TODO: Implement favorite logic
    });
  };

  return (
    <CustomerLayout>
      <Head title={restaurant.name} />

      <div className="restaurant-show-page">
        {/* Banner */}
        <div
          className="restaurant-banner"
          style={bannerUrl ? { backgroundImage: `url(${bannerUrl})` } : {}}
        >
          <div className="banner-actions">
            <Link href={route('restaurants.index')} className="back-button">
              <ArrowLeftIcon className="icon" />
            </Link>
          </div>
        </div>

        {/* Info Card */}
        <div className="restaurant-info-card">
          <h1 className="restaurant-name">{restaurant.name}</h1>
          <button
            className="favorite-button"
            aria-label="Add to favorites"
            onClick={handleFavoriteClick}
          >
            <HeartIcon className="icon" />
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

        {/* Search */}
        <div className="menu-search">
          <SearchInput
            value={query}
            onChange={setQuery}
            placeholder="Search menu..."
          />
        </div>

        {/* Menu Categories */}
        {displayedCategories?.length ? (
          displayedCategories.map((category) => (
            <div key={category.id} className="menu-category">
              <h3 className="category-title">{category.name}</h3>

              <div className="menu-items-list">
                {category.menu_items.map((item) => (
                  // TODO add '-' button to reduce quantity if > 0
                  <MenuItemCard
                    key={item.id}
                    item={item}
                    restaurantId={restaurant.id}
                  />
                ))}
              </div>
            </div>
          ))
        ) : query ? (
          <div className="no-results">
            <p>No menu items found matching "{query}".</p>
          </div>
        ) : null}

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
    </CustomerLayout>
  );
}
