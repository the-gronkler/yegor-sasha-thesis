#import "../../config.typ": code_example, source_code_link

== Frontend Framework: React 19

The frontend of the system is built on *React 19*, a JavaScript library for building user interfaces. This section explains the rationale behind selecting React and describes the key frontend technologies and patterns employed throughout the project.

=== Framework Selection Rationale

When selecting a frontend framework, three primary candidates were evaluated: React, Vue.js, and Angular. Each framework has proven capable of building complex single-page applications, but React was chosen for the following reasons:

*Ecosystem Maturity and Flexibility* — React offers the largest ecosystem of libraries, tools, and community resources among frontend frameworks. Unlike Angular's opinionated structure or Vue's more integrated approach, React provides flexibility in choosing complementary libraries for routing, state management, and styling. This flexibility proved valuable when integrating with Laravel via Inertia.js, which offers first-class React support.

*Component-Based Architecture* — React's component model aligns naturally with the application's UI requirements. The restaurant discovery interface, order management screens, and employee dashboards share common elements (cards, buttons, forms) that benefit from React's composable component approach. Components encapsulate both structure and behavior, enabling consistent reuse across customer and employee interfaces.

*Hooks and Functional Patterns* — React's hooks API enables clean separation of concerns without class-based complexity. Custom hooks extract reusable logic for authentication, cart management, geolocation, and real-time updates. This pattern reduces code duplication and improves testability compared to traditional lifecycle methods.

*Industry Adoption and Hiring* — React remains the most widely adopted frontend framework in the industry. This adoption ensures long-term maintainability, as future developers are more likely to possess React experience than expertise in less common frameworks.

*TypeScript Integration* — While all major frameworks support TypeScript, React's type definitions and community patterns for typed components have matured significantly. The strict typing requirements outlined in the project guidelines integrate seamlessly with React's functional component patterns.

=== TypeScript: Type Safety for JavaScript

The frontend uses *TypeScript 5.9* with strict compiler settings. TypeScript adds static type checking to JavaScript, catching errors during development rather than at runtime.

The project enforces strict typing rules: the `any` type is prohibited, all component props require explicit interfaces, and shared data models are imported from a centralized location rather than redefined locally. These constraints prevent common JavaScript errors such as accessing properties on undefined values or passing incorrect argument types.

Type definitions for backend models (restaurants, orders, menu items) ensure consistency between Laravel's data structures and React's component expectations. When the backend adds or modifies a field, TypeScript compilation fails if the frontend does not account for the change, providing an additional layer of integration verification.

=== Component Architecture

The component structure follows atomic design principles, organizing components by their scope and reusability:

- *UI Components* — Generic, reusable elements such as buttons, inputs, modals, and cards. These components accept customization through props but contain no domain-specific logic. A button component, for example, handles styling variants and click events without knowledge of whether it submits an order or navigates to a restaurant.

- *Shared Components* — Domain-specific components that combine UI elements with business logic. A restaurant card component displays restaurant information, handles favorite toggling, and navigates to the restaurant detail page. These components understand the application domain but remain reusable across different pages.

- *Page Components* — Full-page views corresponding to Laravel routes. Inertia.js renders these components with data passed from controllers. Page components compose UI and shared components into complete interfaces, handling page-level state and interactions.

- *Layout Components* — Wrappers providing consistent structure across pages. The customer layout includes navigation, footer, and authentication state. The map layout provides the full-screen map interface with overlay controls. Pages declare which layout they use, ensuring visual consistency without code duplication.

=== Custom Hooks for Logic Reuse

React hooks encapsulate reusable logic outside of components. The project employs custom hooks extensively:

- *useAuth* — Provides access to the authenticated user and authentication state. Components use this hook to conditionally render authenticated-only features or redirect unauthenticated users.

- *useCart* — Manages shopping cart state including item addition, removal, and quantity updates. The hook implements optimistic updates, immediately reflecting changes in the UI while synchronizing with the server in the background.

- *useSearch* — Wraps the Fuse.js fuzzy search library, providing filtered results based on user input. The menu page uses this hook to filter menu items as customers type, improving discoverability in large menus.

- *useMapGeolocation* — Abstracts browser geolocation APIs, handling permission requests, error states, and coordinate caching. Map components use this hook without managing geolocation complexity directly.

- *useChannelUpdates* — Subscribes to WebSocket channels for real-time updates. This hook abstracts Laravel Echo configuration, channel authentication, and event handling, allowing components to receive updates with minimal boilerplate.

=== State Management with React Context

The application uses React's built-in Context API for state that spans multiple components. Rather than introducing external state management libraries, the project employs context providers for specific domains:

- *CartContext* — Shopping cart state accessible throughout the ordering flow. The context provider wraps customer pages, enabling any component to access cart contents, add items, or proceed to checkout.

- *LoginModalContext* — Controls the login modal visibility across the application. When unauthenticated users attempt protected actions, any component can trigger the login modal through this context.

A utility function composes multiple providers, avoiding deeply nested JSX when multiple contexts are required. This pattern keeps the component tree readable while providing necessary state access.

For local component state and form handling, the project uses React's `useState` and Inertia's `useForm` hook rather than global state. This approach keeps state close to where it is used, improving component isolation and reducing unnecessary re-renders.

=== Map Integration with Mapbox GL

The restaurant discovery feature centers on an interactive map powered by *Mapbox GL* and its React wrapper, *React Map GL*. The map implementation includes:

- *Marker Clustering* — Restaurants are displayed as markers that cluster at lower zoom levels. As users zoom in, clusters expand to reveal individual restaurant locations. This approach maintains performance even with hundreds of restaurant markers.

- *Geolocation Control* — Users can center the map on their current location with a single tap. The browser's geolocation API provides coordinates, which the map animates to smoothly.

- *Interactive Popups* — Selecting a restaurant marker displays a popup with basic information and a link to the full restaurant page. This preview reduces navigation friction when browsing multiple restaurants.

- *Location Picking* — Restaurant administrators can set their establishment's coordinates by clicking directly on the map. This interaction mode simplifies address entry for locations that may not have precise geocoding results.

=== Styling with SCSS

All styling uses *SCSS* (Sass) with semantic class names following BEM-like conventions. Despite Tailwind CSS being present in the project dependencies, utility classes are prohibited in component files per project guidelines.

The SCSS architecture organizes styles into logical partials:

- *Variables* — Centralized color, spacing, and typography definitions. Changing a brand color in one file updates the entire application consistently.

- *Components* — Styles scoped to specific UI components. Each component's styles reside in a dedicated partial, preventing unintended cascade effects.

- *Layouts* — Structural styles for page layouts, navigation, and content areas.

- *Pages* — Page-specific overrides when component styles require contextual adjustments.

SCSS variables generate CSS custom properties at build time, making theme values accessible to JavaScript when needed for dynamic styling or third-party library integration.

=== Form Handling with Inertia

Forms throughout the application use Inertia's `useForm` hook rather than external form libraries. This hook provides:

- *Type-Safe Form Data* — Form fields are defined with TypeScript types, ensuring compile-time checks for field names and value types.

- *Validation Error Display* — Laravel validation errors automatically populate the form's error state. Components display these errors alongside their corresponding fields without manual error mapping.

- *Processing State* — The hook tracks submission state, enabling loading indicators and preventing duplicate submissions while requests are in flight.

- *Server Communication* — Form submission uses Inertia's router, maintaining the server-driven architecture. Successful submissions can redirect, refresh page data, or preserve scroll position as needed.

This approach eliminates the configuration overhead of dedicated form libraries while integrating seamlessly with Laravel's validation system.

=== Build Tooling with Vite

*Vite* serves as the frontend build tool, replacing older bundlers like Webpack. Vite offers:

- *Instant Development Server* — Vite serves source files directly during development using native ES modules. Changes appear in the browser almost instantly without full bundle rebuilds.

- *Hot Module Replacement* — Component changes update in the browser while preserving application state. Developers see styling and logic changes immediately without losing their current navigation context.

- *Optimized Production Builds* — Production builds use Rollup for efficient code splitting, tree shaking, and minification. The resulting bundles load quickly even on slower connections.

- *Laravel Integration* — The Laravel Vite plugin coordinates asset compilation with Laravel's asset versioning and path resolution, ensuring correct asset URLs in both development and production environments.
