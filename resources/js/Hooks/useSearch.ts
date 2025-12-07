import { useState, useMemo } from 'react';
import Fuse, { IFuseOptions } from 'fuse.js';

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
  }, [items, searchKeys, options]);

  const filteredItems = useMemo(() => {
    if (!query) return items;
    return fuse.search(query).map((result) => result.item);
  }, [fuse, query, items]);

  return { query, setQuery, filteredItems };
}
