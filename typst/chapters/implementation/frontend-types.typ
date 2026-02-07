#import "../../config.typ": code_example, source_code_link

==== Type System Implementation

The type system provides compile-time verification of data flow between backend and frontend, preventing type drift that could lead to runtime errors. The implementation centralizes type definitions and enforces strict typing throughout the component tree.

===== Centralized Model Definitions

The file #source_code_link("resources/js/types/models.ts") defines interfaces for all domain entities, mirroring the structure of Laravel Eloquent models. This alignment ensures that data serialized by Laravel controllers matches the shape expected by TypeScript components.

#code_example[
  Model interfaces define exact property names and types matching database columns and Eloquent relationships.

  ```typescript
  export interface MenuItem {
    id: number;
    restaurant_id: number;
    name: string;
    description?: string | null;
    price: number;
    is_available: boolean;
    food_type_id: number;
    image?: Image;
    allergens?: Allergen[];
    created_at: string;
    updated_at: string;
  }

  export interface Restaurant {
    id: number;
    name: string;
    address: string;
    latitude?: number | null;
    longitude?: number | null;
    rating?: number | null;
    description?: string | null;
    opening_hours?: string | null;
    images?: Image[];
    food_types?: FoodType[];
  }
  ```
]

Optional properties use TypeScript's `?` syntax combined with explicit `| null` union types for fields that may be absent or explicitly null. This distinction matters for type guards and conditional rendering logic. Relationship properties like `images` and `food_types` are optional because these relations may not be eager-loaded depending on the endpoint.

===== Enumerations for Finite States

Discrete state values use TypeScript numeric enums matching database integer columns. This provides both type safety and semantic clarity.

#code_example[
  The `OrderStatusEnum` maps database integer status codes to named constants.

  ```typescript
  export enum OrderStatusEnum {
    InCart = 1,
    Placed = 2,
    Accepted = 3,
    Declined = 4,
    Preparing = 5,
    Ready = 6,
    Cancelled = 7,
    Fulfilled = 8,
  }
  ```
]

Components use enum members instead of magic numbers, making status checks explicit and preventing invalid values. For example, `order.order_status_id === OrderStatusEnum.Ready` is more maintainable than `order.order_status_id === 6`.

===== Generic Pagination Interface

Laravel pagination responses follow a consistent structure. Rather than duplicating this shape across multiple interfaces, a generic type captures the pattern once.

#code_example[
  The `PaginatedResponse` interface wraps any model type with Laravel pagination metadata.

  ```typescript
  export interface PaginatedResponse<T> {
    data: T[];
    current_page: number;
    first_page_url: string;
    from: number;
    last_page: number;
    last_page_url: string;
    links: { url: string | null; label: string; active: boolean }[];
    next_page_url: string | null;
    path: string;
    per_page: number;
    prev_page_url: string | null;
    to: number;
    total: number;
  }
  ```
]

Pages receiving paginated data declare their props as `PaginatedResponse<Restaurant>` or `PaginatedResponse<Order>`, automatically receiving correct types for all pagination properties including the navigation links array and page URLs.

===== Global PageProps Interface

All Inertia pages receive shared props (authentication state, flash messages, errors) in addition to page-specific data. The global `PageProps` interface defined in #source_code_link("resources/js/types/index.d.ts") establishes this contract, mirroring the shared data structure returned by the `HandleInertiaRequests` middleware on the backend (described in @backend-architecture).

#code_example[
  `PageProps` defines the baseline properties available to every page component.

  ```typescript
  export interface PageProps {
    auth: {
      user: User;
      restaurant_id?: number | null;
      isRestaurantAdmin?: boolean;
    };
    flash: {
      success?: string;
      error?: string;
    };
    errors: Record<string, string>;
    ziggy: Config & { location: string };
  }
  ```
]

This interface replicates the exact structure defined in the middleware's `share()` method, ensuring type safety when accessing shared props across all pages. The `auth` object provides authentication context populated from the session, `flash` contains success and error messages from redirects, `errors` holds validation failures, and `ziggy` supplies routing configuration for client-side route generation.

Page components extend this interface with their specific data requirements using TypeScript intersection types. The `auth.user` property is always present for authenticated pages, with additional restaurant context for employee users.

#code_example[
  Page-specific props extend `PageProps` to include additional data.

  ```typescript
  interface ShowPageProps extends PageProps {
    restaurant: Restaurant;
    menuItems: MenuItem[];
    reviews: PaginatedResponse<Review>;
  }

  export default function Show({
    restaurant,
    menuItems,
    reviews
  }: ShowPageProps) {
    // Component implementation with fully typed props
  }
  ```
]

This pattern ensures pages have access to both shared authentication state and their specific data, with full autocomplete and type checking in both cases.

===== Custom Hook Type Exports

Reusable hooks export typed return values to propagate type information to consuming components. This enables autocomplete and compile-time verification without requiring consumers to redeclare types.

#code_example[
  The `useSearch` hook exports its return type explicitly.

  ```typescript
  export function useSearch<T>(
    items: T[],
    searchKeys: Array<keyof T>,
    options?: Partial<IFuseOptions<T>>
  ): {
    query: string;
    setQuery: (query: string) => void;
    filteredItems: T[];
  } {
    // Hook implementation
  }
  ```
]

Consuming components destructure the return value with full type inference: `const { query, setQuery, filteredItems } = useSearch(restaurants, ['name', 'description'])` knows `filteredItems` is `Restaurant[]` without explicit annotation.

===== Strict Type Configuration

The TypeScript compiler configuration enforces strict mode, catching potential null reference errors and implicit any types at compile time. This configuration is defined in `tsconfig.json`:

- `strict: true`: Enables all strict type checking options
- `noImplicitAny: true`: Prevents accidental use of `any` type
- `strictNullChecks: true`: Requires explicit handling of null and undefined
- `strictFunctionTypes: true`: Enforces strict checking of function parameters
- `strictPropertyInitialization: true`: Ensures class properties are initialized

These settings transform TypeScript from a permissive type annotation system into a rigorous verification tool that catches errors before runtime.
