import { useState, useMemo } from 'react';
import Fuse, { IFuseOptions } from 'fuse.js';

/**
 * A custom React hook that provides fuzzy search functionality over an array of items using Fuse.js.
 * It manages the search query state and returns filtered items based on the query.
 *
 * @template T - The type of items in the array.
 * @param items - The array of items to search through. Each item should be an object with properties matching the searchKeys.
 * @param searchKeys - An array of keys (properties) of the items to perform the search on. These must be valid keys of type T. Can be empty if keys are provided in options.
 * @param options - Optional configuration options for Fuse.js, such as threshold, ignoreLocation, etc. These will be merged with default options.
 *                  If keys are provided here (e.g. with weights), they will override searchKeys.
 * @returns An object containing:
 *   - `query`: The current search query string.
 *   - `setQuery`: A function to update the search query.
 *   - `filteredItems`: The array of items filtered based on the search query. If no query is provided, returns the original items array.
 *
 * @example
 * ```tsx
 * // Simple usage
 * const { query, setQuery, filteredItems } = useSearch(
 *   [{ name: 'Apple', category: 'Fruit' }, { name: 'Banana', category: 'Fruit' }],
 *   ['name', 'category']
 * );
 *
 * // Usage with weighted keys
 * const { query, setQuery, filteredItems } = useSearch(
 *   items,
 *   [],
 *   {
 *     keys: [
 *       { name: 'name', weight: 2 },
 *       { name: 'description', weight: 1 }
 *     ]
 *   }
 * );
 * ```
 */
export function useSearch<T>(
  items: T[],
  searchKeys: (keyof T)[],
  options?: IFuseOptions<T>,
) {
  const [query, setQuery] = useState('');

  const fuse = useMemo(() => {
    const defaultOptions: IFuseOptions<T> = {
      keys: searchKeys as string[],
      threshold: 0.3, // 0.0 = exact match, 1.0 = match anything
      ignoreLocation: true, // Find matches anywhere in the string
      includeScore: true,
    };

    return new Fuse(items, { ...defaultOptions, ...options });
  }, [items, searchKeys, JSON.stringify(options)]);

  const filteredItems = useMemo(() => {
    if (!query) return items;
    return fuse.search(query).map((result) => result.item);
  }, [fuse, query, items]);

  return { query, setQuery, filteredItems };
}
