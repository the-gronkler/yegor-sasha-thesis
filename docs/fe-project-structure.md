The best way to structure an Inertia app is to mirror the Backend structure for **Pages**, while keeping reusable UI elements in **Components**.

### 1. Recommended Directory Structure (Laravel 12 + Inertia 2 + React 19 + SASS)

```text
resources/
├── css/                  # Global Styles (SASS/SCSS)
│   ├── main.scss         # Main SASS entry point (imports all partials)
│   ├── _variables.scss   # Global variables ($primary-color, $spacing, etc.)
│   ├── _reset.scss       # CSS reset/normalize
│   ├── components/       # Component-specific styles
│   │   ├── _buttons.scss
│   │   ├── _menu-item-card.scss
│   │   └── _star-rating.scss
│   ├── layouts/          # Layout-specific styles
│   │   └── _customer.scss
│   └── pages/            # Page-specific styles
│       ├── _auth.scss
│       ├── _profile.scss
│       ├── _restaurant-index.scss
│       └── _restaurant-show.scss
│
├── js/
│   ├── Components/       # Reusable UI elements (PascalCase for React)
│   │   ├── UI/           # "Atoms": Basic reusable components
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── Modal.tsx
│   │   │   └── Label.tsx
│   │   └── Shared/       # "Molecules": Domain-specific reusable components
│   │       ├── RestaurantCard.tsx
│   │       ├── StarRating.tsx
│   │       ├── CartItem.tsx
│   │       └── Navbar.tsx
│   │
│   ├── Layouts/          # Layout wrappers (Navbar, Footer, Sidebar)
│   │   ├── GuestLayout.tsx      # Public/unauthenticated pages
│   │   ├── CustomerLayout.tsx   # Customer-facing authenticated pages
│   │   ├── AuthLayout.tsx       # Authentication pages (Login/Register)
│   │   └── AdminLayout.tsx      # Restaurant/Admin pages
│   │
│   ├── Pages/            # Inertia pages (returned by Laravel Controllers)
│   │   ├── Auth/         # Authentication pages
│   │   │   ├── Login.tsx
│   │   │   ├── Register.tsx
│   │   │   └── ForgotPassword.tsx
│   │   ├── Customer/     # Customer-facing pages
│   │   │   ├── Restaurants/
│   │   │   │   ├── Index.tsx
│   │   │   │   └── Show.tsx
│   │   │   ├── Cart/
│   │   │   │   └── Index.tsx
│   │   │   ├── Orders/
│   │   │   │   ├── Index.tsx
│   │   │   │   └── Show.tsx
│   │   │   ├── Profile/
│   │   │   │   └── Index.tsx
│   │   │   └── Dashboard.tsx
│   │   ├── Restaurant/   # Restaurant/Admin pages
│   │   │   ├── Menu/
│   │   │   │   ├── Index.tsx
│   │   │   │   ├── Create.tsx
│   │   │   │   └── Edit.tsx
│   │   │   └── Orders/
│   │   │       ├── Index.tsx
│   │   │       └── Show.tsx
│   │   └── Home.tsx      # Public homepage
│   │
│   ├── Hooks/            # Custom React Hooks (PascalCase)
│   │   ├── useCart.ts
│   │   ├── useAuth.ts
│   │   └── useFlashMessages.ts
│   │
│   ├── Utils/            # Helper functions and utilities
│   │   ├── formatters.ts    # Date, currency formatters
│   │   ├── validators.ts    # Form validation helpers
│   │   └── constants.ts     # App constants
│   │
│   ├── app.tsx           # Main Inertia entry point
│   ├── bootstrap.ts      # Bootstrap imports (axios, Echo, etc.)
│   └── ziggy.js          # Auto-generated Ziggy routes (do not edit manually)
```

---

### 2. The "Slicing" Logic (How to organize code)

In React + Inertia, we slice the application based on **Scope** and **Reusability**.

#### A. Pages (The "Controller View")

These are specific to a URL. If Laravel returns `Inertia::render('Customer/Restaurants/Index')`, you **must** have a file at `Pages/Customer/Restaurants/Index.tsx`.

- **Role:** Receive data (props) from Laravel, pass it to components, and define the Layout.
- **Logic:** They shouldn't have heavy CSS or complex logic. They just assemble components.

#### B. Layouts (The "Master Template")

Think of these as your Blade `@extends('layouts.app')`.

- **Role:** Contain the Navbar, Sidebar, Footer, and Flash Messages.
- **Persistence:** In Inertia, layouts persist between page clicks, meaning your scroll position in a sidebar stays the same while the page content changes.

#### C. Components (The "Building Blocks")

We split these into two types:

1.  **UI (Atoms):** Dumb components. They don't know about your "Business Logic".
    - _Example:_ A `<PrimaryButton>` that is blue and has rounded corners. It doesn't know it's used for "Checkout", it just knows it's a button.
2.  **Shared (Molecules):** Components that display specific data.
    - _Example:_ A `<RestaurantCard restaurant={data} />`. It knows it needs to display a name and a rating.

---

### 3. Code Examples

#### 1. The UI Component (`Components/UI/Button.tsx`)

This is a reusable button component with semantic class names. Styles are defined in `resources/css/components/_buttons.scss`.

```tsx
// resources/js/Components/UI/Button.tsx
import { ButtonHTMLAttributes } from 'react';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  className?: string;
}

export default function Button({
  className = '',
  disabled,
  children,
  ...props
}: ButtonProps) {
  return (
    <button
      {...props}
      className={`btn-primary ${disabled ? 'disabled' : ''} ${className}`}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
```

#### 2. The Layout (`Layouts/CustomerLayout.tsx`)

This wraps your customer pages. Note the `{children}` prop—this is where the Page content goes. Styles are defined in `resources/css/layouts/_customer-layout.scss`.

```tsx
// resources/js/Layouts/CustomerLayout.tsx
import { PropsWithChildren } from 'react';
import { Link } from '@inertiajs/react';
import {
  MapPinIcon,
  ShoppingCartIcon,
  UserIcon,
} from '@heroicons/react/24/outline';

interface CustomerLayoutProps extends PropsWithChildren {}

interface NavLinkProps {
  href: string;
  active: boolean;
  icon: React.ElementType;
  label: string;
}

function NavLink({ href, active, icon: Icon, label }: NavLinkProps) {
  return (
    <Link href={href} className={`nav-item ${active ? 'active' : ''}`}>
      <Icon className="icon" aria-hidden="true" />
      <span className="label">{label}</span>
    </Link>
  );
}

export default function CustomerLayout({ children }: CustomerLayoutProps) {
  return (
    <div className="customer-layout">
      <main className="main-content">{children}</main>

      <nav className="bottom-nav">
        <NavLink
          href={route('restaurants.index')}
          active={route().current('restaurants.index')}
          icon={MapPinIcon}
          label="Explore"
        />
        <NavLink
          href={route('orders.index')}
          active={route().current('orders.index')}
          icon={ShoppingCartIcon}
          label="Orders"
        />
        <NavLink
          href={route('profile.show')}
          active={route().current('profile.show')}
          icon={UserIcon}
          label="Profile"
        />
      </nav>
    </div>
  );
}
```

#### 3. The Page (`Pages/Customer/Restaurants/Index.tsx`)

This connects everything. It receives `restaurants` from your Laravel Controller. Styles are defined in `resources/css/pages/_restaurants.scss`.

```tsx
// resources/js/Pages/Customer/Restaurants/Index.tsx
import { Head, Link } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout';
import StarRating from '@/Components/Shared/StarRating';
import { Restaurant } from '@/types/models';
import { PageProps } from '@/types';
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';

interface RestaurantIndexProps extends PageProps {
  restaurants: Restaurant[];
}

export default function RestaurantIndex({ restaurants }: RestaurantIndexProps) {
  return (
    <CustomerLayout>
      <Head title="Explore Restaurants" />

      <div className="restaurant-index-page">
        {/* Search Bar */}
        <div className="search-header">
          <div className="search-bar">
            <MagnifyingGlassIcon className="search-icon" />
            <input
              type="text"
              placeholder="Search restaurants..."
              className="search-input"
            />
          </div>
        </div>

        {/* Restaurant List */}
        <div className="restaurant-list">
          {restaurants.map((restaurant) => {
            const primaryImage =
              restaurant.images?.find((img) => img.is_primary_for_restaurant) ||
              restaurant.images?.[0];
            const imageUrl = primaryImage
              ? primaryImage.url
              : '/images/placeholder-restaurant.jpg';

            return (
              <Link
                key={restaurant.id}
                href={route('restaurants.show', restaurant.id)}
                className="restaurant-card-link"
              >
                <div className="restaurant-card">
                  {/* Restaurant Image */}
                  <div className="restaurant-image-wrapper">
                    <img
                      src={imageUrl}
                      alt={restaurant.name}
                      className="restaurant-image"
                    />
                  </div>

                  {/* Restaurant Info */}
                  <div className="restaurant-info">
                    <div className="restaurant-header">
                      <h3 className="restaurant-name">{restaurant.name}</h3>
                      <StarRating rating={restaurant.rating || 0} />
                    </div>

                    <div className="restaurant-meta">
                      {restaurant.opening_hours ? (
                        <span className="meta-item">
                          {restaurant.opening_hours}
                        </span>
                      ) : (
                        <span className="meta-item">Hours not available</span>
                      )}
                      <span className="meta-separator">•</span>
                      <span className="meta-item">~3km</span>
                    </div>

                    <p className="restaurant-description">
                      {restaurant.description ||
                        'The best food in the world please buy it ASAP'}
                    </p>
                  </div>
                </div>
              </Link>
            );
          })}
        </div>
      </div>
    </CustomerLayout>
  );
}
```
