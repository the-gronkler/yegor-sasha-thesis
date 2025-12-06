# CSS Documentation

## Overview
The project uses SCSS for styling, following a modular structure. The entry point is `resources/css/main.scss`, which imports all partials.

## Directory Structure
```text
resources/css/
├── main.scss           # The HUB: Imports all partials.
├── _variables.scss     # Aggregates variable partials
├── _reset.scss         # CSS Resets
├── variables/          # Variable definitions
│   ├── _main-colors.scss
│   └── _layout.scss
├── components/         # Styles for specific components
│   ├── _buttons.scss
│   ├── _menu-item-card.scss
│   └── _star-rating.scss
├── layouts/            # Styles for layouts
│   └── _customer.scss
└── pages/              # Styles specific to pages
    ├── _auth.scss
    └── _restaurant-show.scss
```

## Base
### `_reset.scss`
Provides a baseline for consistent styling across browsers.
- Sets `box-sizing: border-box` globally.
- Defines base font settings (Inter font family, line-height).
- Resets default margins and paddings.
- Sets default styles for links, lists, and images.

## Variables
Variables are split into partials within the `variables/` directory and aggregated in `_variables.scss`.

### `variables/_main-colors.scss`
Defines the color palette for the application.
- **Brand Colors**: `$brand-primary` (#EE5B2B), `$accent-warm` (#F59E0B).
- **Text Colors**: `$text-primary`, `$text-secondary`, `$text-inverse`.
- **Backgrounds**: `$bg-main` (app background), `$bg-surface` (cards/modals), `$bg-alt-1`, `$bg-alt-2`.
- **Button States**: Derived colors for hover and disabled states.

### `variables/_layout.scss`
Defines structural variables.
- **Borders**: `$border-radius` (8px), `$border-radius-pill`.
- **Shadows**: `$box-shadow` for elevated elements.

## Layouts
### `layouts/_customer.scss`
Defines the main layout structure for the customer-facing application.
- `.customer-layout`: A flex-column container ensuring the footer stays at the bottom.
- `.bottom-nav`: A fixed position navigation bar at the bottom of the screen, containing navigation items with icons.

## Components
### `components/_buttons.scss`
Reusable button styles.
- `.btn-primary`: The main call-to-action button. Supports hover and disabled states.
- `.btn-icon`: A circular button designed for icons (e.g., back buttons, action triggers).

### `components/_menu-item-card.scss`
Styles for displaying individual menu items.
- `.menu-item-card`: The main container.
- `.unavailable`: A modifier class that dims the card and adds an "UNAVAILABLE" overlay.
- Includes styles for the item image, details (name, description, price), and the "add" button.

### `components/_star-rating.scss`
A component for displaying ratings.
- `.star-rating`: Flex container for the stars.
- `.star`: The star icon.
- `.star.filled`: Modifier for active/filled stars (uses `$accent-warm`).

## Pages
### `pages/_restaurant-index.scss`
Styles for the Restaurant Index page (Explore Restaurants).
- `.restaurant-index-page`: The page wrapper with bottom padding for the navigation.
- `.search-header`: A sticky header containing the search bar.
- `.search-bar`: The search input container with icon and input field.
- `.restaurant-list`: A vertical list of restaurant cards.
- `.restaurant-card`: Individual restaurant card with image and info sections.
- `.restaurant-image-wrapper`: Fixed-height container for restaurant images.
- `.restaurant-info`: Contains restaurant details (name, rating, meta, description).
- Responsive design: Centers content on larger screens (max-width: 600px).

### `pages/_auth.scss`
Styles specific to authentication pages (Login/Register).
- `.auth-page`: A full-height, centered flex layout.
- `.auth-card`: The container for the authentication form.
- Includes specific styles for form groups, inputs, error messages, and form actions (remember me, forgot password).

### `pages/_restaurant-show.scss`
Styles for the Restaurant Details page.
- `.restaurant-show-page`: The page wrapper.
- `.restaurant-banner`: A large hero image area at the top.
- `.restaurant-info-card`: A card containing restaurant details that overlaps the banner.
- `.menu-search`: Styles for the search input within the menu.
- `.menu-category`: Styles for category headers.


