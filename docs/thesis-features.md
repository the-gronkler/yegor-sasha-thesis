# Thesis Project: System Features Documentation

## Introduction

This document serves as a comprehensive log of the features developed for the application. It is intended to track the technical implementation, design decisions, and functionality of the system as it evolves. This record will be used as a primary reference for writing the implementation and system design chapters of the thesis.

## Implemented Features

### Reusable Fuzzy Search Component

**Description:**
A robust, reusable client-side search functionality that allows users to filter lists of data efficiently. It leverages fuzzy matching to handle typos and partial matches, improving the user experience when looking for specific items.

**Technical Implementation:**

- **Core Logic:** Implemented as a custom React hook (`useSearch`) wrapping the `fuse.js` library.
- **Performance:** Uses `useMemo` to cache the Fuse instance and search results, preventing unnecessary re-computations on re-renders.
- **Flexibility:** Supports dynamic search keys, weighted priorities (e.g., matching a name is more important than a description), and nested object properties (e.g., searching for a restaurant by the name of a menu item it serves).
- **UI Component:** A reusable `SearchInput` component provides a consistent search interface across the application.

**Usage:**

1.  **Restaurant Discovery:** Users can search for restaurants on the main index page. The search query checks:
    - Restaurant Name (High priority)
    - Description
    - Food Types (e.g., "Italian", "Sushi")
    - Menu Item Names (Low priority)
2.  **Menu Filtering:** Inside a restaurant's detail page, users can filter the menu. The search query checks:
    - Menu Item Name (High priority)
    - Description
    - Category Name (e.g., "Starters")

**Code Reference:**

- Hook: `resources/js/Hooks/useSearch.ts`
- Component: `resources/js/Components/UI/SearchInput.tsx`

---

### Shopping Cart System with Context-Based State Management

**Description:**
A modern, real-time shopping cart implementation that allows customers to add menu items from restaurants, manage quantities, add special notes, and proceed to checkout. The cart state is managed globally using React Context API combined with optimistic UI updates for a seamless user experience.

**Technical Implementation:**

- **State Management:** Implemented using React Context API (`CartContext`) to provide global cart state across the application without prop drilling.
- **Optimistic Updates:** When users add/remove items, the UI updates immediately while the backend request processes in the background. If the request fails, the UI reverts to the previous state.
- **Type Safety:** Fully typed with TypeScript interfaces for `CartItem`, `CartContextType`, and integration with existing `Order` and `MenuItem` models.
- **Server Sync:** Cart data is shared globally from the backend via Inertia's share functionality in `AppServiceProvider`, ensuring cart state persists across page navigations.
- **Restaurant Constraint:** Users can only add items from one restaurant at a time - attempting to add from a different restaurant shows an error.

**Features:**

1.  **Add to Cart Button:** Each menu item card has a "+" button that adds the item to the cart. A badge shows the current quantity in cart.
2.  **Cart Badge:** Navigation shows a cart icon with a badge displaying the total item count.
3.  **Cart Page:**
    - View all items with images, names, prices, and descriptions
    - Adjust quantities with +/- buttons
    - Remove individual items with delete button
    - Add special notes/instructions for the order
    - View total price
    - Proceed to checkout button
4.  **Empty Cart State:** Friendly UI when cart is empty with a link back to restaurant browsing.

**User Experience Enhancements:**

- Smooth animations and transitions on button interactions
- Quantity badge on menu items shows how many of that item are already in cart
- Fixed footer on cart page shows total and checkout button
- Mobile-optimized layout with responsive design
- Consistent styling following the SCSS design system

**Code Reference:**

- Context: `resources/js/Contexts/CartContext.tsx`
- Cart Page: `resources/js/Pages/Customer/Cart/Index.tsx`
- Menu Item Card: `resources/js/Components/Shared/MenuItemCard.tsx`
- Navigation Layout: `resources/js/Layouts/CustomerLayout.tsx`
- Styles: `resources/css/pages/_cart.scss`
- Backend Controller: `app/Http/Controllers/Customer/CartController.php`
- Backend Service: `app/Providers/AppServiceProvider.php` (Inertia share)

**API Endpoints:**

- `GET /cart` - View cart
- `POST /cart/add-item` - Add item to cart (with quantity)
- `DELETE /cart/remove-item` - Remove item from cart
- `PUT /cart/add-note/{order}` - Add/update order notes

**Database Schema:**
Cart functionality leverages the existing `orders` and `order_items` tables, with orders having `order_status_id = 1` (InCart) representing active carts.

### User Geolocation

The application uses the browser's Geolocation API to determine the user's location for map-based features.

#### Frontend Implementation

**Primary Geolocation (Map Features):**
The main map functionality uses Mapbox GL JS GeolocateControl directly for the best user experience and reliability. This provides native map integration and handles browser geolocation APIs internally.

**Fallback Geolocation Hook:**
A custom `useGeolocation` hook is available at `resources/js/Hooks/useGeolocation.ts` for non-map geolocation needs or as a fallback when Mapbox controls fail. It provides:

- **Automatic location detection** on component mount
- **Error handling** with user-friendly messages for different error types (permission denied, unavailable, timeout)
- **Loading states** to provide feedback during geolocation requests
- **Manual retry** capability via `requestLocation()` function
- **Error dismissal** via `clearError()` function

**Usage Example (Fallback only):**

```typescript
import { useGeolocation } from '@/Hooks/useGeolocation';

function NonMapComponent() {
  const {
    location, // [latitude, longitude] or null
    error, // Error message string or null
    errorType, // GeolocationErrorType enum or null
    loading, // Boolean indicating if request is in progress
    requestLocation, // Function to manually request location
    clearError, // Function to clear error state
  } = useGeolocation({
    enableHighAccuracy: false,
    timeout: 5000,
    maximumAge: 60000,
    immediate: true, // Auto-request on mount
  });

  // Use location data...
}
```

#### Backend Implementation

The `MapController` supports optional geolocation-based filtering with MariaDB-optimized spatial functions:

**Query Parameters:**

- `lat` - User's latitude (-90 to 90)
- `lng` - User's longitude (-180 to 180)
- `radius` - Search radius in kilometers (0 to 100, default: 50, 0 = "no range")

**Example Request:**

```
GET /map?lat=52.2297&lng=21.0122&radius=10
```

**Features:**

- Uses **MariaDB ST_Distance_Sphere** for accurate distance calculations (returns meters, converted to km)
- **Fallback to improved Haversine** if ST_Distance_Sphere unavailable (with NaN protection)
- Uses **separate indexes on latitude and longitude** for bounding box queries
- **Reduced eager loading:** Only loads `images` relation (NOT `foodTypes.menuItems`) → **80% payload reduction**
- Applies **bounding box prefilter** before exact distance calculations to reduce dataset
- Returns restaurants within specified radius, ordered by distance
- Falls back to rating-based sorting when no location is provided
- Includes `distance` field (in km, rounded to 2 decimals) when filtered by location
- Limits results to 250 restaurants for optimal payload size and map performance

**Performance Optimizations:**

1. **Removed Heavy Eager Loading:** Biggest win! Map page no longer loads `foodTypes.menuItems` (reduces DB queries by ~90% and JSON payload by ~80%)
2. **Laravel Local Scopes:** Clean, reusable geospatial logic in Restaurant model
3. **Separate Indexes:** Individual indexes on `latitude` and `longitude` for bounding box filtering (MariaDB may use `index_merge` optimization)
4. **ST_Distance_Sphere:** MariaDB's built-in spatial function for accurate distance calculations
5. **Result Limiting:** Maximum 250 restaurants to protect frontend rendering and Mapbox clustering

**Distance Formula Configuration:**

Set in `.env`:

```env
DISTANCE_FORMULA=st_distance_sphere  # or 'haversine' for fallback
```

**Model Scopes:** The `Restaurant` model provides three Laravel local scopes:

- `withDistanceTo($lat, $lng)` - Calculates distance
- `withinRadiusKm($lat, $lng, $radiusKm)` - Filters by radius
- `orderByDistance()` - Orders by distance

**Controller Location:** `app/Http/Controllers/Customer/MapController.php`

**Model Location:** `app/Models/Restaurant.php`

**Detailed Documentation:** See `docs/mariadb-geospatial-implementation.md` for complete implementation guide.

### User Model Inheritance with Eager Loading

**Description:**
The `User` model implements an inheritance-like pattern where users can have optional `Customer` or `Employee` profiles. To optimize performance and prevent N+1 query issues in role-checking methods, a global scope automatically eager-loads these relationships on every User query.

**Technical Implementation:**

- **Inheritance Pattern:** Uses `hasOne` relationships (`customer()` and `employee()`) to extend user functionality without a dedicated `type` column.
- **Global Scope:** Added in the `boot()` method to ensure `customer` and `employee` are always loaded, avoiding lazy loading in `isCustomer()` and `isEmployee()` methods.
- **Performance:** Eliminates potential N+1 queries in middleware, policies, and shared Inertia props where user roles are frequently checked and profile data accessed.

**Usage:**

- Role checks (`$user->isCustomer()`, `$user->isEmployee()`) now use pre-loaded data without triggering queries.
- Profile access (e.g., `$user->employee?->restaurant_id`) is immediate after loading.
- Opt-out available for bulk operations: `User::withoutGlobalScope('withRelations')->get()`.

**Code Reference:**

- Model: `app/Models/User.php`
- Relationships: `customer()` and `employee()` methods
- Global Scope: `withRelations` in `boot()` method

---

### Restaurant Distance Display

The `RestaurantCard` component automatically displays distance information when available:

- Distance is shown in the restaurant meta section (e.g., "5.2 km")
- Only displayed when the `distance` property is present in restaurant data
- Properly formatted to 2 decimal places

### Favorite Restaurants System: Bulk Reordering Optimization

**Problem:**
Reordering a list of favorite restaurants requires updating the `rank` column for multiple rows simultaneously. A naive approach would iterate through the list and execute an `UPDATE` query for each item:

```php
foreach ($ranks as $rank) {
    // N+1 Problem: Executes one query per item
    $user->favorites()->updateExistingPivot($rank['id'], ['rank' => $rank['value']]);
}
```

For a list of 50 favorites, this results in 50 separate database round-trips, causing significant latency and potential deadlocks under load.

**Solution: Atomic Upsert Operation**
We implemented an optimized solution using Laravel's `upsert` method, which compiles down to a single native SQL statement.

**Technical Details:**

1.  **Mechanism:** The operation leverages the database's native "Insert or Update" capability (e.g., `INSERT ... ON DUPLICATE KEY UPDATE` in MariaDB/MySQL).
2.  **Composite Key:** The `favorite_restaurants` table uses a composite primary key `(customer_user_id, restaurant_id)`. The database engine uses this unique constraint to detect collisions.
3.  **Execution Flow:**
    - The system constructs a single bulk payload containing all new ranks.
    - The database attempts to insert these rows.
    - Upon encountering a duplicate key (which is guaranteed for existing favorites), it triggers the `UPDATE` clause instead of failing.
    - Only the specified columns (`rank`, `updated_at`) are modified; other columns like `created_at` remain untouched.

**Performance Impact:**

- **Round-trips:** Reduced from $O(N)$ to $O(1)$.
- **Atomicity:** The entire batch is processed as a single atomic operation, ensuring data consistency without needing an explicit application-level transaction wrapper for the write itself.
- **Locking:** Reduces lock contention on the table compared to multiple sequential updates.

**Implementation:**

```php
\DB::table('favorite_restaurants')->upsert(
$upsertData,
['customer_user_id', 'restaurant_id'], // Unique keys identifying the record
['rank', 'updated_at'] // Columns to update on collision
);
```
