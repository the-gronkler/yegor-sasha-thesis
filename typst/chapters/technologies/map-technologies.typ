#import "../../config.typ": source_code_link

== Map-Based Discovery Technologies <map-technologies>

The map-based restaurant discovery feature requires accurate geospatial calculations, interactive visualization, client-side filtering, and responsive data fetching. This section describes the technology choices that support these requirements.

=== Geospatial Computation <map-tech-geospatial>

*MariaDB Spatial Functions* are used for all distance calculations on the backend. The `ST_Distance_Sphere` function computes geodesic distance on a spherical Earth model, providing acceptable accuracy for restaurant discovery (error < 0.5% for distances under 100 km).

This approach was selected over two alternatives:

_PostGIS (PostgreSQL extension)_ offers comprehensive GIS capabilities including spatial indexing and advanced geometric operations. However, adopting PostGIS would require migrating the entire application from MariaDB to PostgreSQL, adding significant infrastructure complexity for a feature that needs only distance calculations.

_Application-level Haversine_ (computing distances in PHP) provides maximum database portability but moves computation to the application tier. This approach increases network round-trips and prevents database-level query optimization, as the database cannot filter or sort by a value computed outside the query.

MariaDB's native function executes entirely in the database engine, enabling efficient use in `WHERE`, `HAVING`, and `ORDER BY` clauses. A configurable Haversine fallback is provided for environments lacking `ST_Distance_Sphere`, with numerical stability safeguards (clamping trigonometric inputs to prevent `NaN` results from floating-point edge cases).

=== Map Visualization <map-tech-visualization>

*Mapbox GL JS* provides interactive map rendering using WebGL-accelerated vector tiles. This technology was selected for several reasons:

- *Rendering Performance*: Vector-based rendering delivers smooth 60fps interactions even with hundreds of markers, outperforming raster-tile approaches that require downloading pre-rendered images at each zoom level.
- *Native Clustering*: Built-in point clustering groups nearby markers at low zoom levels, improving both visual clarity and rendering performance without additional libraries.
- *Style Customization*: Mapbox Studio enables granular control over map appearance, allowing the map to match the application's design system.
- *Cost Structure*: The free tier (50,000 map loads per month) is sufficient for development and moderate production traffic.

_Google Maps_ was considered due to its ubiquity and user familiarity. However, Mapbox offered more generous free-tier limits, finer style control, and a more modern JavaScript API designed for React integration.

_Leaflet with OpenStreetMap_ was considered as an open-source alternative requiring no API key. However, Leaflet uses raster tiles by default (resulting in slower rendering), and vector tile support requires additional plugins. Clustering also requires plugin integration rather than being built-in.

=== React Integration <map-tech-react-integration>

*react-map-gl* wraps Mapbox GL JS with React-friendly bindings, providing a declarative component model (`<Map>`, `<Source>`, `<Layer>`, `<Popup>`) that integrates naturally with React's lifecycle. The library handles automatic cleanup of event listeners and map instances, preventing memory leaks that commonly occur when managing Mapbox imperatively.

The library supports the controlled component pattern used in the map architecture (see @map-architecture), enabling programmatic camera control and view state synchronization.

The alternative—using Mapbox GL JS directly with `useEffect` hooks—would require manual imperative management of map initialization, event listener registration, and cleanup, increasing complexity and bug potential.

=== Client-Side Search <map-tech-client-search>

*Fuse.js* provides fuzzy search filtering for the restaurant list on the client side. When users type in the search box, Fuse.js filters the restaurant dataset locally without requiring server requests.

This approach was selected because the map endpoint already returns a bounded dataset (up to 250 restaurants within the selected radius). Performing fuzzy search on this pre-filtered set is computationally trivial for the browser and provides instant feedback as users type. Server-side search would introduce unnecessary latency for each keystroke and complicate the interaction between search queries and geographic filters.

Fuse.js supports weighted keys, allowing restaurant names to rank higher than descriptions in search relevance. The library's configurable threshold parameter controls match strictness, balancing typo tolerance against false positives.

=== Data Fetching <map-tech-data-fetching>

*Inertia.js partial reloads* are used to update the restaurant dataset when filters change. The `only: ['restaurants', 'filters']` option re-fetches specific page props while preserving client-side state (camera position, selected restaurant, scroll position).

This approach was selected over two alternatives:

_Full page reloads_ would be simplest to implement but would lose all UI state on each filter change, creating a jarring user experience.

_Manual AJAX with state merging_ (using `fetch()` to retrieve data and manually merging it into React state) would provide fine-grained control but would duplicate Inertia's routing logic, break browser history integration, and require manual handling of loading states and error conditions.

Partial reloads preserve the seamless feel of a single-page application while maintaining Inertia's server-side routing benefits. The `replace: true` option prevents intermediate filter states from polluting browser history.

=== Location Persistence <map-tech-location-persistence>

*Laravel Session* is used to persist user location between visits. When users grant geolocation permission, their coordinates are stored server-side with a 24-hour expiry timestamp.

This approach was selected for several reasons:

- *Server Authority*: Session data cannot be tampered with from the client, preventing manipulation of location coordinates.
- *Automatic Expiry*: Laravel's session management handles expiry automatically, balancing convenience (returning users see their neighborhood) with privacy (stale location data is not retained indefinitely).
- *No Additional Infrastructure*: The existing session store (database-backed) is reused without requiring schema migrations or additional services.

_localStorage_ was considered but cannot be read during server-side rendering or in controller logic, limiting its usefulness for a feature that requires location data on the backend.

_Cookies_ were considered but add bandwidth overhead by being sent with every HTTP request, even when location data is not needed.

=== Database Indexing <map-tech-indexing>

*Separate single-column indexes* on `latitude` and `longitude` columns support the bounding box prefilter that reduces the candidate set before expensive distance calculations.

MariaDB's query optimizer uses index merge to combine separate indexes for range queries (`BETWEEN`) on both columns. This approach was selected over spatial indexes (R-tree), which require geometry columns and schema changes. The `ST_Distance_Sphere` function operates on raw coordinate columns, making traditional B-tree indexes more compatible with the existing schema.

Composite `(latitude, longitude)` indexes were not chosen because they do not benefit range queries that filter on both columns independently—the query optimizer cannot efficiently use a composite index when both columns have range conditions.

=== Payload Optimization <map-tech-payload>

*Strategic eager loading* minimizes response size for the map endpoint. Only the `images` relation is loaded (selecting specific columns: `id`, `restaurant_id`, `image`, `is_primary_for_restaurant`), while the full `foodTypes.menuItems` hierarchy is deliberately excluded.

This approach reduces response size by approximately 80% compared to loading complete restaurant data with nested menu items. The map UI displays only restaurant cards with thumbnails, ratings, and distances—menu data is unnecessary for discovery and is loaded on-demand when users navigate to individual restaurant pages.

This follows the principle of loading only what is displayed, which is particularly important for mobile users on bandwidth-constrained networks.

=== Summary

The map-based discovery feature employs a layered technology stack:

/ Backend geospatial: MariaDB `ST_Distance_Sphere` provides accurate distance calculations entirely in SQL, with Haversine fallback for portability.

/ Map rendering: Mapbox GL JS delivers WebGL-accelerated vector maps with native clustering, wrapped by react-map-gl for React integration.

/ Client-side search: Fuse.js enables instant fuzzy filtering without server round-trips.

/ Data synchronization: Inertia.js partial reloads update the dataset while preserving UI state.

/ Location persistence: Laravel Session stores user coordinates server-side with automatic expiry.

/ Query optimization: Bounding box prefilters with indexed columns reduce the candidate set before distance calculations.

These choices prioritize user experience (smooth interactions, instant search, preserved state), performance (database-level computation, strategic eager loading), and maintainability (leveraging framework features over custom implementations).
