#import "../../config.typ": code_example, source_code_link

==== Directory Structure and Organization

The component hierarchy defined in the architecture manifests as a structured directory layout under `resources/js/`. This organization enables developers to locate components through URL patterns and maintains clear separation between abstraction levels.

_Pages Directory_ (`resources/js/Pages/`) organizes views by user role, mirroring the backend route structure. The directory contains three primary subdivisions:

- `Customer/`: Customer-facing pages including restaurant discovery, menu browsing, cart management, and order tracking
- `Employee/`: Restaurant employee interfaces for order management, menu editing, and establishment settings
- `Auth/`: Authentication flows including login, registration, and password reset

Each page component corresponds to an Inertia route defined in Laravel's web routes file. For example, `Pages/Customer/Restaurants/Show.tsx` corresponds to the route `route('restaurants.show')`.

_Layouts Directory_ (`resources/js/Layouts/`) provides structural wrappers that persist across navigation. The application defines specialized layouts for different contexts:

- `AppLayout`: Default layout with navigation header and footer for standard pages
- `MapLayout`: Full-screen layout for map-based restaurant discovery, disabling body scrolling to prevent conflicts with map pan interactions

_Components Directory_ splits into two subdirectories based on specificity:

- `Components/UI/`: Generic atomic elements without domain knowledge (`Button`, `Modal`, `Toggle`, `Toast`, `SearchInput`, `Lightbox`). These components accept standard HTML attributes and provide consistent styling without business logic.
- `Components/Shared/`: Domain-aware molecules combining UI atoms with business presentation logic (`RestaurantCard`, `MenuItemCard`, `CartItem`, `OrderCard`, `StarRating`, `BottomNav`, `Map`). These components accept typed domain models and format data for display.

_Hooks Directory_ (`resources/js/Hooks/`) encapsulates reusable stateful logic. The directory contains:

- Authentication utilities (`useAuth`)
- Map page orchestration (`useMapPage`)
- Configurable fuzzy search (`useSearch`)
- Real-time update subscriptions (`useMenuItemUpdates`, `useRestaurantCart`)

_Contexts Directory_ (`resources/js/Contexts/`) defines React Context providers for global state:

- `CartContext`: Shopping cart state and mutation functions
- `LoginModalContext`: Authentication modal visibility and callbacks

_Utils Directory_ (`resources/js/Utils/`) contains pure utility functions for data transformation and formatting.

_Types Directory_ (`resources/js/types/`) centralizes TypeScript definitions:

- `models.ts`: Database model interfaces aligned with Laravel Eloquent models
- `index.d.ts`: Global type definitions including `PageProps` interface

This structure enables predictable file locations. A developer implementing a feature for the customer restaurant detail page knows to look in `Pages/Customer/Restaurants/Show.tsx`, expect that page to use components from `Components/Shared/RestaurantCard.tsx` and `Components/UI/Button.tsx`, and potentially extract complex logic into a hook under `Hooks/`.
