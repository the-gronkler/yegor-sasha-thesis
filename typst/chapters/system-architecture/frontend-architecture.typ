#import "../../config.typ": code_example, source_code_link

== Frontend Architecture <frontend-architecture>

The frontend architecture organizes React components into a layered hierarchy that promotes reusability and separation of concerns. This structure establishes clear boundaries between abstraction levels and defines patterns for state management and component communication.

=== Component Hierarchy

The architecture employs a three-tier hierarchy inspired by atomic design @FrostAtomicDesign2016. _Page Components_ correspond to application routes, orchestrating composition of lower-level components while delegating complex logic to custom hooks. _Layout Components_ provide persistent structural elements wrapping page content, persisting across navigation through Inertia.js to maintain state. _Reusable Components_ split into UI Components (generic interface elements) and Shared Components (domain-specific presentation logic). _Custom Hooks_ encapsulate shared logic (authentication, search, real-time subscriptions) or extract complexity from individual components. The directory structure mirrors this hierarchy, enabling location via URL patterns (detailed in @frontend-implementation).

=== State & Data Flow

The application employs local state as default, elevating to global contexts only when necessary. _Local State_ serves most components through React's state hooks managing UI toggles, form inputs, and view-specific data. _Global State_ uses React Context when multiple unrelated components require shared access (e.g., shopping cart data consumed by menu buttons, cart page, and navigation badge). Context providers initialize from server data and synchronize with Inertia navigation events. _Server State_ flows through Inertia's shared props mechanism—authentication state, user profiles, and application data arrive as page props maintaining server authority. _Route Configuration_ uses Ziggy exposing Laravel's named routes to JavaScript (e.g., `route('restaurants.show', restaurantId)`), maintaining URL consistency when backend routes change. Components communicate through props for parent-child relationships, with callbacks propagating actions upward. Real-time updates integrate Laravel broadcasting with Inertia—hooks subscribe to channels and trigger prop refreshes when events occur. Concrete implementation detailed in @frontend-implementation.

=== Styling Architecture

Component styling separates structure from presentation. React components reference semantic class names describing element purpose, while SCSS stylesheets define visual appearance.

The SCSS codebase organizes into modules: design tokens for colors, spacing, and typography; component-specific partials matching React components; layout styles; and page-specific overrides. This mirrors the component hierarchy and enables independent styling without cross-component interference.

The application employs mobile-first responsive design @WroblewskiMobileFirst2011. Base styles target mobile viewports, with media queries progressively enhancing for larger screens. Layout components handle structural adaptation (bottom navigation for mobile, alternative arrangements for desktop), while atomic components remain viewport-agnostic. Customer interfaces prioritize mobile optimization; employee interfaces optimize for desktop workflows.

=== Error Handling

React Error Boundaries @ReactErrorBoundaries catch rendering errors in component subtrees, displaying fallback UI rather than crashing the entire interface. This isolates failures to specific sections while maintaining overall application stability.

Server-side errors flow through Inertia's error handling. Validation errors appear in page props for form feedback. Network and server failures trigger error callbacks, enabling appropriate responses—reverting optimistic updates, displaying notifications, or redirecting to error pages.
