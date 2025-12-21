import { useMemo } from 'react';
import { IFuseOptions } from 'fuse.js';
import { useSearch } from '@/Hooks/useSearch';
import { Restaurant, MenuItem, FoodType } from '@/types/models';

type MenuItemWithCategory = MenuItem & { category_name: string };

const SEARCH_OPTIONS: IFuseOptions<MenuItemWithCategory> = {
  keys: [
    { name: 'name', weight: 2 },
    { name: 'description', weight: 1.5 },
    { name: 'category_name', weight: 0.5 },
  ],
};

const EMPTY_KEYS: any[] = [];

export function useRestaurantMenu(restaurant: Restaurant) {
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
      } as FoodType,
    ];
  }, [query, restaurant.food_types, filteredMenuItems]);

  return {
    query,
    setQuery,
    displayedCategories,
  };
}
