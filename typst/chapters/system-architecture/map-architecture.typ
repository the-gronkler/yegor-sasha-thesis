#import "../../config.typ": source_code_link

== Map-Based Discovery Architecture <map-architecture>

This section describes the high-level design and architectural patterns used in the map-based restaurant discovery feature. The focus is on component interactions, data flow, architectural patterns, and design decisions that shape the system structure - not implementation details or code-level specifics.

=== Architectural Overview

The map feature is designed as a client-server system where the backend produces a filtered, scored dataset and the frontend renders an interactive visualization with synchronized controls. The architecture follows a clear separation between data acquisition (backend), presentation (frontend UI components), and orchestration (frontend state management).

==== Component Topology

The system consists of six primary components:

/ Backend Controller Layer: Handles HTTP requests, validates inputs, orchestrates the three-phase query pipeline, and returns JSON responses via Inertia.

/ Geospatial Service Layer: Encapsulates domain logic for distance calculations, bounding box computation, coordinate validation, and session management.

/ Database Layer: Stores restaurant entities with geographic coordinates and supports spatial queries via MariaDB functions.

/ Frontend Page Layer: Composes the UI from specialized components and delegates business logic to hooks.

/ Frontend State Management: Manages view state (camera position), selection state (active restaurant), and geolocation state using React hooks.

/ Map Visualization Layer: Renders an interactive Mapbox map with clustering, popups, and marker layers.

These components communicate through well-defined interfaces: the controller exposes a REST-like endpoint, the service provides stateless methods, and frontend components interact via props and callbacks.

=== Backend Architecture Patterns

==== Three-Phase Processing Pipeline

The backend controller implements a deterministic three-phase architecture that separates concerns and enforces strict semantic guarantees:

*Phase A: Input Normalization*

Responsibility: Resolve a single center point from multiple possible input sources.

Design rationale: Different user interactions provide coordinates through different request parameters (search center, user location, session). Rather than scattering priority logic across the controller, Phase A centralizes it in a dedicated normalization method. This ensures consistent behavior regardless of how the request originated.

Key guarantee: Exactly one center point emerges, with a clear priority order that prioritizes explicit user intent (search) over persistent context (session).

*Phase B: Proximity-First Selection*

Responsibility: Select up to 250 restaurant IDs based solely on distance from center, enforcing radius as a hard limit.

Design rationale: If selection and ranking happened simultaneously, high-rated distant restaurants could displace lower-rated nearby restaurants, violating user expectations about radius filters. By selecting purely on proximity first, Phase B establishes a geographically-bounded candidate set. The use of SQL `HAVING` ensures the radius limit is enforced *before* the result limit, guaranteeing "up to N within radius" semantics rather than "N closest overall".

Key guarantee: When `radius > 0`, no restaurant beyond that distance can appear in results, regardless of its quality score.

*Phase C: Quality-Based Ranking*

Responsibility: Hydrate full restaurant models, compute composite quality scores, and order by score with distance as a tiebreaker.

Design rationale: Within the geographically-bounded set from Phase B, users want to see the "best" restaurants first. Phase C computes a weighted composite score (rating 50%, review count 30%, proximity 20%) entirely in SQL using derived tables. This approach avoids N+1 queries, eliminates redundant distance calculations, and leverages database query optimization for ordering.

Key guarantee: Scores are computed exactly once and ordering happens in the database, ensuring no PHP post-processing can accidentally change result order.

==== Service Layer Abstraction

The geospatial logic is isolated in a `GeoService` class that provides stateless methods for domain-specific operations. This follows the Domain Service pattern from Domain-Driven Design: logic that doesn't naturally belong to an entity or value object is extracted into a service.

The service exposes methods for:
- Bounding box calculation (approximates lat/lng deltas from radius)
- Distance formatting (converts kilometers to human-readable strings)
- Session persistence (stores/retrieves coordinates with expiry validation)

This abstraction allows controllers to remain focused on HTTP request handling while delegating geospatial domain logic to a specialized component. The service is stateless and side-effect-free (except for session writes), making it straightforward to test and reason about.

==== Session-Based Location Persistence

User location is persisted in the Laravel session under the key `geo.last`. This architectural choice reflects a balance between convenience (returning users see their neighborhood) and privacy (data expires after 24 hours and is not permanently stored).

The session pattern follows a read-through cache model:
1. Controller requests location from service
2. Service checks session for valid (non-expired) coordinates
3. If present and fresh, return; otherwise return `null`
4. Controller falls back to default center (Warsaw)

This design keeps the controller simple (request → service → fallback) while encapsulating session validation logic in the service layer.

=== Frontend Architecture Patterns

==== Component Hierarchy and Separation of Concerns

The frontend follows a clear hierarchy that separates orchestration, state management, and presentation:
// TODO: Change the text diagram below to an actual diagram if needed.
```
MapIndex (Page Component - Orchestration)
├── useMapPage (Hook - State & Business Logic)
├── MapLayout (Layout - Scroll Management)
├── MapOverlay (Component - Controls)
│   ├── Search Input
│   ├── Radius Slider
│   ├── Location Controls
│   └── "Search Here" Button
├── Map (Component - Visualization)
│   ├── GeoJSON Source (Restaurants)
│   ├── Cluster Layer
│   ├── Point Layer
│   ├── Selected Point Layer
│   └── User Marker Layer
├── MapPopup (Component - Selection Detail)
└── BottomSheet (Component - List Sync)
    └── RestaurantCard (Component - List Item)
```

This hierarchy enforces single responsibility:
- The page component composes layout and wires props
- The hook owns state and performs side effects (Inertia navigation, geolocation)
- Each UI component focuses on one interaction surface (overlay controls, map canvas, list)

==== State Management Architecture

State is distributed across three layers, each with a specific responsibility:

*Server State (Inertia Props):*

Authoritative data from backend: restaurant array, filter metadata (lat, lng, radius). Updated via Inertia partial reloads when filters change. The server is the single source of truth for the dataset.

*Page State (useMapPage Hook):*

Manages client-side state: view state (camera position), selection state (active restaurant ID), geolocation state (loading/error), and search query (fuzzy filter). This state is ephemeral - it doesn't persist across page reloads and isn't sent to the server.

*Global State (React Context):*

Cart state is shared globally via Context API. This state must be accessible from navigation, restaurant menus, and the cart page. The Context pattern avoids prop drilling while keeping state simple (no Redux boilerplate needed).

This layered approach follows the principle of state locality: keep state as close as possible to where it's used, but share globally only when necessary.

==== Data Flow and Synchronization

The map feature implements bidirectional data flow between server and client:

*Server → Client (Initial Load & Updates):*

1. User navigates to map page or changes filters
2. Backend executes three-phase pipeline and returns restaurant array
3. Inertia updates page props
4. React re-renders with new dataset
5. Hook converts restaurants to GeoJSON markers
6. Map component updates layers

*Client → Server (Filter Changes):*

1. User adjusts radius, triggers geolocation, or clicks "Search Here"
2. Hook constructs new query parameters
3. Inertia partial reload (`only: ['restaurants', 'filters']`)
4. Backend re-executes pipeline with new parameters
5. Response updates only dataset props, preserving UI state

*Client-Only Flow (Search & Selection):*

1. User types in search box
2. Hook filters restaurant array with Fuse.js
3. Filtered results update map markers and list
4. No server request (client-side only)

This hybrid approach optimizes for responsiveness: dataset changes require server validation (radius enforcement, scoring), but UI interactions (search, selection) remain instant through client-side state.

==== Controlled Map Component Pattern

The Map component follows React's controlled component pattern: view state (latitude, longitude, zoom, bearing, pitch) is managed by the parent hook and passed down as props. Camera movements trigger an `onMove` callback that updates the parent state, which flows back down as props.

This architecture enables:
- Programmatic camera control (flying to selected restaurant)
- Conditional rendering based on view state (showing "Search Here" button)
- Preserving camera position across dataset updates
- Testability (mock view state in tests)

The alternative - uncontrolled component with internal ref access - would scatter view state across components and make state synchronization fragile.

==== Geolocation Integration Pattern

Geolocation uses a callback registration pattern to bridge the gap between the Mapbox `GeolocateControl` (which has its own UI and lifecycle) and the custom overlay controls.

Flow:
1. Map component renders hidden `GeolocateControl`
2. Geolocation hook inside Map registers a trigger function via callback
3. Page-level hook stores the trigger function in a ref
4. Overlay "My Location" button calls the trigger function
5. Control acquires location and fires success/error events
6. Events propagate to page hook, which updates state and navigates

This pattern decouples the UI (custom button in overlay) from the implementation (Mapbox control) while maintaining clean component boundaries. The trigger function serves as a stable interface across component re-renders.

=== Data Architecture and Flow Patterns

==== Query Optimization Strategy

The backend query architecture prioritizes single-pass computation:

- Distance is calculated once using a subquery and reused in scoring
- Review counts are pre-aggregated via grouped subquery, not correlated `COUNT(*)`
- Composite score is computed once in a derived table
- Final ordering happens directly on derived columns

This strategy reflects the architectural principle of "compute once, use many times". Rather than recalculating distance in multiple `SELECT` clauses or `ORDER BY` expressions, the architecture uses SQL subqueries to establish a single source of truth.

The derived table pattern (`fromSub`, `joinSub`) allows complex scoring while still returning Eloquent models. This hybrid approach balances SQL efficiency with Laravel's ORM convenience.

==== Bounding Box Prefilter Pattern

The architecture uses a two-stage spatial filter:

1. *Coarse filter (bounding box):* `WHERE latitude BETWEEN ... AND longitude BETWEEN ...`
2. *Exact filter (distance):* `HAVING ST_Distance_Sphere(...) <= radius`

This reflects the architectural tradeoff between index efficiency and computation cost. Bounding box queries use simple indexed range scans, reducing the candidate set before expensive spherical distance calculations. The HAVING clause ensures accuracy while benefiting from the reduced dataset.

Alternative architectures (spatial indexes on geometry columns, R-tree indexes) were not chosen because they require schema changes and don't benefit `ST_Distance_Sphere` on coordinate columns.

==== Payload Shaping and Lazy Loading

The architecture deliberately separates discovery data from detail data:

- Map endpoint loads: restaurant metadata, single primary image, distance, score
- Map endpoint omits: full menu hierarchy, all images, reviews

This reflects the architectural principle of "load what you display". The map UI doesn't render menus, so loading them wastes bandwidth. When users click a restaurant, a separate detail page loads the full dataset.

This pattern follows a lazy loading architecture: load minimal data eagerly for browsing, fetch detailed data on-demand for interaction.

=== Architectural Guarantees and Invariants

The map architecture enforces several key invariants:

*Radius Determinism:*

When `radius > 0`, the result set contains only restaurants within that distance. This is enforced via SQL HAVING, not application filtering, ensuring the database engine upholds the constraint.

*Score Stability:*

Composite scores are computed exactly once in SQL. No PHP code modifies scores or reorders results. This guarantees that what the database orders is what the user sees.

*Center Point Uniqueness:*

Phase A guarantees exactly one center point per request. The priority cascade is deterministic, so repeated requests with identical parameters produce identical centers.

*Session Isolation:*

User location and search center are separate concepts. Exploring a new area (`search_lat`/`search_lng`) does not overwrite the persistent user location (`lat`/`lng`). This allows exploration without losing context.

*UI State Preservation:*

Partial Inertia reloads update only the dataset, not UI state. Camera position, selection, and overlay state persist across filter changes, maintaining spatial orientation.

These guarantees reflect deliberate architectural choices that prioritize predictability and user experience over implementation simplicity.

=== Integration Architecture

==== Inertia.js Bridge Pattern

// TODO: Check this once we write the general section about Inertia to avoid duplication and make sure thesis flows well.

The architecture uses Inertia as a bridge between Laravel (server) and React (client), providing SPA-like navigation without API route duplication. Key architectural benefits:

- Single routing definition (Laravel routes serve both HTML and JSON)
- Automatic CSRF protection without manual token handling
- Progressive enhancement (works without JavaScript via server-side rendering)
- Type-safe props via TypeScript interfaces

The map feature leverages Inertia's partial reload capability to update only the dataset while preserving component state. This reflects a hybrid architecture: server-authoritative data combined with client-side UI state.

==== Mapbox Integration Architecture

The map visualization uses a layered architecture:

*Data Layer:* GeoJSON source with restaurant features
*Clustering Layer:* Mapbox-native clustering (configured at source level)
*Visual Layers:* Cluster circles, point circles, selected point overlay
*Interaction Layer:* Click handlers, hover effects, popup management

This separation allows independent control: data updates don't require re-configuring layers, and visual styling changes don't affect data structure. The architecture uses Mapbox's declarative layer system rather than imperative canvas drawing, enabling GPU-accelerated rendering.

=== Scalability and Performance Architecture

The architecture incorporates several design decisions that support scalability:

*Hard Result Limit:*

The 250-restaurant limit protects against unbounded queries, excessive JSON payloads, and client-side rendering costs. This is an architectural safeguard, not a temporary optimization.

*Database-Level Computation:*

All scoring and ordering happens in SQL, leveraging MariaDB's query optimizer. This scales better than fetching all candidates and sorting in PHP.

*Client-Side Search:*

The fuzzy search filter runs entirely in the browser using Fuse.js. This offloads computation to the client and avoids network latency for interactive search.

*Strategic Indexing:*

Separate indexes on `latitude` and `longitude` enable efficient bounding box filters. The index merge optimization allows MariaDB to combine them without a composite index.

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
