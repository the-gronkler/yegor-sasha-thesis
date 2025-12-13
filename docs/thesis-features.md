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
