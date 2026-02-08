#import "../../config.typ": source_code_link

== Map-Based Discovery Architecture <map-architecture>

The architectural design of the map-based restaurant discovery feature is outlined in this section, covering the component topology, backend processing pipeline, frontend state management, data flow patterns, architectural guarantees, integration with Inertia and Mapbox, and scalability considerations.

=== Architectural Overview

The map feature is designed as a client-server system where the backend produces a filtered, scored dataset and the frontend renders an interactive visualization with synchronized controls. The architecture follows a clear separation between data acquisition (backend), presentation (frontend UI components), and orchestration (frontend state management).

==== Layer Topology

The map feature is organized into six architectural layers:

/ Map Controller Layer: Handles map discovery requests, validates geospatial inputs, orchestrates the three-phase query pipeline, and returns the filtered restaurant dataset.

/ Geospatial Service Layer: Encapsulates distance calculations, bounding box computation, coordinate validation, and location session management for the map feature.

/ Spatial Query Layer: Executes proximity-based restaurant selection using MariaDB spatial functions and indexed coordinate columns.

/ Map Page Layer: Composes the map UI from specialized partials (overlay, bottom sheet, popup) and delegates geospatial logic to the map hook.

/ Map State Management: Manages camera state (position, zoom), selection state (active restaurant), and geolocation flow using a dedicated hook.

/ Map Visualization Layer: Renders the interactive Mapbox canvas with GeoJSON sources, clustering layers, and marker interactions.

These layers communicate through well-defined interfaces: the controller exposes a REST-like endpoint, the service provides stateless methods, and frontend layers interact via props and callbacks.

=== Backend Architecture Patterns

==== Three-Phase Processing Pipeline <map-arch-three-phase>

When users open the map or change filters, the application must fetch a relevant subset of restaurants. Showing all restaurants is infeasible—metropolitan areas contain thousands of listings, overwhelming network payloads and UI rendering. The system selects restaurants near the user, ranked by proximity and quality, executing on every map interaction with performance constraints requiring efficient processing of large candidate sets.

A deterministic three-phase pipeline balances geographic proximity (respecting radius constraints) with quality ranking. This architecture separates input normalization, proximity filtering, and quality scoring into sequential phases, ensuring geographic constraints are enforced before quality scoring. High-rated distant restaurants cannot displace lower-rated nearby options, maintaining spatial coherence.

The three phases serve distinct architectural responsibilities:

*Phase A: Input Normalization* - Resolves a single center point from multiple possible input sources (search center, user location, session, default) using a deterministic priority cascade. This centralization ensures consistent behavior regardless of how the request originated.

*Phase B: Proximity-First Selection* - Selects up to 250 restaurant IDs based solely on distance from center, enforcing radius as a hard SQL constraint. This phase is quality-agnostic: it ignores restaurant ratings, review counts, and popularity metrics, establishing a geographically-bounded candidate set before any quality-based ranking occurs.

*Phase C: Quality-Based Ranking* - Hydrates full restaurant models and computes composite quality scores entirely in SQL using derived tables. Within the geographically-bounded set from Phase B, restaurants are ordered by quality (rating 50%, review count 30%, proximity 20%) with distance as a tiebreaker.

This separation enforces the architectural guarantee that radius constraints are absolute: when `radius > 0`, no restaurant beyond that distance can appear in results, regardless of its quality score. The three-phase boundary prevents implementation drift where quality-based filtering could accidentally violate geographic constraints.

==== Service Layer Abstraction

The geospatial logic is isolated in a dedicated service class that provides stateless methods for domain-specific operations. This follows the Domain Service pattern from Domain-Driven Design @EvansDDD2003: logic that does not naturally belong to an entity or value object is extracted into a service.

The service exposes methods for:
- Bounding box calculation (approximates lat/lng deltas from radius)
- Distance formatting (converts kilometers to human-readable strings)
- Session persistence (stores/retrieves coordinates with expiry validation)

This abstraction allows controllers to remain focused on HTTP request handling while delegating geospatial domain logic to a specialized component. The service is stateless and side-effect-free (except for session writes), making it straightforward to test and reason about.

==== Session-Based Location Persistence <map-arch-session-persistence>

User location is persisted in the server-side session with an expiry timestamp. This architectural choice reflects a balance between convenience (returning users see their neighborhood) and privacy (data expires after a configurable period and is not permanently stored). The session pattern follows a read-through cache model where the controller delegates location retrieval to the service layer, which handles session validation and fallback logic.

=== Frontend Architecture Patterns

==== Component Hierarchy and Separation of Concerns <map-arch-component-hierarchy>

The frontend employs a layered hierarchy following single responsibility: page components compose layout and wire props; hooks own state and perform side effects (Inertia navigation, geolocation); UI components focus on single interaction surfaces (overlay controls, map canvas, list).

=== State Management Architecture

State in the map feature is distributed across three layers:

*Server State (Inertia Props):* Authoritative data from backend (restaurant array, filter metadata). Updated via Inertia partial reloads. The server is the single source of truth for the dataset.

*Page State (Map Hook):* Client-side view state (camera position), selection state (active restaurant ID), geolocation state, and search query (fuzzy filter). Ephemeral—does not persist across reloads or sync to server.

*Global State (React Context):* Cart state shared globally via Context API, accessible from navigation, menus, and cart page without prop drilling.

This layered approach follows state locality principles @DoddsStateColocation: keep state as close as possible to where it is used, share globally only when necessary.

==== Data Flow and Synchronization <map-arch-data-flow>

The map feature implements bidirectional data flow. Server-to-client: initial loads and filter updates through Inertia partial reloads executing the three-phase pipeline. Client-to-server: filter adjustments triggering server re-execution. Client-only: search and selection via Fuse.js without server requests. This hybrid approach optimizes responsiveness: dataset changes require server validation (radius enforcement, scoring); UI interactions (search, selection) remain instant through client-side state.

==== Controlled Map Component Pattern

The Map component follows React's controlled component pattern: view state (latitude, longitude, zoom, bearing, pitch) is managed by the parent hook and passed down as props. Camera movements trigger an `onMove` callback that updates the parent state, which flows back down as props.

This architecture enables:
- Programmatic camera control (flying to selected restaurant)
- Conditional rendering based on view state (showing "Search Here" button)
- Preserving camera position across dataset updates
- Testability (mock view state in tests)

The alternative - uncontrolled component with internal ref access - would scatter view state across components and make state synchronization fragile.

==== Geolocation Integration Pattern <map-arch-geolocation-pattern>

Geolocation uses a callback registration pattern to bridge the gap between the Mapbox `GeolocateControl` (which has its own UI and lifecycle) and the custom overlay controls. This pattern decouples the UI (custom button in overlay) from the implementation (Mapbox control) while maintaining clean component boundaries. The trigger function serves as a stable interface across component re-renders.

=== Data Architecture and Flow Patterns

==== Query Optimization Strategy <map-arch-query-optimization>

The backend query architecture prioritizes single-pass computation: distance calculated once via subquery and reused in scoring; review counts pre-aggregated via grouped subquery; composite score computed once in derived table; final ordering on derived columns. This follows "compute once, use many times" rather than recalculating distance across multiple clauses. The derived table pattern (`fromSub`, `joinSub`) allows complex scoring while returning Eloquent models, balancing SQL efficiency with Laravel ORM convenience.

==== Bounding Box Prefilter Pattern <map-arch-bounding-box>

The architecture uses two-stage spatial filtering: (1) coarse filter via `WHERE latitude BETWEEN ... AND longitude BETWEEN ...` using indexed range scans; (2) exact filter via `HAVING ST_Distance_Sphere(...) <= radius` ensuring accuracy. This balances index efficiency with computation cost—bounding box reduces candidate set before expensive spherical distance calculations. Alternative spatial indexes (R-tree) were not chosen because they require schema changes and do not benefit `ST_Distance_Sphere` on coordinate columns.

==== Payload Shaping and Lazy Loading

The architecture deliberately separates discovery data from detail data:

- Map endpoint loads: restaurant metadata, single primary image, distance, score
- Map endpoint omits: full menu hierarchy, all images, reviews

This reflects the architectural principle of loading only what is displayed. The map UI does not render menus, so loading them wastes bandwidth. When users click a restaurant, a separate detail page loads the full dataset.

This pattern follows a lazy loading architecture: load minimal data eagerly for browsing, fetch detailed data on-demand for interaction.

=== Architectural Guarantees and Invariants <map-arch-guarantees>

The map architecture enforces key invariants:

*Radius Determinism:* When `radius > 0`, results contain only restaurants within that distance, enforced via SQL HAVING ensuring database-level constraint.

*Score Stability:* Composite scores computed exactly once in SQL. No PHP code modifies scores or reorders results.

*Center Point Uniqueness:* Phase A guarantees exactly one center point per request via deterministic priority cascade.

*Session Isolation:* User location and search center are separate. Exploring new areas (`search_lat`/`search_lng`) does not overwrite persistent user location (`lat`/`lng`).

*UI State Preservation:* Partial Inertia reloads update only dataset, not UI state. Camera position, selection, and overlay state persist across filter changes.

These guarantees reflect architectural choices prioritizing predictability and user experience.

=== Integration Architecture

==== Inertia.js Bridge Pattern <map-arch-inertia-bridge>

The map feature relies on the Inertia.js integration described in @inertia-technology, which provides SPA-like navigation with server-authoritative routing and data.

Of particular importance for the map architecture is Inertia's partial reload capability: when the user changes filters, only the restaurant dataset is re-fetched from the server, while the rest of the page state (camera position, selection, overlay) is preserved.

This allows the map to maintain user context (e.g., zoom level, selected restaurant) while updating the underlying data. The architecture leverages this capability to create a responsive, stateful UI without sacrificing server-side control over routing and data.

==== Mapbox Integration Architecture

The map visualization uses a layered architecture:

*Data Layer:* GeoJSON source with restaurant features
*Clustering Layer:* Mapbox-native clustering (configured at source level)
*Visual Layers:* Cluster circles, point circles, selected point overlay
*Interaction Layer:* Click handlers, hover effects, popup management

This separation allows independent control: data updates do not require re-configuring layers, and visual styling changes do not affect data structure. The architecture uses Mapbox's declarative layer system rather than imperative canvas drawing, enabling GPU-accelerated rendering.

=== Scalability and Performance Architecture <map-arch-scalability>

The architecture incorporates several design decisions that support scalability:

==== Hard Result Limit:

The 250-restaurant limit protects against unbounded queries, excessive JSON payloads, and client-side rendering costs. This is an architectural safeguard, not a temporary optimization.

==== Database-Level Computation

All scoring and ordering happens in SQL, leveraging MariaDB's query optimizer. This scales better than fetching all candidates and sorting in PHP.

==== Strategic Indexing
<map-arch-indexing>

Separate single-column indexes on `latitude` and `longitude` columns support the bounding box prefilter that reduces the candidate set before expensive distance calculations.

MariaDB's query optimizer uses index merge @MariaDBIndexMerge to combine separate indexes for range queries (`BETWEEN`) on both columns. This approach was selected over spatial indexes (R-tree), which require geometry columns and schema changes. The `ST_Distance_Sphere` function operates on raw coordinate columns, making traditional B-tree indexes more compatible with the existing schema.

Composite `(latitude, longitude)` indexes were not chosen because they do not benefit range queries that filter on both columns independently-the query optimizer cannot efficiently use a composite index when both columns have range conditions.

These patterns reflect an architecture designed for predictable resource consumption: capped result sizes, database-offloaded computation, and index-supported queries.

=== Summary

The map discovery architecture demonstrates several key patterns:

- *Three-phase pipeline* separates concerns and enforces semantic guarantees (proximity selection → quality ranking)
- *Service layer abstraction* centralizes geospatial domain logic
- *Layered state management* distributes state across server (dataset), page (UI), and global (cart) layers
- *Controlled components* enable programmatic control and state synchronization
- *Single-pass SQL computation* avoids redundant calculations and leverages query optimization
- *Lazy loading* separates discovery data from detail data for payload efficiency
- *Hybrid client-server* balances server authority (filtering, scoring) with client responsiveness (search, selection)

These architectural choices prioritize deterministic behavior, maintainable code structure, and scalable performance while delivering a smooth user experience across desktop and mobile platforms.
