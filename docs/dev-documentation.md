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

The `MapController` supports optional geolocation-based filtering:

**Query Parameters:**

- `lat` - User's latitude (-90 to 90)
- `lng` - User's longitude (-180 to 180)
- `radius` - Search radius in kilometers (0.1 to 100, default: 50)

**Example Request:**

```
GET /map?lat=52.2297&lng=21.0122&radius=10
```

**Features:**

- Uses **Haversine formula** to calculate distances
- Returns restaurants within specified radius
- Sorts results by distance when geolocation is provided
- Falls back to rating-based sorting when no location is provided
- Includes `distance` field (in km) in restaurant data when filtered by location

**Controller Location:** `app/Http/Controllers/Customer/MapController.php`

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
