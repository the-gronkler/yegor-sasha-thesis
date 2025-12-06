The best way to structure an Inertia app is to mirror the Backend structure for **Pages**, while keeping reusable UI elements in **Components**.

### 1. Recommended Directory Structure (Laravel 12 + Inertia 2 + React 19 + SASS)

```text
resources/
├── css/                  # Global Styles (SASS/SCSS)
│   ├── app.scss          # Main SASS entry point (imports all partials)
│   ├── _variables.scss   # Global variables ($primary-color, $spacing, etc.)
│   ├── _mixins.scss      # Reusable SASS mixins
│   ├── _reset.scss       # CSS reset/normalize
│   ├── components/       # Component-specific styles
│   │   ├── _buttons.scss
│   │   ├── _cards.scss
│   │   ├── _forms.scss
│   │   └── _modals.scss
│   ├── layouts/          # Layout-specific styles
│   │   ├── _auth-layout.scss
│   │   ├── _customer-layout.scss
│   │   └── _guest-layout.scss
│   └── pages/            # Page-specific styles
│       ├── _home.scss
│       ├── _login.scss
│       └── _restaurants.scss
│
├── js/
│   ├── Components/       # Reusable UI elements (PascalCase for React)
│   │   ├── UI/           # "Atoms": Basic reusable components
│   │   │   ├── Button.jsx
│   │   │   ├── Input.jsx
│   │   │   ├── Card.jsx
│   │   │   ├── Modal.jsx
│   │   │   └── Label.jsx
│   │   └── Shared/       # "Molecules": Domain-specific reusable components
│   │       ├── RestaurantCard.jsx
│   │       ├── StarRating.jsx
│   │       ├── CartItem.jsx
│   │       └── Navbar.jsx
│   │
│   ├── Layouts/          # Layout wrappers (Navbar, Footer, Sidebar)
│   │   ├── GuestLayout.jsx      # Public/unauthenticated pages
│   │   ├── CustomerLayout.jsx   # Customer-facing authenticated pages
│   │   ├── AuthLayout.jsx       # Authentication pages (Login/Register)
│   │   └── AdminLayout.jsx      # Restaurant/Admin pages
│   │
│   ├── Pages/            # Inertia pages (returned by Laravel Controllers)
│   │   ├── Auth/         # Authentication pages
│   │   │   ├── Login.jsx
│   │   │   ├── Register.jsx
│   │   │   └── ForgotPassword.jsx
│   │   ├── Customer/     # Customer-facing pages
│   │   │   ├── Restaurants/
│   │   │   │   ├── Index.jsx
│   │   │   │   └── Show.jsx
│   │   │   ├── Cart/
│   │   │   │   └── Index.jsx
│   │   │   ├── Orders/
│   │   │   │   ├── Index.jsx
│   │   │   │   └── Show.jsx
│   │   │   ├── Profile/
│   │   │   │   └── Index.jsx
│   │   │   └── Dashboard.jsx
│   │   ├── Restaurant/   # Restaurant/Admin pages
│   │   │   ├── Menu/
│   │   │   │   ├── Index.jsx
│   │   │   │   ├── Create.jsx
│   │   │   │   └── Edit.jsx
│   │   │   └── Orders/
│   │   │       ├── Index.jsx
│   │   │       └── Show.jsx
│   │   └── Home.jsx      # Public homepage
│   │
│   ├── Hooks/            # Custom React Hooks (PascalCase)
│   │   ├── useCart.js
│   │   ├── useAuth.js
│   │   └── useFlashMessages.js
│   │
│   ├── Utils/            # Helper functions and utilities
│   │   ├── formatters.js    # Date, currency formatters
│   │   ├── validators.js    # Form validation helpers
│   │   └── constants.js     # App constants
│   │
│   ├── app.jsx           # Main Inertia entry point
│   ├── bootstrap.js      # Bootstrap imports (axios, Echo, etc.)
│   └── ziggy.js          # Auto-generated Ziggy routes (do not edit manually)
```

---

### 2. The "Slicing" Logic (How to organize code)

In React + Inertia, we slice the application based on **Scope** and **Reusability**.

#### A. Pages (The "Controller View")
These are specific to a URL. If Laravel returns `Inertia::render('Customer/Restaurants/Index')`, you **must** have a file at `Pages/Customer/Restaurants/Index.jsx`.
*   **Role:** Receive data (props) from Laravel, pass it to components, and define the Layout.
*   **Logic:** They shouldn't have heavy CSS or complex logic. They just assemble components.

#### B. Layouts (The "Master Template")
Think of these as your Blade `@extends('layouts.app')`.
*   **Role:** Contain the Navbar, Sidebar, Footer, and Flash Messages.
*   **Persistence:** In Inertia, layouts persist between page clicks, meaning your scroll position in a sidebar stays the same while the page content changes.

#### C. Components (The "Building Blocks")
We split these into two types:
1.  **UI (Atoms):** Dumb components. They don't know about your "Business Logic".
    *   *Example:* A `<PrimaryButton>` that is blue and has rounded corners. It doesn't know it's used for "Checkout", it just knows it's a button.
2.  **Shared (Molecules):** Components that display specific data.
    *   *Example:* A `<RestaurantCard restaurant={data} />`. It knows it needs to display a name and a rating.

---

### 3. Code Examples

#### 1. The UI Component (`Components/UI/Button.jsx`)
This is a reusable button component with semantic class names. Styles are defined in `resources/css/components/_buttons.scss`.

```jsx
// resources/js/Components/UI/Button.jsx
export default function Button({ 
    variant = 'primary', 
    className = '', 
    disabled, 
    children, 
    ...props 
}) {
    return (
        <button
            {...props}
            className={`btn btn-${variant} ${disabled ? 'btn-disabled' : ''} ${className}`}
            disabled={disabled}
        >
            {children}
        </button>
    );
}
```

#### 2. The Layout (`Layouts/CustomerLayout.jsx`)
This wraps your customer pages. Note the `{children}` prop—this is where the Page content goes. Styles are defined in `resources/css/layouts/_customer-layout.scss`.

```jsx
// resources/js/Layouts/CustomerLayout.jsx
import { Link, usePage } from '@inertiajs/react';

export default function CustomerLayout({ children }) {
    const { auth } = usePage().props; // Access shared data like authenticated User

    return (
        <div className="customer-layout">
            <nav className="main-nav">
                <div className="container">
                    <div className="nav-wrapper">
                        <div className="nav-left">
                            <Link href={route('customer.dashboard')} className="brand-logo">
                                🍔 ThesisEats
                            </Link>
                            <div className="nav-links">
                                <Link href={route('restaurants.index')} className="nav-link">
                                    Restaurants
                                </Link>
                                <Link href={route('customer.orders.index')} className="nav-link">
                                    My Orders
                                </Link>
                            </div>
                        </div>
                        <div className="nav-right">
                            <span className="user-greeting">Hello, {auth.user.name}</span>
                            <Link href={route('customer.cart.index')} className="cart-link">
                                🛒 Cart
                            </Link>
                        </div>
                    </div>
                </div>
            </nav>

            <main className="main-content">{children}</main>

            <footer className="main-footer">
                <div className="container">
                    <p>&copy; 2025 ThesisEats. All rights reserved.</p>
                </div>
            </footer>
        </div>
    );
}
```

#### 3. The Page (`Pages/Customer/Restaurants/Index.jsx`)
This connects everything. It receives `restaurants` from your Laravel Controller. Styles are defined in `resources/css/pages/_restaurants.scss`.

```jsx
// resources/js/Pages/Customer/Restaurants/Index.jsx
import React from 'react';
import { Head, Link } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout';
import Button from '@/Components/UI/Button';

export default function RestaurantIndex({ restaurants }) {
    return (
        <CustomerLayout>
            <Head title="All Restaurants" />

            <div className="restaurant-index-page">
                <div className="container">
                    <h1 className="page-title">Browse Restaurants</h1>
                    
                    <div className="restaurant-grid">
                        {restaurants.map((restaurant) => (
                            <div key={restaurant.id} className="restaurant-card">
                                {restaurant.image_url && (
                                    <img 
                                        src={restaurant.image_url} 
                                        alt={restaurant.name}
                                        className="card-image"
                                    />
                                )}
                                <div className="card-body">
                                    <h3 className="card-title">{restaurant.name}</h3>
                                    <p className="card-address">{restaurant.address}</p>
                                    {restaurant.rating && (
                                        <div className="card-rating">
                                            ⭐ {restaurant.rating} / 5
                                        </div>
                                    )}
                                    <div className="card-actions">
                                        <Link href={route('restaurants.show', restaurant.id)}>
                                            <Button variant="primary">View Menu</Button>
                                        </Link>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </CustomerLayout>
    );
}
```
