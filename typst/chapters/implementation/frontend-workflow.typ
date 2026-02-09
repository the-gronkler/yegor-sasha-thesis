#import "../../config.typ": code_example, source_code_link

==== Development Workflow and Module Boundaries

The component architecture enables efficient development workflows through clear module boundaries and hot module replacement. These boundaries isolate changes and reduce iteration time during feature development.

===== Component Isolation and Change Impact

The layered component hierarchy limits the scope of changes. Modifications to UI atoms affect only their direct consumers, while page-level changes remain route-isolated without cascading to unrelated features.

For example, changing the `Button` component's styling requires rebuilding all pages that import it, but the TypeScript type system and bundler ensure only affected modules recompile. Modifying a specific customer page affects only that route's code chunk.

===== SCSS Compilation Pipeline

SCSS styles compile through Vite with #source_code_link("resources/css/main.scss") as the entry point. The modular structure organizes styles into `variables/`, `components/`, `layouts/`, and `pages/` subdirectories, mirroring the component hierarchy. Style changes hot-swap into the running application without re-rendering React components.

===== Separation of Components and Styling

React components reference semantic class names without coupling to specific style implementations. This separation allows independent iteration on visual design: changing button colors requires only SCSS modifications, not component code changes.

===== Production Code Splitting

The production build splits code by route: Inertia page components define natural split points where customer and employee pages bundle separately. Each route loads only its required chunk when visited.
