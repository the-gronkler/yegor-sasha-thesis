#import "../../config.typ": code_example, source_code_link

== Frontend Framework: React 19

The frontend of the system is built on *React 19*, a JavaScript library for building user interfaces. This section explains the rationale behind selecting React and describes the key frontend technologies and patterns employed throughout the project.

=== Framework Selection Rationale

When selecting a frontend framework, three primary candidates were evaluated: React, Vue.js, and Angular. React was chosen based on the comparative analysis in @tbl:react-comparison.

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    align: (left, left, left, left),
    [*Criterion*], [*React*], [*Vue.js*], [*Angular*],
    [Ecosystem], [Largest and most diverse @StackOverflowSurvey2024], [Excellent official packages, smaller third-party ecosystem], [Mature but tightly coupled to framework],
    [Inertia Integration], [Primary target, best documentation and support], [Functional adapter with fewer examples], [Experimental support, not production-ready],
    [Component Model], [Composition-based, highly reusable], [Single-file components, complicates styling reuse], [Powerful but requires understanding directives, pipes, DI],
    [State API], [Hooks API for functional patterns @ReactHooksDocs], [Composition API inspired by React hooks @VueCompositionAPIRFC], [Services with dependency injection, more boilerplate],
    [TypeScript], [Optional, gradual adoption with strong inference], [Improved in Vue 3, historically weaker], [Mandatory usage @AngularDocs],
    [Industry Adoption], [Most widely adopted @StackOverflowSurvey2024], [Growing adoption], [Declining popularity],
  ),
  caption: [Frontend Framework Comparison]
) <tbl:react-comparison>

=== TypeScript: Type Safety for JavaScript

The frontend uses *TypeScript 5.9* with strict compiler settings. TypeScript adds static type checking to JavaScript, catching errors during development rather than at runtime. This reduces debugging time and prevents entire categories of errors that would otherwise only surface in production environments. TypeScript's integration with modern code editors provides intelligent autocompletion, inline documentation, and refactoring support, significantly improving developer productivity when working with large codebases.

=== Styling: SCSS Over Utility-First CSS

All styling uses *SCSS* (Sass) with semantic class names following BEM-like conventions. Although Tailwind CSS is included in the project dependencies to support Inertia.js architecture, utility classes are not used in any React components

SCSS was selected over utility-first approaches (Tailwind CSS) and plain CSS for several reasons. SCSS's variables, mixins, and nesting capabilities enable maintainable, DRY (Don't Repeat Yourself) stylesheets without the verbose class lists common in utility-first frameworks. Semantic class names provide clearer intent than utility combinations, improving code readability and maintainability. SCSS's ability to generate CSS custom properties at build time makes theme values accessible to JavaScript when needed for dynamic styling or third-party library integration, providing flexibility that pure utility frameworks lack.

=== Build Tooling with Vite

*Vite* serves as the frontend build tool, replacing older bundlers like Webpack @ViteDocs. Vite offers:

- *Instant Development Server* — Vite serves source files directly during development using native ES modules @ViteDocs. Changes appear in the browser almost instantly without full bundle rebuilds.

- *Hot Module Replacement* — Component changes update in the browser while preserving application state. Developers see styling and logic changes immediately without losing their current navigation context.

- *Optimized Production Builds* — Production builds use Rollup for efficient code splitting, tree shaking, and minification. The resulting bundles load quickly even on slower connections.

- *Laravel Integration* — The Laravel Vite plugin coordinates asset compilation with Laravel's asset versioning and path resolution, ensuring correct asset URLs in both development and production environments.

=== Client-Side Search with Fuse.js <tech-fuse>

*Fuse.js* provides fuzzy search filtering for client-side datasets across multiple features including restaurant discovery, menu browsing, and order lists @FuseJSDocs. When users type in search boxes, Fuse.js filters data locally without requiring server requests, providing instant feedback.

This client-side approach was selected because many features work with bounded datasets already loaded to the client (restaurants within a geographic radius, menu items for a single restaurant, a customer's order history). Performing fuzzy search on these pre-loaded sets is computationally trivial for modern browsers and eliminates network latency that would occur with server-side search on every keystroke.

Fuse.js offers several capabilities that make it well-suited for this use case:

- *Fuzzy Matching* — Tolerates typos and partial matches, improving search success rates when users misspell restaurant or menu item names.

- *Weighted Keys* — Allows prioritizing certain fields over others in search relevance. For example, restaurant names can rank higher than descriptions, ensuring exact name matches appear first even if descriptions contain the search term.

- *Configurable Threshold* — The threshold parameter controls match strictness, balancing typo tolerance against false positives. A threshold of 0.3 (requiring 70% match quality) has proven effective across different feature contexts.

- *Nested Property Search* — Supports searching within nested objects and arrays, enabling searches across relationships like "search menu items within food types within restaurants" without flattening data structures.

The library integrates naturally with React through custom hooks that encapsulate Fuse.js configuration and memoization patterns, providing a reusable search abstraction across the application. The implementation details of this integration pattern are described in @frontend-implementation.

The trade-off of client-side search is that it operates only on data already loaded to the browser. For comprehensive search across entire databases (useful in administrative interfaces or global search features), server-side search with database indexing would be necessary. However, for feature-specific search within already-filtered datasets, client-side filtering provides superior user experience through instant feedback.
