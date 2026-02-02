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

=== Map Library: Mapbox GL

The restaurant discovery feature requires an interactive map for browsing nearby establishments. *Mapbox GL* was selected over alternatives such as Google Maps and Leaflet for its balance of features, performance, and cost structure. Mapbox provides vector-based rendering that maintains visual quality at any zoom level, while its free tier accommodates the project's expected usage volume. The *React Map GL* wrapper integrates Mapbox with React's component model, enabling declarative map configuration consistent with the rest of the frontend.

=== Styling with SCSS

All styling uses *SCSS* (Sass) with semantic class names following BEM-like conventions. Despite Tailwind CSS being present in the project dependencies, utility classes are prohibited in component files per project guidelines.

The SCSS architecture organizes styles into logical partials:

- *Variables* — Centralized color, spacing, and typography definitions. Changing a brand color in one file updates the entire application consistently.

- *Components* — Styles scoped to specific UI components. Each component's styles reside in a dedicated partial, preventing unintended cascade effects.

- *Layouts* — Structural styles for page layouts, navigation, and content areas.

- *Pages* — Page-specific overrides when component styles require contextual adjustments.

SCSS variables generate CSS custom properties at build time, making theme values accessible to JavaScript when needed for dynamic styling or third-party library integration.

=== Build Tooling with Vite

*Vite* serves as the frontend build tool, replacing older bundlers like Webpack. Vite offers:

- *Instant Development Server* — Vite serves source files directly during development using native ES modules. Changes appear in the browser almost instantly without full bundle rebuilds.

- *Hot Module Replacement* — Component changes update in the browser while preserving application state. Developers see styling and logic changes immediately without losing their current navigation context.

- *Optimized Production Builds* — Production builds use Rollup for efficient code splitting, tree shaking, and minification. The resulting bundles load quickly even on slower connections.

- *Laravel Integration* — The Laravel Vite plugin coordinates asset compilation with Laravel's asset versioning and path resolution, ensuring correct asset URLs in both development and production environments.
