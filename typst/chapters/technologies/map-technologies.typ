#import "../../config.typ": source_code_link

== Map-Based Discovery: Technology Selection <map-technologies>

This section presents the technology choices for the map-based restaurant discovery feature and the rationale behind each decision.

=== Backend Geospatial Technologies

==== MariaDB with Spatial Functions

*Decision:* Use MariaDB's built-in spatial functions (`ST_Distance_Sphere`) for distance calculations rather than application-level computation or dedicated geospatial databases.

*Rationale:*

The primary requirement was accurate geodesic distance calculation between geographic coordinates. Several options were evaluated:

/ Application-level Haversine: Implement the Haversine formula in PHP/Laravel code. This approach offers maximum portability but moves computation to the application tier, increasing network round-trips and preventing database-level query optimization.

/ PostGIS (PostgreSQL extension): Industry-standard geospatial database extension with comprehensive GIS capabilities including spatial indexing, geometric operations, and routing algorithms. However, this would require migrating the entire application from MariaDB to PostgreSQL.

/ MariaDB ST_Distance_Sphere: Native spatial function available in MariaDB 10.1+ that computes geodesic distance on a spherical Earth model. Returns distance in meters with acceptable accuracy for restaurant discovery use cases (error < 0.5% for distances under 100 km).

MariaDB's `ST_Distance_Sphere` was selected because it provides sufficient accuracy for the restaurant discovery domain while keeping the technology stack consistent (no database migration required). The function executes entirely in the database engine, enabling efficient use in `WHERE`, `HAVING`, and `ORDER BY` clauses. For the use case of finding restaurants within a few kilometers, the spherical Earth approximation (rather than full ellipsoidal calculations) provides adequate precision without the overhead of PostGIS.

*Fallback Strategy:*

The application provides a configurable distance calculation mechanism through the `geo.distance_formula` configuration option. The Restaurant model's `scopeWithDistanceTo` method respects this setting and can switch between MariaDB's `ST_Distance_Sphere` function and a numerically-stable Haversine implementation (using `GREATEST`/`LEAST` clamping around trigonometric operations to prevent `NaN` results from floating-point rounding errors in the `ACOS` function).

However, the map discovery feature's current implementation uses `ST_Distance_Sphere` directly in its query pipeline for performance optimization reasons (avoiding scope overhead in multi-phase queries with derived tables). This means the map feature assumes MariaDB 10.1+ availability. Portability to database engines lacking `ST_Distance_Sphere` would require refactoring the MapController's distance calculations to leverage the configurable scope mechanism or implement an equivalent conditional expression within the controller's raw SQL queries.

=== Frontend Technologies

==== Map Visualization: Mapbox GL JS

*Decision:* Use Mapbox GL JS for interactive map rendering rather than Google Maps, Leaflet, or OpenLayers.

*Rationale:*

Several mapping libraries were evaluated based on rendering performance, clustering capabilities, style customization, and licensing:

/ Google Maps JavaScript API: Industry-standard with excellent documentation and reliability. However, pricing is based on map loads and requires a credit card even for free tier. Styling options are more limited, and custom clustering requires additional work.

/ Leaflet with OpenStreetMap: Open-source, no API key required, large ecosystem. However, Leaflet uses raster tiles by default (slower rendering, less smooth), and vector tile support requires additional plugins. Clustering works but requires plugin integration.

/ OpenLayers: Powerful open-source library with vector tile support. However, it has a steeper learning curve and more verbose API compared to modern alternatives.

/ Mapbox GL JS: Vector-based rendering using WebGL for smooth 60fps interactions. Built-in clustering, extensive style customization through Mapbox Studio, and a generous free tier (50,000 loads/month). Designed for React integration through `react-map-gl`.

Mapbox was selected for its superior rendering performance (vector tiles + WebGL), native clustering support, and modern API that integrates cleanly with React's component model. The free tier is sufficient for development and moderate production traffic, and the style customization allows the map to match the application's design system. The decision to use the public token type (`pk.`) rather than secret tokens prevents accidental credential exposure in client bundles.

*Alternative Considered:*

Google Maps was seriously considered due to its ubiquity and familiarity to users. The decision came down to cost predictability (Mapbox's free tier is more generous for the expected traffic) and style flexibility (Mapbox Studio provides more granular control over visual appearance).

==== React-Map-GL Integration

*Decision:* Use the `react-map-gl` wrapper library rather than vanilla Mapbox GL JS.

*Rationale:*

`react-map-gl` provides React-friendly bindings for Mapbox, including:

- Declarative component model (`<Map>`, `<Source>`, `<Layer>`, `<Popup>`)
- Automatic cleanup and lifecycle management
- TypeScript type definitions
- Controlled component pattern for view state synchronization

The alternative - using Mapbox GL JS directly with `useEffect` hooks - would require manual imperative management of map instances, event listeners, and cleanup. The declarative wrapper reduces boilerplate and prevents common bugs (memory leaks from unremoved listeners, stale closures, race conditions in async initialization).

==== State Management: React Context API

*Decision:* Use React Context API for global cart state rather than Redux, Zustand, or prop drilling.

*Rationale:*

The cart state must be accessible from multiple surfaces (navigation badge, restaurant menu, cart page) without deep prop drilling. Several state management solutions were evaluated:

/ Prop drilling: Pass cart state down component tree. Simple but becomes unwieldy beyond 2-3 levels and makes refactoring difficult.

/ Redux: Industry-standard global state with time-travel debugging and middleware. However, Redux involves significant boilerplate (actions, reducers, store configuration) and is overkill for a single cart slice.

/ Zustand: Lightweight state management with minimal boilerplate. Clean API but adds another dependency for a problem React Context solves natively.

/ React Context API: Built-in React feature for sharing state across components. Zero dependencies, TypeScript-friendly, integrates naturally with hooks.

Context API was chosen because the cart state is simple (items array, derived totals), updates are localized (not high-frequency), and React 18's optimizations minimize re-render concerns. The Context provides methods for adding, removing, and updating items that handle server requests with optimistic updates, providing a responsive UI without external state library complexity.

==== Data Fetching: Inertia.js Partial Reloads

*Decision:* Use Inertia's `only` prop to reload specific page props rather than full page refreshes.

*Rationale:*

When the map's radius or location changes, only the restaurant dataset needs updating - UI state (camera position, selected restaurant, scroll position) should persist. Three approaches were considered:

/ Full page reload: Simplest but loses all UI state and feels jarring.

/ Manual AJAX with state merge: Fetch new data via `fetch()` and manually merge into React state. Flexible but duplicates Inertia's routing logic and breaks browser history.

/ Inertia partial reloads: Use `only: ['restaurants', 'filters']` to re-fetch only specified props while preserving component state.

Partial reloads provide the best user experience: the dataset updates seamlessly while camera position, selection, and overlay state remain intact. The `preserveScroll: true` option prevents scroll jumps, and `replace: true` avoids polluting browser history with intermediate filter states.

=== Session Storage Technologies

==== Laravel Session for Location Persistence

*Decision:* Use Laravel's default session storage (database-backed) for persisting user location rather than cookies, localStorage, or dedicated geolocation database.

*Rationale:*

User location should persist across visits (for convenience) but expire after 24 hours (for privacy). Options considered:

/ Cookies: Accessible from both client and server but limited to 4KB and sent with every request (bandwidth overhead).

/ LocalStorage: 5-10MB limit, accessible only from JavaScript. Cannot be read during server-side rendering or controller logic.

/ Database table: Maximum flexibility but requires schema migrations, additional queries, and cleanup jobs.

/ Laravel session: Built-in, database-backed (or file/Redis-backed), expires automatically, accessible in controllers via `$request->session()`.

Laravel session was chosen because it requires no additional infrastructure, respects existing session expiry configuration, and keeps location data server-authoritative (preventing client-side tampering). The session stores latitude, longitude, and timestamp, allowing the controller to validate freshness before use.

=== Performance Optimization Technologies

==== Database Indexing Strategy

*Decision:* Use separate indexes on `latitude` and `longitude` rather than spatial indexes or composite indexes.

*Rationale:*

The bounding box prefilter uses range queries (`BETWEEN`) on latitude and longitude independently. MariaDB's query optimizer can use index merge to combine separate indexes efficiently. Spatial indexes (R-tree) would optimize geometric operations but are not used because `ST_Distance_Sphere` operates on raw coordinates, not geometry columns. Composite `(latitude, longitude)` indexes do not benefit range queries on both columns.

The chosen strategy - separate single-column indexes - allows MariaDB to use index merge optimization for bounding box filters, reducing the candidate set before expensive distance calculations.

==== Payload Reduction Strategy

*Decision:* Deliberately exclude `foodTypes.menuItems` relations from map endpoint eager loading.

*Rationale:*

The map UI displays restaurant names, ratings, distances, and thumbnails - it does not need full menu data. Loading the complete menu hierarchy (food types → menu items → allergens → images) multiplies the JSON payload size by approximately 5x for large restaurants. The decision to load only `images` (selecting specific columns) reduces response size by ~80%, significantly improving initial page load on mobile networks.

This follows the principle of "load only what you display" - menu data is loaded on-demand when users navigate to restaurant detail pages.

=== Summary of Technology Decisions

/ Geospatial computation: MariaDB `ST_Distance_Sphere` for accuracy and performance, with Haversine fallback for portability.

/ Map visualization: Mapbox GL JS for WebGL-based vector rendering, native clustering, and style flexibility via React-Map-GL wrapper.

/ State management: React Context API for cart state (simple, zero-dependency), Inertia partial reloads for seamless dataset updates.

/ Session storage: Laravel session for location persistence (built-in, secure, automatic expiry).

/ Performance: Separate lat/lng indexes for bounding box queries, strategic eager loading to minimize payload size.

These choices prioritize developer productivity (leveraging built-in framework features), user experience (smooth interactions, fast loads), and maintainability (declarative UI components, minimal external dependencies).

