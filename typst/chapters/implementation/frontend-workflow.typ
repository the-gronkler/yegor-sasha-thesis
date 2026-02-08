#import "../../config.typ": code_example, source_code_link

==== Development Workflow and Module Boundaries

The component architecture enables efficient development workflows through clear module boundaries and hot module replacement. These boundaries isolate changes and reduce iteration time during feature development.

===== Component Isolation and Change Impact

The layered component hierarchy limits the scope of changes. Modifications to UI atoms affect only their direct consumers, while page-level changes remain route-isolated without cascading to unrelated features.

For example, changing the `Button` component's styling requires rebuilding all pages that import it, but the TypeScript type system and bundler ensure only affected modules recompile. Modifying a specific customer page affects only that route's code chunk.

===== Vite Hot Module Replacement

The Vite development server provides hot module replacement (HMR) that updates changed modules in the running application without full page reload. This preserves application state during development, enabling rapid style iteration and component refinement.

The HMR configuration in `vite.config.js` recognizes React Fast Refresh @ReactFastRefresh, which preserves component state across edits to component bodies while resetting state when props or hooks change.

"The Vite configuration enables hot module replacement for React components and processes SCSS through the standard build pipeline." #source_code_link("vite.config.js")

The `refresh: true` option enables Blade template detection, triggering full page reloads when server-side templates change rather than attempting to hot-replace server-rendered content.

===== SCSS Compilation Pipeline

SCSS styles compile through the Vite pipeline, with #source_code_link("resources/css/main.scss") serving as the entry point that imports all partials using `@use` directives. The modular SCSS structure mirrors the component hierarchy:

- Design tokens in `variables/` subdirectory (`_main-colors.scss`, `_layout.scss`, `_exception-colors.scss`, `_map-colors.scss`, `_css-vars.scss`)
- Component-specific partials in `components/` subdirectory (`_buttons.scss`, `_modal.scss`, `_restaurant-card.scss`, `_menu-item-card.scss`, etc.)
- Layout styles in `layouts/` subdirectory (`_customer.scss`, `_map.scss`)
- Page-specific overrides in `pages/` subdirectory

This organization enables styling changes to affect only relevant components. Modifying `components/_buttons.scss` triggers recompilation of the main stylesheet, which Vite then hot-swaps into the running application without re-rendering React components.

===== Separation of Components and Styling

React components reference semantic class names without coupling to specific style implementations. This separation allows independent iteration on visual design without touching component logic.

For example, changing button colors from blue to green requires only SCSS modifications. The component code remains unchanged, and TypeScript verification passes without recompiling JSX.

This separation also enables A/B testing of visual variants by swapping stylesheets without deploying new application code.

===== Production Code Splitting

The production build splits code based on route access patterns. Inertia page components define natural split points — customer pages bundle separately from employee pages.

The bundler analyzes the import graph and creates separate chunks for each Inertia page component. Since pages are resolved dynamically at navigation time, each page and its direct dependencies form an independent chunk that loads only when that route is visited. This ensures users download only code relevant to their current view.

===== Bundle Optimization Strategies

The production build applies several optimizations to minimize JavaScript payload:

- _Tree shaking_: Unused exports from imported modules are eliminated during bundling @ViteDocs
- _Minification_: JavaScript code is compressed, removing whitespace and shortening identifiers
- _Compression_: Vite generates pre-compressed gzip and Brotli variants for static assets
- _Asset hashing_: File names include content hashes enabling aggressive caching with cache invalidation on updates

These optimizations occur automatically during production builds (`npm run build`), requiring no manual configuration for typical use cases.
