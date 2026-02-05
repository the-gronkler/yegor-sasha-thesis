# Frontend Implementation - Topics to Cover

## TODO: Form Handling Pattern

**Location**: Should be added to Implementation chapter

**Content to cover**:

- Inertia's `useForm` hook usage for form state management
- TypeScript generics for type-safe form data
- Form validation error handling
- Examples from Auth pages (Login, Register)

**Reference files**:

- `resources/js/Pages/Auth/Register.tsx` - useForm example
- `resources/js/Pages/Auth/Login.tsx` - useForm example
- `docs/ts-guidelines.md` - TypeScript form typing guidelines

**Key pattern**:

```typescript
const form = useForm<FormDataType>({
  // initial values
});

// form.data, form.setData, form.post, etc.
```

This pattern provides type safety, automatic error handling, and integration with Laravel's validation system.

---

## TODO: Directory Structure Details

**Location**: Should be added to Implementation chapter (code-level details moved from System Architecture)

**Content to cover**:

- Specific directory paths and their contents:
  - `Pages/` organized by role: `Customer/`, `Employee/`, `Auth/`
  - `Layouts/`: `AppLayout`, `MapLayout`
  - `Components/UI/`: Button, Modal, Toggle, Toast, SearchInput, Lightbox
  - `Components/Shared/`: RestaurantCard, MenuItemCard, CartItem, OrderCard, StarRating, BottomNav, Map
  - `Hooks/`: useAuth, useMapPage, useSearch, useMenuItemUpdates, useRestaurantCart
  - `Contexts/`: CartContext, LoginModalContext
  - `Utils/`: Pure utility functions
  - `types/`: `models.ts` for database models, `index.d.ts` for PageProps

---

## TODO: Type System Implementation

**Location**: Should be added to Implementation chapter (section moved from System Architecture)

**Content to cover**:

- Centralized type definition strategy preventing type drift between components
- `types/models.ts` - database model types (User, Restaurant, MenuItem, Order) aligned with backend
- `types/index.d.ts` - global PageProps interface
- Page components extending PageProps with page-specific data requirements
- Custom hooks exporting typed return values for autocomplete and compile-time verification
- TypeScript strict mode configuration

---

## TODO: Client-Side Search Implementation

**Location**: Should be added to Implementation chapter (full section moved from System Architecture)

**Content to cover**:

- Client-side search using reusable `useSearch` hook wrapping Fuse.js fuzzy search library
- Hook accepts data array and configuration specifying searchable properties with relevance weights
- Returns filtered results ranked by match quality
- Provides immediate search feedback without server round-trips
- Constraint: search operates only on data already loaded to client
- `useMemo` usage for caching Fuse.js instance
- Preventing redundant instantiation on unrelated re-renders
- Fuse.js configuration options (threshold, ignoreLocation, etc.)
- Context-specific configurations:
  - Restaurant discovery: weights name/description higher than nested menu item names
  - Menu filtering: prioritizes item names over descriptions and categories

**Reference files**:

- `resources/js/Hooks/useSearch.ts`

---

## TODO: Accessibility Implementation

**Location**: Should be added to Implementation chapter (section moved from System Architecture)

**Content to cover**:

- Accessibility enforced at UI component layer for consistent patterns
- Preference for semantic HTML over generic containers with click handlers
- Buttons, navigation landmarks, sectioning elements communicating roles to assistive tech
- Specific ARIA label patterns: "Remove [item name] from cart", "Add to favorites"
- `aria-label` attribute usage on interactive elements
- Form label association via `htmlFor` attributes
- Validation error announcements
- Focus management with visible indicators on all interactive elements
- Keyboard-only navigation support

---

## TODO: Development Workflow Implementation

**Location**: Should be added to Implementation chapter (section moved from System Architecture)

**Content to cover**:

- Module boundaries enabling incremental updates during development
- Component hierarchy isolating changes: UI atom changes affect only consumers, page changes stay route-isolated
- Vite hot module replacement configuration
- SCSS compilation pipeline
- Separation between components and styling allowing independent iteration
- Production code splitting based on route access patterns
- Bundle optimization strategies

---

**Note**: Optimistic UI Updates are already covered in `implementation/optimistic-updates.typ`
