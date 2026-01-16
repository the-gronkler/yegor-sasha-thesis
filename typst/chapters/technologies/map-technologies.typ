== Map-Based Discovery: Technology Selection <map-technologies>

The map-based restaurant discovery feature combines geospatial querying with an interactive, map-centric UI. This section documents the key technology choices and explains why they were selected over common alternatives. System structure and data flow are described in @map-architecture, while code-level realization is covered in @map-implementation.

=== Backend geospatial computation

==== MariaDB spatial distance functions

*Decision:* Use MariaDB's built-in spherical distance function (`ST_Distance_Sphere`) for proximity filtering and ordering.

*Rationale:*

The map feature needs to filter and order restaurants by distance while keeping query cost predictable. That is best achieved when distance is computed inside the database engine and can be used in SQL constraints and ordering.

Alternatives that were considered:
- *Application-level Haversine (PHP/Laravel):* Portable and easy to understand, but it moves computation to the application tier, prevents database-side query optimization, and increases server workload under repeated map interactions.
- *PostGIS (PostgreSQL extension):* A comprehensive GIS stack with spatial indexing and advanced geometry operations. However, it would require migrating from MariaDB to PostgreSQL and operating a more complex geospatial setup that exceeds the feature's scope.
- *MariaDB `ST_Distance_Sphere`:* Native distance computation on a spherical Earth model. It integrates directly into `SELECT`, `HAVING`, and `ORDER BY`, keeping the computation close to the data.

MariaDB's native function was selected because it provides the necessary proximity behavior without requiring a database migration, and it keeps the stack consistent with the rest of the system.

==== Geospatial utility service (GeoService)

*Decision:* Encapsulate reusable geospatial utilities in a dedicated Laravel service class.

*Rationale:*

Even when distance is calculated in SQL, the application still needs shared utilities such as coordinate validation boundaries, radius limits, formatting of distance values, and short-lived persistence of a user's last location. Centralizing these operations in one service improves maintainability and avoids duplicating constants and formulas across controllers and UI code.

=== Frontend map visualization

==== Mapbox GL JS

*Decision:* Use Mapbox GL JS for interactive rendering of the discovery map.

*Rationale:*

The map UI requires smooth panning/zooming, marker clustering, and styling flexibility.

Alternatives that were considered:
- *Google Maps JavaScript API:* Widely used and well documented, but cost predictability and styling flexibility were less favorable for the expected usage.
- *Leaflet (with OpenStreetMap):* Lightweight and open-source, but higher-performance workflows (vector tiles and clustering at scale) typically require additional plugins and integration work.
- *OpenLayers:* Highly capable, but a heavier API surface for the required feature set.
- *Mapbox GL JS:* WebGL-based vector rendering with built-in clustering and strong style tooling.

Mapbox GL JS was selected mainly for its rendering performance and native clustering support, which are critical for a map-first browsing experience.

==== React integration (`react-map-gl`)

*Decision:* Use `react-map-gl` to integrate Mapbox GL JS into the React page.

*Rationale:*

`react-map-gl` provides a declarative component model and lifecycle handling that fits naturally into a React + Inertia application. Compared to managing the Mapbox instance imperatively, it reduces boilerplate, makes view-state synchronization more predictable, and simplifies cleanup of event handlers.

=== Data refresh and routing

==== Inertia.js partial reloads

*Decision:* Use Inertia partial reloads when the user changes map filters (radius, user location, or search center).

*Rationale:*

Interactive filtering should update the restaurant dataset without resetting the rest of the UI. Partial reloads allow requesting only the props that need to change, which reduces data transfer and keeps client-side state (map camera, selection, and list position) stable across updates.

=== Location persistence

==== Laravel session storage

*Decision:* Persist the last known user location in the server-side Laravel session with a short expiry.

*Rationale:*

Session storage avoids adding new database tables or cleanup processes while keeping the backend in control of validation and expiry. Client-only storage (cookies or localStorage) was considered, but it would make the backend more dependent on untrusted client state and complicate consistent server-side behavior for defaults.

=== Summary of key choices

- *Geospatial computation:* MariaDB `ST_Distance_Sphere` for database-side proximity filtering and ordering.
- *Map rendering:* Mapbox GL JS for WebGL vector tiles and clustering.
- *React integration:* `react-map-gl` for a declarative integration layer.
- *Data refresh:* Inertia partial reloads for responsive filter updates without full reloads.
- *Location persistence:* Laravel session for short-lived, server-authoritative location context.
