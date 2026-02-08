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

The frontend uses *TypeScript 5.9* with strict compiler settings, adding static type checking that catches errors during development, provides intelligent autocompletion, and improves developer productivity.

=== Styling: SCSS Over Utility-First CSS

All styling uses *SCSS* (Sass) with semantic class names following BEM-like conventions. SCSS was selected for its maintainability, DRY capabilities, and ability to generate CSS custom properties accessible to JavaScript for dynamic styling.

=== Build Tooling with Vite

*Vite* serves as the frontend build tool @ViteDocs, providing instant development server via native ES modules, hot module replacement preserving application state, optimized production builds with code splitting and tree shaking, and Laravel integration for asset versioning.

=== Client-Side Search with Fuse.js <tech-fuse>

*Fuse.js* provides fuzzy search filtering for client-side datasets across multiple features @FuseJSDocs. This client-side approach was selected because features work with bounded datasets already loaded to the client, eliminating network latency. Fuse.js offers fuzzy matching (typo tolerance), weighted keys (field prioritization), configurable threshold (match strictness), and nested property search. The trade-off is that it operates only on loaded data; comprehensive database search would require server-side implementation.
