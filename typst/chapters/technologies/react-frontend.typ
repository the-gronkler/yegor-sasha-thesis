#import "../../config.typ": code_example, source_code_link

== Frontend Framework: React 19

The frontend of the system is built on *React 19*, a JavaScript library for building user interfaces. This section explains the rationale behind selecting React and describes the key frontend technologies and patterns employed throughout the project.

=== Framework Selection Rationale

React was selected after evaluating three candidates: React, Vue.js, and Angular. The primary factors favoring React were its ecosystem maturity and community size @StackOverflowSurvey2024, the most stable and well-documented Inertia.js adapter (Angular's remains experimental), a composition-oriented component model well-suited to the shared UI elements across restaurant discovery, order management, and employee dashboards, and the hooks API that enables extraction of reusable logic without class-based boilerplate @ReactHooksDocs. Vue 3's Composition API @VueCompositionAPIRFC offers comparable capabilities but had less mature community patterns at the time of selection. Angular mandates TypeScript and requires understanding directives, dependency injection, and zone-based change detection @AngularDocs, increasing onboarding overhead. React's industry adoption @StackOverflowSurvey2024 also ensures a larger talent pool for future maintenance.

=== TypeScript: Type Safety for JavaScript

The frontend uses *TypeScript 5.9* with strict compiler settings. TypeScript adds static type checking to JavaScript, catching errors during development rather than at runtime. This reduces debugging time and prevents entire categories of errors that would otherwise only surface in production environments. TypeScript's integration with modern code editors provides intelligent autocompletion, inline documentation, and refactoring support, significantly improving developer productivity when working with large codebases.

=== Styling: SCSS Over Utility-First CSS

All styling uses *SCSS* (Sass) with semantic class names following BEM-like conventions. Although Tailwind CSS is included in the project dependencies to support Inertia.js architecture, utility classes are not used in any React components

SCSS was selected over utility-first approaches (Tailwind CSS) and plain CSS for several reasons. SCSS's variables, mixins, and nesting capabilities enable maintainable, DRY (Don't Repeat Yourself) stylesheets without the verbose class lists common in utility-first frameworks. Semantic class names provide clearer intent than utility combinations, improving code readability and maintainability. SCSS's ability to generate CSS custom properties at build time makes theme values accessible to JavaScript when needed for dynamic styling or third-party library integration, providing flexibility that pure utility frameworks lack.

=== Build Tooling with Vite

*Vite* serves as the frontend build tool @ViteDocs, replacing older bundlers like Webpack. It leverages native ES modules for instant development server startup and hot module replacement, preserving application state during edits. Production builds use Rollup for code splitting, tree shaking, and minification. The Laravel Vite plugin coordinates asset compilation with Laravel's asset versioning and path resolution.

=== Client-Side Search with Fuse.js <tech-fuse>

*Fuse.js* provides fuzzy search filtering for client-side datasets across restaurant discovery, menu browsing, and order lists @FuseJSDocs. This client-side approach was selected because many features operate on bounded datasets already loaded to the client (restaurants within a geographic radius, menu items for a single restaurant), making local fuzzy search computationally trivial while eliminating network latency on every keystroke.

Fuse.js supports fuzzy matching with typo tolerance, weighted keys for relevance tuning, configurable match thresholds, and nested property search across relationships. The library integrates with React through custom hooks that encapsulate configuration and memoization patterns, as described in @frontend-implementation. The trade-off is that search operates only on data already in the browser; comprehensive search across entire databases would require server-side indexing.
