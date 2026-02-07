#import "../../config.typ": code_example, source_code_link

== Frontend Architecture <frontend-architecture>

The frontend architecture organizes React components into a layered hierarchy that promotes reusability and separation of concerns. This structure establishes clear boundaries between abstraction levels and defines patterns for state management and component communication.

=== Component Hierarchy

The architecture employs a three-tier component hierarchy inspired by atomic design principles.

_Page Components_ represent the top level, corresponding directly to application routes. Pages receive data from Laravel controllers via Inertia.js and orchestrate composition of lower-level components. Complex logic delegates to custom hooks, keeping pages focused on assembly and data distribution.

_Layout Components_ provide persistent structural elements wrapping page content. Layouts persist across navigation through Inertia.js, maintaining state while only inner content updates. This prevents unnecessary remounting and preserves component state during navigation.

_Reusable Components_ split into two categories. UI Components (Atoms) provide generic interface elements without domain awareness. Shared Components (Molecules) combine atoms with domain-specific presentation logic, formatting business data for display.

_Custom Hooks_ serve two purposes. Reusable hooks encapsulate shared logic across components—authentication utilities, configurable search, real-time update subscriptions. Component-specific hooks extract complex logic from individual components when complexity warrants separation, transforming components into purely presentational elements.

The directory structure mirrors this hierarchy: pages organize by user role mirroring backend routes, layouts provide structural wrappers, components separate into generic UI elements and domain-specific shared components, and hooks encapsulate stateful logic. This organization enables locating components through URL patterns.

=== State & Data Flow

The application employs local state as the default, elevating to global contexts only when necessary.

_Local State_ serves most components through React's state hooks. Components manage UI toggles, form inputs, and view-specific data locally. Custom hooks encapsulate complex local state logic.

_Global State_ uses React Context when multiple unrelated components require shared access. Context providers wrap the component tree, exposing state and mutation functions to any descendant. Components consume context directly without receiving props through intermediate layers. For example, the shopping cart uses a CartContext provider that holds cart items and exposes functions to add, update, or remove items. Menu buttons, the cart page, and the navigation badge all consume this context independently. The cart initializes from server data via Inertia shared props, updates optimistically for immediate feedback, then persists changes through server requests.

_Server State_ flows through Inertia's shared props mechanism. Authentication state, user profiles, and application data arrive as page props rather than client-side fetches. This maintains the server as the authoritative data source.

Components communicate through props for parent-child relationships, with callbacks propagating user actions upward. Real-time updates integrate Laravel broadcasting with Inertia—hooks subscribe to channels and trigger prop refreshes when events occur, providing reactivity without polling.

=== Styling Architecture

Component styling separates structure from presentation. React components reference semantic class names describing element purpose, while SCSS stylesheets define visual appearance.

The SCSS codebase organizes into modules: design tokens for colors, spacing, and typography; component-specific partials matching React components; layout styles; and page-specific overrides. This mirrors the component hierarchy and enables independent styling without cross-component interference.

The application employs mobile-first responsive design. Base styles target mobile viewports, with media queries progressively enhancing for larger screens. Layout components handle structural adaptation (bottom navigation for mobile, alternative arrangements for desktop), while atomic components remain viewport-agnostic. Customer interfaces prioritize mobile optimization; employee interfaces optimize for desktop workflows.

=== Error Handling

React Error Boundaries catch rendering errors in component subtrees, displaying fallback UI rather than crashing the entire interface. This isolates failures to specific sections while maintaining overall application stability.

Server-side errors flow through Inertia's error handling. Validation errors appear in page props for form feedback. Network and server failures trigger error callbacks, enabling appropriate responses—reverting optimistic updates, displaying notifications, or redirecting to error pages.
