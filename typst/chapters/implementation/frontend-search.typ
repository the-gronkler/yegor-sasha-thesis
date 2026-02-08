#import "../../config.typ": code_example, source_code_link

==== Client-Side Search Implementation

The search implementation provides instant filtering feedback for restaurant and menu item discovery without server round-trips. The implementation uses Fuse.js wrapped in a reusable custom hook that applies fuzzy matching with configurable relevance weights.

===== Reusable useSearch Hook

The #source_code_link("resources/js/Hooks/useSearch.ts") hook encapsulates the Fuse.js integration and search state management. The hook accepts a generic data array, searchable property keys, and optional configuration, returning filtered results and query state management functions. The generic type parameter `T` enables the hook to work with any data structure while maintaining type safety. TypeScript verifies that `searchKeys` reference actual properties of `T`, preventing runtime errors from invalid property access.

===== Fuse.js Configuration and Caching

The hook configures Fuse.js with defaults optimized for typical restaurant discovery use cases: threshold of 0.3 (requires 70% match quality), `ignoreLocation: true` (matches anywhere in text), `includeScore: true` (enables relevance ordering), and `shouldSort: true`. The Fuse.js instance creation is wrapped in `useMemo` to prevent redundant instantiation on unrelated component re-renders, with a dependency array ensuring reindexing only when items, search keys, or options change.

===== Filtering Logic and Empty Query Optimization

The filtering logic distinguishes between empty and populated queries. Empty queries return the unfiltered dataset immediately, avoiding unnecessary Fuse.js processing. This optimization matters for large datasets where Fuse.js processing has measurable cost. When users clear the search box, the full dataset displays instantly without recomputation.

===== Context-Specific Configurations

While the hook provides general-purpose fuzzy search, specific features require tailored configurations with weighted keys for relevance tuning. Restaurant search weights name (0.5) and description (0.3) higher than nested menu items (0.2), reflecting search intent where users prioritize restaurant names and secondarily consider descriptions. Menu filtering prioritizes item names (0.6) over descriptions (0.25) and categories (0.15).

===== Constraints and Trade-offs

Client-side search operates only on data already loaded to the client. This constraint has performance and completeness implications:

*Performance*: For datasets under several hundred items, client-side filtering provides instant feedback with minimal CPU cost. The approach avoids network latency entirely.

*Completeness*: Search results are limited to items already returned from the backend. If a restaurant list loads 50 nearby restaurants, searching can only filter within those 50. Users cannot discover restaurants beyond the initial dataset without requesting more data from the server.

The architecture accepts this trade-off because:
1. Restaurant discovery already filters by proximity, so the subset is relevant.
2. Menu browsing operates within a single restaurant's items (complete dataset).
3. Instant feedback improves perceived performance compared to server-side search with network delays.

For use cases requiring comprehensive search across entire databases (administrative search, analytics), server-side search with database indexing would be necessary.
