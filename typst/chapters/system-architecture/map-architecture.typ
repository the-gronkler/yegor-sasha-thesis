== Map-Based Discovery Architecture <map-architecture>

This section describes the high-level design of the map-based restaurant discovery feature: the main components, how they communicate, and the architectural guarantees enforced across the request/response boundary. Technology selection (why MariaDB, Mapbox, and Inertia were chosen) is discussed in @map-technologies. Detailed code realization is covered in @map-implementation.

=== Architectural overview

The map feature follows a client-server architecture:

- The backend exposes a single discovery endpoint that returns a bounded, location-aware restaurant dataset.
- The frontend renders an interactive map and a synchronized list, and it triggers dataset refreshes when the user changes filters.

The system intentionally separates *server responsibilities* (validation, filtering, ranking) from *client responsibilities* (visualization, selection, and transient UI state).

=== Component topology

/ *Backend controller*: Accepts filter parameters (location, search center, radius), validates them, and returns the discovery dataset.
/ *Geospatial service*: Provides shared geospatial utilities (e.g., bounding box computation, session-based location retrieval).
/ *Database*: Stores restaurants and related entities and supports distance computation in query execution.
/ *Map page UI*: Hosts the map canvas and the list, and exposes controls for filtering.
/ *Page state layer*: Maintains transient UI state (camera position, current selection, geolocation progress) and coordinates navigation.
/ *Map visualization layer*: Renders markers, clusters, and selection popups.

These components communicate through narrow interfaces: HTTP requests from the page state layer to the controller, service calls inside the backend, and prop/callback contracts between UI components.

=== Backend design

==== Deterministic three-stage pipeline

To keep filtering semantics stable under repeated interactions, the backend request handling is structured as three conceptual stages:

- *Normalize the request center:* Resolve a single center point from possible inputs (explicit search center, user location, session fallback, default).
- *Select geographically nearest candidates:* Build a bounded candidate set based on proximity, enforcing the radius constraint as a hard limit when the radius is enabled.
- *Rank within the candidate set:* Order the candidate set by a quality signal that favors well-rated and popular restaurants while keeping proximity as a tie-breaker.

The core architectural goal is to ensure that radius filtering is applied *before* limiting the result set, so the meaning of "within radius" cannot be diluted by later ranking decisions.

==== Location semantics

The architecture distinguishes two location concepts that serve different interactions:

/ *User location*: The user context location, persisted for continuity across visits.
/ *Search center*: A temporary exploration center used when the user pans the map and triggers a search in the current viewport.

This separation allows exploration without overwriting the persistent user context.

==== Payload shaping

Discovery data is intentionally smaller than restaurant detail data. The discovery endpoint returns only the fields required for browsing (coordinates, basic metadata, images, and ranking-related values), while detail pages load the full menu and review context on demand. This keeps map interaction responsive and avoids unnecessary data transfer.

=== Frontend design

==== UI composition

The map page is composed from specialized UI surfaces:

- *Overlay controls:* Search input, radius control, and location tools.
- *Map canvas:* The primary visualization surface with clustering and selection.
- *Popup:* A lightweight detail surface for the selected restaurant.
- *Bottom sheet list:* A secondary browsing surface that stays synchronized with map selection.

The architectural intent is to keep each surface focused on one responsibility, with a single page-level state layer coordinating interactions between them.

==== State layering

State is intentionally split by ownership:

- *Server state:* The authoritative dataset returned by the backend (restaurants and applied filters).
- *Page state:* Transient UI state owned by the map page (camera position, selected restaurant, geolocation loading/errors, search query).
- *Session state:* A short-lived user location context, used only to improve defaults and continuity.

This separation avoids mixing long-lived persistence with transient UI state and keeps the dataset server-authoritative.

==== Refresh strategy

Filter changes (radius, location, or search center) trigger a navigation back to the same page with updated query parameters. The page requests only the data that must change, while preserving local UI state such as the current map camera and list scroll position. Client-only interactions (search query filtering and selection) do not require server communication.

=== Architectural guarantees

The design enforces the following invariants:

- *Radius determinism:* When a radius is enabled, results outside the radius never appear in the dataset.
- *Bounded results:* The dataset is hard-limited to a fixed maximum per request to protect query cost and client rendering performance.
- *Center uniqueness:* Each request resolves exactly one center point through a deterministic priority cascade.
- *Separation of contexts:* Search center updates do not overwrite the persisted user location.
- *UI stability on refresh:* Dataset refreshes do not reset the map camera or selection by default, preserving spatial orientation.

=== Performance-oriented patterns

The architecture uses complementary techniques to keep both backend and frontend costs predictable:

- *Coarse-to-exact spatial filtering:* Use a cheap coarse filter to reduce candidates, followed by exact distance evaluation for correctness.
- *Database-side ordering:* Perform ordering at the database layer to avoid large in-memory sorts.
- *Client-side clustering:* Cluster markers at low zoom levels to reduce visual noise and rendering load.

=== Summary

The map discovery architecture organizes the chosen technologies into a predictable system: the backend validates and produces a bounded, correctly filtered dataset, while the frontend focuses on visualization and interaction. The result is an interactive browsing feature with stable filtering semantics and a clear separation between server-authoritative data and client-only UI state.
