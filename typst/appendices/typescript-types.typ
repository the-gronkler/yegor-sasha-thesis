#import "../config.typ": code_example, source_code_link

= Appendix A: TypeScript Type Definitions

This appendix provides reference documentation for the core TypeScript interfaces used throughout the frontend implementation. These type definitions ensure compile-time verification of data flow between the Laravel backend and React frontend.

== Model Interfaces

Model interfaces define exact property names and types matching database columns and Eloquent relationships.

=== MenuItem Interface

```typescript
export interface MenuItem {
  id: number;
  restaurant_id: number;
  food_type_id: number;
  name: string;
  price: number;
  description: string | null;
  is_available: boolean;
  image_id: number | null;
  image?: Image;
  allergens?: Allergen[];
  pivot?: { quantity: number };
  created_at: string;
  updated_at: string;
}
```

=== Restaurant Interface

```typescript
export interface Restaurant {
  id: number;
  name: string;
  address: string;
  latitude: number | null;
  longitude: number | null;
  description: string | null;
  rating: number | null;
  opening_hours: string | null;
  distance?: number | null;
  is_favorited?: boolean;
  images?: Image[];
  food_types?: FoodType[];
  created_at: string;
  updated_at: string;
}
```

== State Enumerations

=== OrderStatusEnum

The `OrderStatusEnum` maps database integer status codes to named constants for type-safe status handling.

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

== Generic Types

=== PaginatedResponse Interface

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

This interface is used throughout the application for endpoints that return paginated data: `PaginatedResponse<Restaurant>`, `PaginatedResponse<Order>`, etc.
