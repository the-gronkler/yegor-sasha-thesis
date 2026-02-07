#import "../../config.typ": code_example, source_code_link

== Frontend-Backend Integration: Inertia.js <inertia-technology>

Modern web applications typically choose between two architectural approaches: traditional server-rendered applications with full page reloads, or single-page applications (SPAs) that consume a separate API. Each approach involves trade-offs between developer experience, performance, and complexity. *Inertia.js 2.0* offers a third option that combines advantages of both approaches.

=== Integration Approach Selection

When designing the connection between the Laravel backend and React frontend, three primary approaches were evaluated:

*Traditional REST API with SPA* — The conventional approach separates the backend into a stateless API that returns JSON, while the frontend maintains its own routing, state management, and data fetching logic. This architecture requires maintaining two separate applications: the API with its own authentication, validation responses, and error handling, plus a frontend application that duplicates route definitions and implements client-side data fetching. For small teams, this duplication increases development overhead and creates synchronization challenges when requirements change.

*GraphQL* — GraphQL addresses some API flexibility concerns by allowing clients to request exactly the data they need. However, it introduces additional complexity through schema definitions, resolver implementations, and client-side query management. For an application with well-defined page structures and predictable data requirements, GraphQL's flexibility provides limited benefit while adding infrastructure overhead.

*Server-Driven SPA (Inertia.js)* — Inertia eliminates the API layer entirely. The server renders responses that include both the page component name and its required data as JSON. The frontend receives this payload and renders the appropriate component, while Inertia handles navigation through XHR requests rather than full page reloads. This approach maintains the server as the single source of truth for routing, authentication, and data while preserving the reactive experience of a modern SPA.

=== Rationale for Inertia.js

Inertia.js was selected for the following reasons:

*Single Source of Truth* — Routes, authentication, authorization, and validation remain entirely on the server. There is no need to implement API endpoints, configure CORS, manage API tokens for the frontend, or duplicate validation logic. Laravel handles all these concerns through its established patterns, and the frontend simply receives the results.

*Reduced Duplication* — Traditional SPAs require defining routes twice: once on the backend API and once in the frontend router. With Inertia, routes exist only in Laravel. When a URL changes or a new page is added, the modification occurs in one location. This eliminates an entire category of synchronization errors.

*Simplified Data Flow* — Controllers pass data directly to page components as props. There is no need for frontend data fetching libraries, loading state management for initial page loads, or caching strategies. The page component receives its data before rendering, similar to traditional server-rendered applications but with client-side navigation.

*Laravel Ecosystem Integration* — Inertia was developed alongside Laravel and maintains first-class integration. Laravel's middleware, session handling, CSRF protection, and validation errors work seamlessly. The Laravel community provides extensive documentation, tutorials, and support specifically for the Inertia integration.

*Partial Reloads* — Interactive pages frequently need to refresh a subset of data without discarding client-side state (scroll position, open menus, selected items). In a traditional server-rendered application, this requires a full page reload that destroys all UI state. In a conventional SPA, it requires a manually implemented AJAX layer with custom state merging. Inertia's partial reload mechanism solves this by allowing components to request only specific props via the `only` option - the server re-executes only the requested prop closures and returns a minimal JSON payload, which Inertia merges into the existing page state without a full re-render. The `replace: true` option further prevents intermediate states from polluting browser history when filters change rapidly. This capability was a significant factor in selecting Inertia, as several application features (map filter adjustments, list sorting, search refinement) rely on frequent data updates that must preserve surrounding UI state.

*Progressive Enhancement Path* — While Inertia handles the primary application flow, it does not prevent using traditional API endpoints where needed. Real-time features, background updates, or third-party integrations can still use conventional HTTP or WebSocket communication alongside Inertia's page-based navigation.

=== Complementary Technology: Ziggy

The *Ziggy* package complements Inertia by exposing Laravel's named routes to the JavaScript frontend. Rather than hardcoding URL paths in React components, developers reference routes by name. When backend routes change, the frontend automatically uses the updated paths. This maintains URL consistency between server and client without manual synchronization.

