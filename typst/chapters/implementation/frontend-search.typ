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
    searchKeys: Array<keyof T>,
    options?: Partial<IFuseOptions<T>>
  ): {
    query: string;
    setQuery: (query: string) => void;
    filteredItems: T[];
  }
  ```
]

The generic type parameter `T` enables the hook to work with any data structure while maintaining type safety. TypeScript verifies that `searchKeys` reference actual properties of `T`, preventing runtime errors from invalid property access.

===== Fuse.js Configuration and Caching

The hook configures Fuse.js with defaults optimized for typical restaurant discovery use cases. The configuration balances match tolerance with result relevance.

#code_example[
  Default Fuse.js configuration prioritizes relevant matches with location-agnostic search.

  ```typescript
  const defaultOptions: IFuseOptions<T> = {
    keys: searchKeys as string[],
    threshold: 0.3,
    ignoreLocation: true,
    includeScore: true,
    shouldSort: true,
  };

  const fuseOptions = { ...defaultOptions, ...options };
  ```
]

Configuration parameters control matching behavior:
- `threshold: 0.3`: Requires 70% match quality, filtering very distant matches while allowing minor typos
- `ignoreLocation: true`: Matches anywhere in text, not requiring match at string start
- `includeScore: true`: Enables relevance-based result ordering
- `shouldSort: true`: Orders results by match quality

The Fuse.js instance creation is wrapped in `useMemo` to prevent redundant instantiation on unrelated component re-renders.

#code_example[
  Memoization prevents unnecessary Fuse.js instance creation when dependencies are stable.

  ```typescript
  const fuse = useMemo(
    () => new Fuse(items, { ...defaultOptions, ...options }),
    [items, searchKeys, options]
  );
  ```
]

The dependency array ensures the Fuse instance updates when items, search keys, or options change, triggering reindexing only when necessary.

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

While the hook provides general-purpose fuzzy search, specific features require tailored configurations with weighted keys for relevance tuning.

#code_example[
  Restaurant search weights name and description higher than nested menu items.

  ```typescript
  const { query, setQuery, filteredItems } = useSearch(
    restaurants,
    ['name', 'description', 'food_types.menu_items.name'],
    {
      keys: [
        { name: 'name', weight: 0.5 },
        { name: 'description', weight: 0.3 },
        { name: 'food_types.menu_items.name', weight: 0.2 },
      ],
    }
  );
  ```
]

The weight distribution reflects search intent: users searching restaurants prioritize restaurant names, secondarily consider descriptions, and only tangentially care about specific menu items. This prevents a restaurant with matching menu items but unrelated name from outranking a restaurant with matching name.

#code_example[
  Menu filtering prioritizes item names over descriptions and categories.

  ```typescript
  const { filteredItems } = useSearch(
    menuItems,
    ['name', 'description', 'food_type.name'],
    {
      keys: [
        { name: 'name', weight: 0.6 },
        { name: 'description', weight: 0.25 },
        { name: 'food_type.name', weight: 0.15 },
      ],
    }
  );
  ```
]

===== Constraints and Trade-offs

Client-side search operates only on data already loaded to the client. This constraint has performance and completeness implications:

*Performance*: For datasets under several hundred items, client-side filtering provides instant feedback with minimal CPU cost. The approach avoids network latency entirely.

*Completeness*: Search results are limited to items already returned from the backend. If a restaurant list loads 50 nearby restaurants, searching can only filter within those 50. Users cannot discover restaurants beyond the initial dataset without requesting more data from the server.

The architecture accepts this trade-off because:
1. Restaurant discovery already filters by proximity, so the subset is relevant.
2. Menu browsing operates within a single restaurant's items (complete dataset).
3. Instant feedback improves perceived performance compared to server-side search with network delays.

For use cases requiring comprehensive search across entire databases (administrative search, analytics), server-side search with database indexing would be necessary.
