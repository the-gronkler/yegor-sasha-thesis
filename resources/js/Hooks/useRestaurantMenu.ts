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

/**
 * Custom hook to manage restaurant menu display and searching.
 *
 * This hook flattens the restaurant's menu items for efficient searching using Fuse.js.
 * It returns either the original categorized menu or a flattened "Search Results" category
 * based on the current search query.
 *
 * @param {Restaurant} restaurant - The restaurant object containing menu data.
 * @returns {object} An object containing:
 *   - query: The current search query string.
 *   - setQuery: Function to update the search query.
 *   - displayedCategories: The list of food categories to display (filtered or original).
 */
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
