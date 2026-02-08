#import "../../config.typ": code_example, source_code_link

==== Directory Structure and Organization

The component hierarchy described in @frontend-architecture is realized as a structured directory layout under #source_code_link("resources/js"). This section maps each architectural layer to its physical location in the codebase.

*Pages* (#source_code_link("resources/js/Pages")) are organized by user role (`Customer/`, `Employee/`, `Auth/`), mirroring the backend route structure. Each page component corresponds to an Inertia route; for example, #source_code_link("resources/js/Pages/Customer/Restaurants/Show.tsx") maps to `route('restaurants.show')`.

*Layouts* (#source_code_link("resources/js/Layouts")) provide structural wrappers that persist across navigation, including `AppLayout` (standard header and footer) and `MapLayout` (full-screen map view with disabled body scrolling).

*Components* split into two subdirectories: #source_code_link("resources/js/Components/UI") for generic atomic elements (`Button`, `Modal`, `Toggle`, `SearchInput`) without domain knowledge, and #source_code_link("resources/js/Components/Shared") for domain-aware molecules (`RestaurantCard`, `MenuItemCard`, `CartItem`, `StarRating`, `Map`) that accept typed domain models.

*Hooks* (#source_code_link("resources/js/Hooks")) encapsulate reusable stateful logic: authentication (`useAuth`), map orchestration (`useMapPage`), fuzzy search (`useSearch`), per-restaurant cart management (`useRestaurantCart`), and real-time update subscriptions in a dedicated `Updates/` subdirectory.

*Contexts* (#source_code_link("resources/js/Contexts")) define React Context providers (`CartContext`, `LoginModalContext`). *Types* (#source_code_link("resources/js/types")) centralize TypeScript definitions, and *Utils* (#source_code_link("resources/js/Utils")) contain pure utility functions.

===== Convention in Practice

#code_example[
  A typical page component in #source_code_link("resources/js/Pages/Customer/Restaurants/Show.tsx") illustrates the import conventions, drawing from layouts, shared components, typed models, and hooks.

  ```typescript
  import AppLayout from '@/Layouts/AppLayout';
  import StarRating from '@/Components/Shared/StarRating';
  import { Restaurant } from '@/types/models';
  import { useRestaurantCart } from '@/Hooks/useRestaurantCart';

  interface RestaurantShowProps extends PageProps {
    restaurant: Restaurant;
    isFavorited: boolean;
  }

  export default function RestaurantShow({ restaurant, isFavorited }: RestaurantShowProps) {
    // Page composes shared components with server-provided data
  }
  ```
]

This structure enables predictable file discovery: a developer implementing a customer-facing feature navigates to `Pages/Customer/`, locates shared components under `Components/Shared/`, and extracts complex logic into hooks under `Hooks/`.
