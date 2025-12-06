The best way to structure an Inertia app is to mirror the Backend structure for **Pages**, while keeping reusable UI elements in **Components**.

### 1. Recommended Directory Structure

```text
resources/
├── css/                  # Global Styles (SCSS)
│   ├── main.scss         # The HUB: Imports all partials. Imported once in app.jsx
│   ├── _variables.scss   # Global variables ($primary-color, etc.)
│   ├── _reset.scss       # CSS Resets
│   ├── components/       # Styles for specific components (_buttons.scss, _cards.scss)
│   └── pages/            # Styles specific to pages (_home.scss)
│
├── js/
│   ├── Components/       # Reusable UI elements
│   │   ├── UI/           # "Atoms": Basic HTML wrappers
│   │   │   ├── Button.jsx
│   │   │   ├── Input.jsx
│   │   │   └── Modal.jsx
│   │   └── Shared/       # "Molecules": Specific blocks used in multiple places
│   │       ├── RestaurantCard.jsx
│   │       └── StarRating.jsx
│   │
│   ├── Layouts/          # Page wrappers (Navbar, Footer, Sidebar)
│   │   ├── GuestLayout.jsx
│   │   ├── CustomerLayout.jsx
│   │   └── AdminLayout.jsx
│   │
│   ├── Pages/            # The Views returned by Laravel Controllers
│   │   ├── Auth/             # Login, Register, ForgotPassword
│   │   ├── Customer/         # Matches Customer Controller Namespace
│   │   │   ├── Restaurants/
│   │   │   │   ├── Index.jsx
│   │   │   │   └── Show.jsx
│   │   │   └── Cart/
│   │   │       └── Index.jsx
│   │   └── Restaurant/       # Matches Restaurant/Admin Controller Namespace
│   │       └── Admin/
│   │           ├── Menu/
│   │           └── Orders/
│   │
│   ├── Hooks/            # Custom React Hooks
│   ├── Utils/            # Helper functions
│   └── app.jsx           # Main entry point (Imports ../css/main.scss)
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
This is a wrapper around the HTML button. We use a semantic class `btn-primary` instead of utility classes.

```jsx
import './Button.scss';

export default function Button({ className = '', disabled, children, ...props }) {
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

#### 2. The Layout (`Layouts/CustomerLayout.jsx`)
This wraps your customer pages. Note the `{children}` prop—this is where the Page content goes.

```jsx
import { Link, usePage } from '@inertiajs/react';
import './CustomerLayout.scss';

export default function CustomerLayout({ children }) {
    const { auth } = usePage().props; // Access shared data like User

    return (
        <div className="customer-layout">
            <nav className="main-nav">
                <div className="container">
                    <div className="nav-wrapper">
                        <div className="nav-left">
                            <Link href={route('restaurants.index')} className="brand-logo">
                                🍔 ThesisEats
                            </Link>
                        </div>
                        <div className="nav-right">
                            Hello, {auth.user.name}
                        </div>
                    </div>
                </div>
            </nav>

            <main className="main-content">{children}</main>
        </div>
    );
}
```

#### 3. The Page (`Pages/Customer/Restaurants/Index.jsx`)
This connects everything. It receives `restaurants` from your Laravel Controller.

```jsx
import React from 'react';
import { Head, Link } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout';
import Button from '@/Components/UI/Button';
import './Index.scss';

export default function RestaurantIndex({ restaurants }) {
    return (
        <CustomerLayout>
            <Head title="All Restaurants" />

            <div className="restaurant-index-page">
                <div className="container">
                    <div className="restaurant-grid">
                        
                        {restaurants.map((restaurant) => (
                            <div key={restaurant.id} className="restaurant-card">
                                <h3 className="card-title">{restaurant.name}</h3>
                                <p className="card-address">{restaurant.address}</p>
                                <div className="card-actions">
                                    <Link href={route('restaurants.show', restaurant.id)}>
                                        <Button>View Menu</Button>
                                    </Link>
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
