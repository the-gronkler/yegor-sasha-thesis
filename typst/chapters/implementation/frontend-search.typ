#import "../../config.typ": code_example, source_code_link

==== Client-Side Search Implementation

The search implementation provides instant filtering feedback for restaurant and menu item discovery without server round-trips. The implementation uses Fuse.js wrapped in a reusable custom hook that applies fuzzy matching with configurable relevance weights.

===== Reusable useSearch Hook

The #source_code_link("resources/js/Hooks/useSearch.ts") hook encapsulates the Fuse.js integration and search state management. The hook accepts a data array, searchable property keys, and optional configuration, returning filtered results and query state management functions.

#code_example[
  The `useSearch` hook signature provides flexible configuration with sensible defaults.

  ```typescript
  export function useSearch<T>(
    items: T[],
    searchKeys: (keyof T)[],
    options?: IFuseOptions<T>
  ): {
    query: string;
    setQuery: (query: string) => void;
    filteredItems: T[];
  }
  ```
]

The generic type parameter `T` enables the hook to work with any data structure while maintaining type safety. TypeScript verifies that `searchKeys` reference actual properties of `T`, preventing runtime errors from invalid property access.

===== Generic Configuration with Context-Specific Customization

#code_example[
    The hook's design separates the generic search mechanism from domain-specific configuration. Default settings  provide sensible behavior across all use cases, while the `options` parameter enables callers to customize search behavior for their specific data structures.

 ```typescript
  const defaultOptions: IFuseOptions<T> = {
    keys: searchKeys as string[],
    threshold: 0.3,
    ignoreLocation: true,
    includeScore: true,
    shouldSort: true,
  };
  ```
]

This reusability is the key advantage: the same hook powers restaurant search, menu item filtering, and order history search by simply passing different data types and searchable keys. The Fuse.js instance is memoized to avoid reindexing on unrelated re-renders. #source_code_link("resources/js/Hooks/useSearch.ts")

===== Filtering Logic and Empty Query Optimization

The filtering logic distinguishes between empty and populated queries. Empty queries return the unfiltered dataset immediately, avoiding unnecessary Fuse.js processing.

#code_example[
  Filtered results compute only when query is non-empty.

  ```typescript
  const filteredItems = useMemo(() => {
    if (!query) {
      return items;
    }
    return fuse.search(query).map(result => result.item);
  }, [fuse, query]);
  ```
]

This optimization matters for large datasets where Fuse.js processing has measurable cost. When users clear the search box, the full dataset displays instantly without recomputation.

===== Context-Specific Configurations

While the hook provides general-purpose fuzzy search, specific features supply tailored weighted key configurations for relevance tuning.

#code_example[
  Restaurant search weights name highest, then description, food type categories, and nested menu item names, reflecting typical search intent.

  ```typescript
  const SEARCH_OPTIONS: IFuseOptions<Restaurant> = {
    keys: [
      { name: 'name', weight: 2 },
      { name: 'description', weight: 1.5 },
      { name: 'food_types.name', weight: 1 },
      { name: 'food_types.menu_items.name', weight: 0.5 },
    ],
  };

  const { query, setQuery, filteredItems } = useSearch(
    restaurants,
    [],
    SEARCH_OPTIONS
  );
  ```
]

This weight distribution ensures a restaurant with a matching name outranks one that merely contains a matching menu item. Other search contexts, such as menu item filtering, apply analogous weight distributions tuned to their respective data structures.

===== Constraints and Trade-offs

Client-side search operates only on data already loaded to the client. This constraint has performance and completeness implications:

*Performance*: For datasets under several hundred items, client-side filtering provides instant feedback with minimal CPU cost. The approach avoids network latency entirely.

*Completeness*: Search results are limited to items already returned from the backend. If a restaurant list loads 50 nearby restaurants, searching can only filter within those 50. Users cannot discover restaurants beyond the initial dataset without requesting more data from the server.

The architecture accepts this trade-off because:
1. Restaurant discovery already filters by proximity, so the subset is relevant.
2. Menu browsing operates within a single restaurant's items (complete dataset).
3. Instant feedback improves perceived performance compared to server-side search with network delays.

For use cases requiring comprehensive search across entire databases (administrative search, analytics), server-side search with database indexing would be necessary.
