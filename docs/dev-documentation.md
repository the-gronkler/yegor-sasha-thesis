# Developer Documentation

## Intro

This file stores technical documentation useful during development. If a PR introduces something that needs to be 'kept in mind' during development, it should also update this file

## Related Documents

- [Frontend Project Structure](./fe-project-structure.md)
- [TypeScript Guidelines](./ts-guidelines.md)
- [CSS Documentation](./css-documentation.md)

## Geolocation & Map Features

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

### Restaurant Distance Display

The `RestaurantCard` component automatically displays distance information when available:

- Distance is shown in the restaurant meta section (e.g., "5.2 km")
- Only displayed when the `distance` property is present in restaurant data
- Properly formatted to 2 decimal places

## Console commands

Custom artisan commands, to use type:

```powershell
php artisan <command-name>
```

- `mfs`

  Alias for: `migrate:fresh --path=database/migrations/* --seed`. Wipes the DB, reruns all migrations in the specified folder and its subfolders, and then seeds the database.

- `ziggy:generate`

  Generates the `resources/js/ziggy.js` file. Run this whenever you add or modify named routes in `routes/web.php` to make them available in the frontend.

## Formatting

### Git Hooks (Automation)

We use **Husky** and **lint-staged** to automatically format files before they are committed.

- When you run `git commit`, only the **staged files** (the ones you added) will be formatted.
- If formatting changes are made, they are automatically added to the commit.
- This ensures that no unformatted code enters the repository.

- Theat means you dont need to run the commands below manually

### Frontend (JS/TS/CSS)

We use **Prettier** for code formatting. The configuration is located in [`.prettierrc`](../.prettierrc).

To format all frontend files, run:

```powershell
npm run format
```

### Backend (PHP)

We use **Laravel Pint** for PHP formatting. The configuration is located in [`pint.json`](../pint.json).

To format all PHP files, run:

```powershell
composer run format
```

Or the alias:

```powershell
npm run format:php
```

### Format Everything

To format both frontend and backend files in one go, run:

```powershell
npm run format:all
```
