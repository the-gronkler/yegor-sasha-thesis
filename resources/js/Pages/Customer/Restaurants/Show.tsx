import { useMemo } from 'react';
import { Head, Link, router } from '@inertiajs/react';
import {
  ArrowLeftIcon,
  HeartIcon,
  ShoppingBagIcon,
} from '@heroicons/react/24/outline';
import { IFuseOptions } from 'fuse.js';
import CustomerLayout from '@/Layouts/CustomerLayout';
import StarRating from '@/Components/Shared/StarRating';
import MenuItemCard from '@/Components/Shared/MenuItemCard';
import SearchInput from '@/Components/UI/SearchInput';
import { useSearch } from '@/Hooks/useSearch';
import { Restaurant, MenuItem } from '@/types/models';
import { PageProps } from '@/types';
import { useCart } from '@/Contexts/CartContext';

interface RestaurantShowProps extends PageProps {
  restaurant: Restaurant;
}

type MenuItemWithCategory = MenuItem & { category_name: string };

const SEARCH_OPTIONS: IFuseOptions<MenuItemWithCategory> = {
  keys: [
    { name: 'name', weight: 2 },
    { name: 'description', weight: 1.5 },
    { name: 'category_name', weight: 0.5 },
  ],
};

const EMPTY_KEYS: any[] = [];

export default function RestaurantShow({ restaurant }: RestaurantShowProps) {
  const primaryImage =
    restaurant.restaurant_images?.find(
      (img) => img.is_primary_for_restaurant,
    ) || restaurant.restaurant_images?.[0];
  const bannerUrl = primaryImage ? primaryImage.url : null;

  // Flatten menu items for searching
  const allMenuItems = useMemo(
    () =>
      restaurant.food_types?.flatMap((ft) =>
        ft.menu_items.map((item) => ({ ...item, category_name: ft.name })),
      ) || [],
    [restaurant.food_types],
  );

  const {
    query,
    setQuery,
    filteredItems: filteredMenuItems,
  } = useSearch<MenuItemWithCategory>(allMenuItems, EMPTY_KEYS, SEARCH_OPTIONS);

  // Group filtered items back into categories
  const displayedCategories = useMemo(() => {
    if (!query) return restaurant.food_types;

    if (filteredMenuItems.length === 0) return [];

    return [
      {
        id: -1,
        name: 'Search Results',
        menu_items: filteredMenuItems,
      },
    ];
  }, [query, restaurant.food_types, filteredMenuItems]);

  const { items, getOrderId } = useCart();

  const restaurantCartItems = useMemo(
    () => items.filter((item) => item.restaurant_id === restaurant.id),
    [items, restaurant.id],
  );

  const cartItemCount = restaurantCartItems.reduce(
    (sum, item) => sum + item.quantity,
    0,
  );

  const cartTotal = restaurantCartItems.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0,
  );

  const handleGoToCheckout = () => {
    const orderId = getOrderId(restaurant.id);
    if (orderId) {
      router.visit(route('checkout.show', { order: orderId }));
    } else {
      // Fallback if order ID is not yet available (e.g. optimistic update pending)
      // In a real app, we might want to wait or show a loading state.
      // For now, fallback to cart index which will have the order.
      router.visit(route('cart.index'));
    }
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
          <button className="favorite-button" aria-label="Add to favorites">
            <HeartIcon className="icon" />
          </button>

          <div
            style={{
              display: 'flex',
              justifyContent: 'center',
              marginBottom: '0.5rem',
            }}
          >
            <StarRating rating={restaurant.rating || 0} />
          </div>

          <div className="info-row">
            {restaurant.opening_hours ? (
              <span>Open {restaurant.opening_hours}</span>
            ) : (
              <span>Hours not available</span>
            )}
            <span>~3km</span> {/* Placeholder data */}
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

        {/* Floating Checkout Button */}
        {cartItemCount > 0 && (
          <div className="floating-checkout-container">
            <button className="checkout-fab" onClick={handleGoToCheckout}>
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
