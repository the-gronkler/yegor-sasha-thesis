import { Head, Link } from '@inertiajs/react';
import {
  ArrowLeftIcon,
  HeartIcon,
  MagnifyingGlassIcon,
} from '@heroicons/react/24/outline';
import CustomerLayout from '@/Layouts/CustomerLayout';
import StarRating from '@/Components/Shared/StarRating';
import MenuItemCard from '@/Components/Shared/MenuItemCard';
import { Restaurant } from '@/types/models';
import { PageProps } from '@/types';

interface RestaurantShowProps extends PageProps {
  restaurant: Restaurant;
}

export default function RestaurantShow({ restaurant }: RestaurantShowProps) {
  const primaryImage =
    restaurant.restaurant_images?.find(
      (img) => img.is_primary_for_restaurant,
    ) || restaurant.restaurant_images?.[0];
  const bannerUrl = primaryImage ? primaryImage.url : null;

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
          <MagnifyingGlassIcon className="search-icon" aria-hidden="true" />
          <input
            type="text"
            placeholder="Search menu..."
            aria-label="Search menu"
          />
        </div>

        {/* Menu Categories */}
        {restaurant.food_types?.map((category) => (
          <div key={category.id} className="menu-category">
            <h3 className="category-title">{category.name}</h3>

            <div className="menu-items-list">
              {category.menu_items.map((item) => (
                <MenuItemCard key={item.id} item={item} />
              ))}
            </div>
          </div>
        ))}
      </div>
    </CustomerLayout>
  );
}
