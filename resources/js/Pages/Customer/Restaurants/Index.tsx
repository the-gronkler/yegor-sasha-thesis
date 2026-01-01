import { Head } from '@inertiajs/react';
import { IFuseOptions } from 'fuse.js';
import AppLayout from '@/Layouts/AppLayout';
import RestaurantCard from '@/Components/Shared/RestaurantCard';
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

const EMPTY_KEYS: any[] = [];

export default function RestaurantIndex({ restaurants }: RestaurantIndexProps) {
  const {
    query,
    setQuery,
    filteredItems: filteredRestaurants,
  } = useSearch(restaurants, EMPTY_KEYS, SEARCH_OPTIONS);

  return (
    <AppLayout>
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
          {filteredRestaurants.length > 0 ? (
            filteredRestaurants.map((restaurant) => (
              <RestaurantCard key={restaurant.id} restaurant={restaurant} />
            ))
          ) : (
            <div className="no-results">
              <p>No restaurants found matching "{query}".</p>
            </div>
          )}
        </div>
      </div>
    </AppLayout>
  );
}
