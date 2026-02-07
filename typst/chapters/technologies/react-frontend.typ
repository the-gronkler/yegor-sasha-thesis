#import "../../config.typ": code_example, source_code_link

== Frontend Framework: React 19

The frontend of the system is built on *React 19*, a JavaScript library for building user interfaces. This section explains the rationale behind selecting React and describes the key frontend technologies and patterns employed throughout the project.

=== Framework Selection Rationale

When selecting a frontend framework, three primary candidates were evaluated: React, Vue.js, and Angular. Each framework has proven capable of building complex single-page applications, but React was chosen for the following reasons:

*Ecosystem Maturity and Community Support* — React's ecosystem significantly surpasses both Vue.js and Angular in size and diversity. While Vue.js offers excellent official packages (Vue Router, Pinia), its third-party ecosystem remains smaller, limiting options for specialized requirements such as advanced data visualization, complex form handling, or specific UI component libraries. Angular's ecosystem, though mature, remains tightly coupled to the framework's opinionated architecture, requiring developers to adopt Angular-specific solutions rather than leveraging the broader JavaScript ecosystem. React's flexibility allows integration with any compatible library, providing greater adaptability as project requirements evolve.

*Inertia.js Integration Quality* — Inertia.js was originally developed alongside Laravel with React as the primary frontend target. While Inertia adapters exist for Vue.js and Angular, the React implementation receives the most attention, documentation, and community support. The Vue.js adapter, though functional, has fewer real-world examples and community-contributed patterns available. Angular's Inertia support remains experimental and lacks the production-ready stability required for a reliable application. Choosing React ensures access to the most mature Inertia integration, reducing integration risks and development overhead.

*Component Model and Reusability* — React's component model emphasizes composition over configuration, aligning well with the application's UI requirements. The restaurant discovery interface, order management screens, and employee dashboards share common elements (cards, buttons, forms, modals) that benefit from React's composable approach. Vue.js achieves similar composability, but its single-file component structure combines template, logic, and styling in one file, which can complicate component reuse when styling needs differ across contexts. Angular's component model, while powerful, requires understanding directives, pipes, and dependency injection before achieving similar levels of reusability, increasing the learning curve for new developers joining the project.

*Hooks API vs. Alternatives* — React's hooks API provides a functional programming approach to state management and side effects without the complexity of class-based components. Custom hooks enable extraction of reusable logic for authentication, cart management, geolocation, and real-time updates, reducing code duplication across components. Vue 3's Composition API offers similar capabilities and was directly inspired by React hooks, but Vue's ecosystem had less mature patterns for hook-based development at the time of technology selection. Angular's reliance on services and dependency injection requires more boilerplate code to achieve similar separation of concerns, particularly when sharing stateful logic between components.

*Developer Experience and Tooling* — React's developer tools and debugging capabilities surpass those of competing frameworks. The React DevTools browser extension provides detailed component hierarchy inspection, prop and state analysis, and performance profiling. While Vue Devtools offer comparable functionality for Vue applications, the React tools benefit from wider adoption and more frequent updates. Angular's debugging tools, though comprehensive, require understanding Angular's zone-based change detection and dependency injection system, adding cognitive overhead during development and troubleshooting.

*TypeScript Integration* — While all three frameworks support TypeScript, their approaches differ significantly. Angular mandates TypeScript usage, which ensures type safety but removes flexibility for teams preferring gradual adoption. Vue.js supports TypeScript but historically had weaker type inference, particularly with the Options API (Vue 3's Composition API improved this considerably). React treats TypeScript as optional, allowing gradual adoption while providing excellent type inference through community-maintained type definitions. This flexibility proved valuable during initial development, enabling rapid prototyping in JavaScript before adding type safety to critical components.

*Industry Adoption and Hiring Considerations* — React remains the most widely adopted frontend framework in the industry. According to Stack Overflow's developer surveys and npm download statistics, React consistently shows higher usage than Vue.js and Angular. This widespread adoption ensures future maintainability, as developers joining the project are statistically more likely to possess React experience than expertise in Vue or Angular. Additionally, the abundance of React developers in the job market reduces hiring friction compared to frameworks with smaller talent pools.

=== TypeScript: Type Safety for JavaScript

The frontend uses *TypeScript 5.9* with strict compiler settings. TypeScript adds static type checking to JavaScript, catching errors during development rather than at runtime. This reduces debugging time and prevents entire categories of errors that would otherwise only surface in production environments. TypeScript's integration with modern code editors provides intelligent autocompletion, inline documentation, and refactoring support, significantly improving developer productivity when working with large codebases.

=== Styling: SCSS Over Utility-First CSS

All styling uses *SCSS* (Sass) with semantic class names following BEM-like conventions. Although Tailwind CSS is included in the project dependencies to support Inertia.js architecture, utility classes are not used in any React components

SCSS was selected over utility-first approaches (Tailwind CSS) and plain CSS for several reasons. SCSS's variables, mixins, and nesting capabilities enable maintainable, DRY (Don't Repeat Yourself) stylesheets without the verbose class lists common in utility-first frameworks. Semantic class names provide clearer intent than utility combinations, improving code readability and maintainability. SCSS's ability to generate CSS custom properties at build time makes theme values accessible to JavaScript when needed for dynamic styling or third-party library integration, providing flexibility that pure utility frameworks lack.

=== Build Tooling with Vite

*Vite* serves as the frontend build tool, replacing older bundlers like Webpack. Vite offers:

- *Instant Development Server* — Vite serves source files directly during development using native ES modules. Changes appear in the browser almost instantly without full bundle rebuilds.

- *Hot Module Replacement* — Component changes update in the browser while preserving application state. Developers see styling and logic changes immediately without losing their current navigation context.

- *Optimized Production Builds* — Production builds use Rollup for efficient code splitting, tree shaking, and minification. The resulting bundles load quickly even on slower connections.

- *Laravel Integration* — The Laravel Vite plugin coordinates asset compilation with Laravel's asset versioning and path resolution, ensuring correct asset URLs in both development and production environments.

=== Client-Side Search with Fuse.js <tech-fuse>

*Fuse.js* provides fuzzy search filtering for client-side datasets across multiple features including restaurant discovery, menu browsing, and order lists. When users type in search boxes, Fuse.js filters data locally without requiring server requests, providing instant feedback.

This client-side approach was selected because many features work with bounded datasets already loaded to the client (restaurants within a geographic radius, menu items for a single restaurant, a customer's order history). Performing fuzzy search on these pre-loaded sets is computationally trivial for modern browsers and eliminates network latency that would occur with server-side search on every keystroke.

Fuse.js offers several capabilities that make it well-suited for this use case:

- *Fuzzy Matching* — Tolerates typos and partial matches, improving search success rates when users misspell restaurant or menu item names.

- *Weighted Keys* — Allows prioritizing certain fields over others in search relevance. For example, restaurant names can rank higher than descriptions, ensuring exact name matches appear first even if descriptions contain the search term.

- *Configurable Threshold* — The threshold parameter controls match strictness, balancing typo tolerance against false positives. A threshold of 0.3 (requiring 70% match quality) has proven effective across different feature contexts.

- *Nested Property Search* — Supports searching within nested objects and arrays, enabling searches across relationships like "search menu items within food types within restaurants" without flattening data structures.

The library integrates naturally with React through custom hooks that encapsulate Fuse.js configuration and memoization patterns, providing a reusable search abstraction across the application. The implementation details of this integration pattern are described in @frontend-implementation.

The trade-off of client-side search is that it operates only on data already loaded to the browser. For comprehensive search across entire databases (useful in administrative interfaces or global search features), server-side search with database indexing would be necessary. However, for feature-specific search within already-filtered datasets, client-side filtering provides superior user experience through instant feedback.
