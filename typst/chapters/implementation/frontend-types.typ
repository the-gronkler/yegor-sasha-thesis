#import "../../config.typ": code_example, source_code_link

==== Type System Implementation

The type system provides compile-time verification of data flow between backend and frontend, preventing type drift that could lead to runtime errors. The implementation centralizes type definitions and enforces strict typing throughout the component tree.

===== Centralized Model Definitions

The file #source_code_link("resources/js/types/models.ts") defines interfaces for all domain entities, mirroring the structure of Laravel Eloquent models. This alignment ensures that data serialized by Laravel controllers matches the shape expected by TypeScript components.

#code_example[
  Model interfaces define exact property names and types matching database columns and Eloquent relationships.

  ```typescript
  export interface Restaurant {
    id: number;
    name: string;
    address: string;
    latitude: number | null;
    longitude: number | null;
    rating: number | null;
    images?: Image[];
    food_types?: FoodType[];
  }
  ```
]

Similar interfaces define `MenuItem`, `Order`, `Review`, and related models. #source_code_link("resources/js/types/models.ts")

===== Enumerations for Finite States

Discrete state values use TypeScript numeric enums matching database integer columns. This provides both type safety and semantic clarity.

TypeScript numeric enums encode finite-state values like dictionary entity models (`OrderStatusEnum`) matching database integer columns, ensuring compile-time exhaustiveness checks. Components use enum members instead of magic numbers, making status checks explicit and preventing invalid values. #source_code_link("resources/js/types/models.ts")

===== Generic Pagination Interface

Laravel pagination responses follow a consistent structure. Rather than duplicating this shape across multiple interfaces, a generic type captures the pattern once.

A generic `PaginatedResponse<T>` interface wraps Laravel's standard pagination response shape, providing type-safe access to paginated data across all list views. Pages receiving paginated data declare their props as `PaginatedResponse<Restaurant>` or `PaginatedResponse<Order>`, automatically receiving correct types for all pagination properties. #source_code_link("resources/js/types/models.ts")

===== Global PageProps Interface

All Inertia pages receive shared props (authentication state, flash messages, errors) in addition to page-specific data. The global `PageProps` interface defined in #source_code_link("resources/js/types/index.d.ts") establishes this contract, mirroring the shared data structure returned by the `HandleInertiaRequests` middleware on the backend (described in @backend-architecture).

#code_example[
  `PageProps` defines the baseline properties available to every page component using a generic type alias with intersection types.

  ```typescript
  export type PageProps<
    T extends Record<string, unknown> = Record<string, unknown>,
  > = T & {
    auth: {
      user: User;
      restaurant_id?: number | null;
      isRestaurantAdmin?: boolean;
    };
    errors: Record<string, string>;
    flash: {
      success?: string;
      error?: string;
    };
    ziggy: Config & { location: string };
  };
  ```
]

This type replicates the exact structure defined in the middleware's `share()` method, ensuring type safety when accessing shared props across all pages. The generic parameter `T` allows page-specific data to be intersected with the shared props, providing a single unified type. The `auth` object provides authentication context populated from the session, `flash` contains success and error messages from redirects, `errors` holds validation failures, and `ziggy` supplies routing configuration for client-side route generation.

Page components extend this type with their specific data requirements using the generic parameter or TypeScript intersection types. The `auth.user` property is always present for authenticated pages, with additional restaurant context for employee users.

#code_example[
  Page-specific props extend `PageProps` to include additional data.

  ```typescript
  interface SpecificPageProps extends PageProps {
    // ... page specific props
  }

  export default function SpecificPage({
    // ... page specific props
  }: SpecificPageProps) {
    // Component implementation with fully typed props
  }
  ```
]

This pattern ensures pages have access to both shared authentication state and their specific data, with full autocomplete and type checking in both cases.

===== Strict Type Configuration

The TypeScript compiler configuration enforces strict mode, catching potential null reference errors and implicit any types at compile time. This configuration is defined in `tsconfig.json`:

- `strict: true`: Enables all strict type checking options, which implicitly activates `noImplicitAny`, `strictNullChecks`, `strictFunctionTypes`, and `strictPropertyInitialization`
- `noUnusedLocals: true`: Flags unused local variables as errors
- `noUnusedParameters: true`: Flags unused function parameters as errors
- `noFallthroughCasesInSwitch: true`: Prevents unintentional fallthrough in switch statements
- `forceConsistentCasingInFileNames: true`: Enforces consistent file name casing across imports

These settings transform TypeScript from a permissive type annotation system into a rigorous verification tool that catches errors before runtime.
