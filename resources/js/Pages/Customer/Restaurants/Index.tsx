import { Head, Link } from '@inertiajs/react';
import { IFuseOptions } from 'fuse.js';
import CustomerLayout from '@/Layouts/CustomerLayout';
import StarRating from '@/Components/Shared/StarRating';
import SearchInput from '@/Components/UI/SearchInput';
import { useSearch } from '@/Hooks/useSearch';
import { Restaurant } from '@/types/models';
import { PageProps } from '@/types';

interface RestaurantIndexProps extends PageProps {
  restaurants: Restaurant[];
}

const SEARCH_OPTIONS: IFuseOptions<Restaurant> = {
  keys: [
    { name: 'name', weight: 2 },
    { name: 'description', weight: 1.5 },
    { name: 'food_types.name', weight: 1 },
    { name: 'food_types.menu_items.name', weight: 0.5 },
  ],
};

export default function RestaurantIndex({ restaurants }: RestaurantIndexProps) {
  const {
    query,
    setQuery,
    filteredItems: filteredRestaurants,
  } = useSearch(restaurants, [], SEARCH_OPTIONS);

  return (
    <CustomerLayout>
      <Head title="Explore Restaurants" />

      <div className="restaurant-index-page">
        {/* Search Bar */}
        <div className="search-header">
          <SearchInput
            value={query}
            onChange={setQuery}
            placeholder="Search restaurants..."
          />
        </div>

        {/* Restaurant List */}
        <div className="restaurant-list">
          {filteredRestaurants.map((restaurant) => {
            const primaryImage =
              restaurant.images?.find((img) => img.is_primary_for_restaurant) ||
              restaurant.images?.[0];
            const imageUrl = primaryImage
              ? primaryImage.url
              : '/images/placeholder-restaurant.jpg';

            return (
              <Link
                key={restaurant.id}
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
                        <span className="meta-item">
                          {restaurant.opening_hours}
                        </span>
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
          })}
        </div>
      </div>
    </CustomerLayout>
  );
}
