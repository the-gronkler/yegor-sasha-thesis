#import "../../config.typ": code_example, source_code_link

== Frontend Architecture <frontend-architecture>

The frontend architecture organizes React components into a layered hierarchy that promotes reusability and separation of concerns. This structure establishes clear boundaries between abstraction levels and defines patterns for state management and component communication.

=== Component Hierarchy

The architecture employs a three-tier component hierarchy inspired by atomic design principles @FrostAtomicDesign2016.

_Page Components_ represent the top level, corresponding directly to application routes. Pages receive data from Laravel controllers via Inertia.js and orchestrate composition of lower-level components. Complex logic delegates to custom hooks, keeping pages focused on assembly and data distribution.

_Layout Components_ provide persistent structural elements wrapping page content. Layouts persist across navigation through Inertia.js, maintaining state while only inner content updates. This prevents unnecessary remounting and preserves component state during navigation.

_Reusable Components_ split into two categories. UI Components (Atoms) provide generic interface elements without domain awareness. Shared Components (Molecules) combine atoms with domain-specific presentation logic, formatting business data for display.

_Custom Hooks_ serve two purposes. Reusable hooks encapsulate shared logic across components - authentication utilities, configurable search, real-time update subscriptions. Component-specific hooks extract complex logic from individual components when complexity warrants separation, transforming components into purely presentational elements.

The directory structure mirrors this hierarchy, enabling developers to locate components through URL patterns. The concrete directory layout and file organization are detailed in @frontend-implementation.

=== State & Data Flow

The application employs local state as the default, elevating to global contexts only when necessary.

_Local State_ serves most components through React's state hooks. Components manage UI toggles, form inputs, and view-specific data locally. Custom hooks encapsulate complex local state logic.

_Global State_ uses React Context when multiple unrelated components require shared access. Context providers wrap the component tree, exposing state and mutation functions to any descendant. Components consume context directly without receiving props through intermediate layers. This pattern is applied where state must be accessible from structurally distant components - for example, shopping cart data consumed by menu buttons, the cart page, and the navigation badge simultaneously. Context providers initialize from server-provided data and synchronize with Inertia navigation events to maintain server authority over client state. The concrete implementation of this pattern is detailed in @frontend-implementation.

_Server State_ flows through Inertia's shared props mechanism. Authentication state, user profiles, and application data arrive as page props rather than client-side fetches. This maintains the server as the authoritative data source.

_Route Configuration_ uses Ziggy to expose Laravel's named routes to JavaScript. Components navigate using `route('restaurants.show', restaurantId)` rather than hardcoded paths like `/restaurants/${restaurantId}`. This approach maintains URL consistency between server and client - when backend routes change, the frontend automatically uses updated paths without manual synchronization. Route configuration arrives as shared props through Inertia, providing access to all named routes and current location information.

Components communicate through props for parent-child relationships, with callbacks propagating user actions upward. Real-time updates integrate Laravel broadcasting with Inertia - hooks subscribe to channels and trigger prop refreshes when events occur, providing reactivity without polling.

=== Styling Architecture

Component styling separates structure from presentation. React components reference semantic class names describing element purpose, while SCSS stylesheets define visual appearance.

The SCSS codebase organizes into modules: design tokens for colors, spacing, and typography; component-specific partials matching React components; layout styles; and page-specific overrides. This mirrors the component hierarchy and enables independent styling without cross-component interference.

The application employs mobile-first responsive design @WroblewskiMobileFirst2011. Base styles target mobile viewports, with media queries progressively enhancing for larger screens. Layout components handle structural adaptation (bottom navigation for mobile, alternative arrangements for desktop), while atomic components remain viewport-agnostic. Customer interfaces prioritize mobile optimization; employee interfaces optimize for desktop workflows.

=== Error Handling

React Error Boundaries @ReactErrorBoundaries catch rendering errors in component subtrees, displaying fallback UI rather than crashing the entire interface. This isolates failures to specific sections while maintaining overall application stability.

Server-side errors flow through Inertia's error handling. Validation errors appear in page props for form feedback. Network and server failures trigger error callbacks, enabling appropriate responses - reverting optimistic updates, displaying notifications, or redirecting to error pages.
