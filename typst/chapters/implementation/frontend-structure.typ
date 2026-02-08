#import "../../config.typ": code_example, source_code_link

==== Directory Structure and Organization

The component hierarchy described in @frontend-architecture is realized as a structured directory layout under #source_code_link("resources/js"). This section maps each architectural layer to its physical location in the codebase and demonstrates the conventions that govern file placement.

*Pages Directory* (#source_code_link("resources/js/Pages")) organizes views by user role, mirroring the backend route structure. The directory contains three primary subdivisions:

- `Customer/`: Customer-facing pages including restaurant discovery, menu browsing, cart management, and order tracking
- `Employee/`: Restaurant employee interfaces for order management, menu editing, and establishment settings
- `Auth/`: Authentication flows including login, registration, and password reset

Each page component corresponds to an Inertia route defined in Laravel's web routes file. For example, #source_code_link("resources/js/Pages/Customer/Restaurants/Show.tsx") corresponds to the route `route('restaurants.show')`.

*Layouts Directory* (#source_code_link("resources/js/Layouts")) provides structural wrappers that persist across navigation. The application defines specialized layouts for different contexts:

- `AppLayout`: Default layout with navigation header and footer for standard pages
- `MapLayout`: Full-screen layout for map-based restaurant discovery, disabling body scrolling to prevent conflicts with map pan interactions

*Components Directory* splits into two subdirectories based on specificity:

- #source_code_link("resources/js/Components/UI"): Generic atomic elements without domain knowledge (`Button`, `Modal`, `Toggle`, `Toast`, `SearchInput`, `Lightbox`). These components accept standard HTML attributes and provide consistent styling without business logic.
- #source_code_link("resources/js/Components/Shared"): Domain-aware molecules combining UI atoms with business presentation logic (`RestaurantCard`, `MenuItemCard`, `CartItem`, `OrderCard`, `StarRating`, `BottomNav`, `Map`). These components accept typed domain models and format data for display.

*Hooks Directory* (#source_code_link("resources/js/Hooks")) encapsulates reusable stateful logic:

- Authentication utilities (`useAuth`)
- Map page orchestration (`useMapPage`)
- Configurable fuzzy search (`useSearch`)
- Real-time update subscriptions (`useMenuItemUpdates`, `useRestaurantCart`)

*Contexts Directory* (#source_code_link("resources/js/Contexts")) defines React Context providers for global state:

- `CartContext`: Shopping cart state and mutation functions
- `LoginModalContext`: Authentication modal visibility and callbacks

*Types Directory* (#source_code_link("resources/js/types")) centralizes TypeScript definitions, with `models.ts` containing database model interfaces and `index.d.ts` providing global type definitions including the `PageProps` interface.

*Utils Directory* (#source_code_link("resources/js/Utils")) contains pure utility functions for data transformation and formatting.

===== Convention in Practice

#code_example[
  The following excerpt from #source_code_link("resources/js/Pages/Customer/Restaurants/Show.tsx") illustrates how a typical page component composes elements from each layer — importing shared components, consuming a context hook, and receiving typed props from the server.

  ```typescript
  import AppLayout from '@/Layouts/AppLayout';
  import MenuItemCard from '@/Components/Shared/MenuItemCard';
  import StarRating from '@/Components/Shared/StarRating';
  import { useCart } from '@/Contexts/CartContext';
  import { Restaurant, MenuItem } from '@/types/models';

  interface ShowPageProps extends PageProps {
    restaurant: Restaurant;
    menuItems: MenuItem[];
  }

  export default function Show({ restaurant, menuItems }: ShowPageProps) {
    const { addItem } = useCart();
    // Page composes shared components with server-provided data
  }
  ```
]

This structure enables predictable file discovery: a developer implementing a feature for the customer restaurant detail page navigates to `Pages/Customer/Restaurants/`, expects shared components under `Components/Shared/`, and extracts complex logic into a hook under `Hooks/`.
