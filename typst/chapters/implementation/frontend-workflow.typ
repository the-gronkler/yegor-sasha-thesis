#import "../../config.typ": code_example, source_code_link

==== Development Workflow and Module Boundaries

The component architecture enables efficient development workflows through clear module boundaries and hot module replacement. These boundaries isolate changes and reduce iteration time during feature development.

===== Component Isolation and Change Impact

The layered component hierarchy limits the scope of changes. Modifications to UI atoms affect only their direct consumers, while page-level changes remain route-isolated without cascading to unrelated features.

For example, changing the `Button` component's styling requires rebuilding all pages that import it, but the TypeScript type system and bundler ensure only affected modules recompile. Modifying a specific customer page affects only that route's code chunk.

===== Vite Hot Module Replacement

The Vite development server provides hot module replacement (HMR) that updates changed modules in the running application without full page reload. This preserves application state during development, enabling rapid style iteration and component refinement.

The HMR configuration in `vite.config.ts` recognizes React Fast Refresh, which preserves component state across edits to component bodies while resetting state when props or hooks change.

#code_example[
  Vite configuration enables React Fast Refresh for development builds.

  ```typescript
  export default defineConfig({
    plugins: [
      react(),
      laravel({
        input: ['resources/js/app.tsx', 'resources/css/main.scss'],
        refresh: true,
      }),
    ],
  });
  ```
]

The `refresh: true` option enables Blade template detection, triggering full page reloads when server-side templates change rather than attempting to hot-replace server-rendered content.

===== SCSS Compilation Pipeline

SCSS styles compile through the Vite pipeline, enabling imports of SCSS partials into the main stylesheet. The modular SCSS structure mirrors the component hierarchy:

- Design tokens (`_variables.scss`, `_colors.scss`, `_typography.scss`)
- Component-specific partials (`_button.scss`, `_modal.scss`)
- Layout styles (`_grid.scss`, `_spacing.scss`)
- Page-specific overrides

This organization enables styling changes to affect only relevant components. Modifying `_button.scss` triggers recompilation of the main stylesheet, which Vite then hot-swaps into the running application without re-rendering React components.

===== Separation of Components and Styling

React components reference semantic class names without coupling to specific style implementations. This separation allows independent iteration on visual design without touching component logic.

For example, changing button colors from blue to green requires only SCSS modifications. The component code remains unchanged, and TypeScript verification passes without recompiling JSX.

This separation also enables A/B testing of visual variants by swapping stylesheets without deploying new application code.

===== Production Code Splitting

The production build splits code based on route access patterns. Inertia page components define natural split points - customer pages bundle separately from employee pages, ensuring users download only code relevant to their role.

The bundler analyzes dynamic imports and creates separate chunks for lazily loaded components. For example, the image lightbox component (used only when users click images) loads on-demand rather than blocking initial page load.

#code_example[
  Lazy loading defers component download until needed.

  ```typescript
  const Lightbox = React.lazy(() => import('@/Components/UI/Lightbox'));

  function RestaurantGallery({ images }: Props) {
    const [isOpen, setIsOpen] = useState(false);

    return (
      <>
        <button onClick={() => setIsOpen(true)}>View Gallery</button>
        {isOpen && (
          <React.Suspense fallback={<div>Loading...</div>}>
            <Lightbox images={images} onClose={() => setIsOpen(false)} />
          </React.Suspense>
        )}
      </>
    );
  }
  ```
]

This pattern reduces initial bundle size, improving perceived performance on slow connections.

===== Bundle Optimization Strategies

The production build applies several optimizations to minimize JavaScript payload:

- _Tree shaking_: Unused exports from imported modules are eliminated during bundling
- _Minification_: JavaScript code is compressed, removing whitespace and shortening identifiers
- _Compression_: Vite generates pre-compressed gzip and Brotli variants for static assets
- _Asset hashing_: File names include content hashes enabling aggressive caching with cache invalidation on updates

These optimizations occur automatically during production builds (`npm run build`), requiring no manual configuration for typical use cases.
