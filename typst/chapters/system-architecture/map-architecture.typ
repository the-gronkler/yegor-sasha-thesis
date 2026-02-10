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

=== Three-Phase Processing Pipeline <map-arch-three-phase>

Metropolitan areas such as Warsaw can contain thousands of restaurant listings, making unbounded queries infeasible for both network payloads and map rendering. The system must select a bounded set of nearby restaurants ranked by a combination of proximity and quality, while handling multiple center point sources and maintaining deterministic behavior. This requires a processing strategy that enforces geographic constraints before applying quality-based ranking.

To address these requirements, a deterministic three-phase processing pipeline was developed, separating input normalization, proximity-based filtering, and quality-based ranking into distinct sequential phases. This separation prevents high-rated distant restaurants from displacing lower-rated nearby options, maintaining spatial coherence in the result set.

The three phases serve distinct architectural responsibilities:

*Phase A: Input Normalization* - Resolves a single center point from multiple possible input sources (search center, user location, session, default) using a deterministic priority cascade. This centralization ensures consistent behavior regardless of how the request originated.

*Phase B: Proximity-First Selection* - Selects up to 250 restaurant IDs based solely on distance from center, enforcing radius as a hard SQL constraint. This phase is quality-agnostic: it ignores restaurant ratings, review counts, and popularity metrics, establishing a geographically-bounded candidate set before any quality-based ranking occurs.

*Phase C: Quality-Based Ranking* - Hydrates full restaurant models and computes composite quality scores entirely in SQL using derived tables. Within the geographically-bounded set from Phase B, restaurants are ordered by quality (rating 50%, review count 30%, proximity 20%) with distance as a tiebreaker.

This separation enforces the architectural guarantee that radius constraints are absolute: when `radius > 0`, no restaurant beyond that distance can appear in results, regardless of its quality score. The three-phase boundary prevents implementation drift where quality-based filtering could accidentally violate geographic constraints. The query architecture computes distance once using a subquery and reuses it in scoring, following a single-pass computation principle.

=== Query Optimization Through Single-Pass Computation <map-arch-query-optimization>

Within the three-phase pipeline, database queries are structured to compute expensive operations (distance calculations, aggregations) exactly once and reuse the results. This single-pass computation principle minimizes redundant work and ensures consistency between filtering and ranking operations.

=== Service Layer Abstraction

The geospatial logic is isolated in a dedicated service class that provides stateless methods for domain-specific operations. This follows the Domain Service pattern from Domain-Driven Design @EvansDDD2003: logic that does not naturally belong to an entity or value object is extracted into a service.

The service exposes methods for:
- Bounding box calculation (approximates lat/lng deltas from radius)
- Distance formatting (converts kilometers to human-readable strings)
- Session persistence (stores/retrieves coordinates with expiry validation)

This abstraction allows controllers to remain focused on HTTP request handling while delegating geospatial domain logic to a specialized component. The service is stateless and side-effect-free (except for session writes), making it straightforward to test and reason about.

=== Session-Based Location Persistence <map-arch-session-persistence>

User location is persisted in the server-side session with an expiry timestamp, following a read-through cache model: the service reads and validates session data, returning coordinates or null, with the controller falling back to defaults. This balances convenience for returning users with privacy, as location data expires after a configurable period and is not permanently stored.

=== Component Hierarchy and Separation of Concerns <map-arch-component-hierarchy>

The frontend follows a clear hierarchy that separates orchestration, state management, and presentation. The `MapIndex` page component composes the UI and delegates all geospatial logic to the `useMapPage` hook. Beneath it, `MapOverlay` provides filter controls (search, radius, location), `Map` renders the Mapbox canvas with GeoJSON sources and clustering layers, `MapPopup` displays selection details, and `BottomSheet` synchronizes a scrollable restaurant list with the map view. Each component follows the single responsibility principle, focusing on one interaction surface.

=== State Management Architecture

State in the map feature is distributed across three layers, each with a specific responsibility:

*Server State (Inertia Props):*

Authoritative data from backend: restaurant array, filter metadata (lat, lng, radius). Updated via Inertia partial reloads when filters change. The server is the single source of truth for the dataset.

*Page State (Map Hook):*

Manages client-side state: view state (camera position), selection state (active restaurant ID), geolocation state (loading/error), and search query (fuzzy filter). This state is ephemeral - it does not persist across page reloads and is not sent to the server.

*Global State (React Context):*

Cart state is shared globally via Context API. This state must be accessible from navigation, restaurant menus, and the cart page. The Context pattern avoids prop drilling while keeping state simple (no external state library boilerplate needed).

This layered approach follows the principle of state locality @DoddsStateColocation: keep state as close as possible to where it is used, but share globally only when necessary.

==== Data Flow and Synchronization <map-arch-data-flow>

The map feature implements bidirectional data flow between server and client. On initial load or filter changes, the backend executes the three-phase pipeline and returns a restaurant array via Inertia page props; the hook then converts the dataset to GeoJSON markers and the map component re-renders its layers.

When users adjust the radius, trigger geolocation, or activate "Search Here," the hook constructs new query parameters and issues an Inertia partial reload (`only: ['restaurants', 'filters']`), updating only the dataset while preserving UI state such as camera position and selection.

For client-side interactions such as search filtering and selection, no server request is issued. The hook filters the existing restaurant array using Fuse.js, and updates are reflected immediately in both the map markers and the list view. This hybrid approach optimizes for responsiveness: dataset changes require server validation, while UI interactions remain instant through client-side state.

==== Controlled Map Component Pattern

The Map component follows React's controlled component pattern: view state is managed by the parent hook and passed as props. Camera movements trigger an `onMove` callback, enabling programmatic camera control and state synchronization.

==== Geolocation Control Integration Pattern <map-arch-geolocation-pattern>

The geolocation control integration uses a callback registration pattern where the hidden Mapbox `GeolocateControl` is triggered via a callback registered in a ref, allowing custom UI buttons to trigger built-in geolocation functionality while maintaining control over the user interface.

The architecture separates discovery data (restaurant metadata, primary image, distance, score) from detail data (full menu hierarchy, all images, reviews). The map endpoint loads only what is displayed; detailed data is fetched on demand when users navigate to individual restaurant pages.

=== Architectural Guarantees and Invariants <map-arch-guarantees>

The map architecture enforces two key invariants:

_Radius Determinism_ -- when `radius > 0`, the result set contains only restaurants within that distance. This constraint is enforced via SQL `HAVING`, not application-level filtering, ensuring the database engine upholds the geographic boundary.

_Session Isolation_ -- user location and search center are maintained as separate concepts. Exploring a new area (`search_lat`/`search_lng`) does not overwrite the persistent user location (`lat`/`lng`), allowing exploration without losing context.

=== Mapbox Integration Architecture

The map visualization uses a layered architecture: a GeoJSON data source with clustering, visual layers for cluster circles, point markers, and selection highlighting, and an interaction layer for click handlers and popup management. This separation allows independent control, as data updates do not require re-configuring visual layers.

=== Bounding Box Prefilter Pattern <map-arch-bounding-box>

Separate single-column indexes on `latitude` and `longitude` columns support a bounding box prefilter that reduces the candidate set before expensive distance calculations.

MariaDB's query optimizer uses index merge @MariaDBIndexMerge to combine separate indexes for range queries (`BETWEEN`) on both columns. This approach was selected over spatial indexes (R-tree), which require geometry columns and schema changes. The `ST_Distance_Sphere` function operates on raw coordinate columns, making traditional B-tree indexes more compatible with the existing schema.

Composite `(latitude, longitude)` indexes were not chosen because they do not benefit range queries that filter on both columns independently-the query optimizer cannot efficiently use a composite index when both columns have range conditions.

=== Summary

The map discovery architecture is built on three key patterns:

- *Three-phase pipeline* separates concerns and enforces semantic guarantees (proximity selection → quality ranking)
- *Service layer abstraction* centralizes geospatial domain logic
- *Layered state management* distributes state across server (dataset), page (UI), and global (cart) layers
