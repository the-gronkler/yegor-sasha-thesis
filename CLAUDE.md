# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A mobile-first restaurant discovery and ordering platform built with Laravel 11 + Inertia.js 2.0 + React 19. Features include:

- Restaurant map with heatmap filtering by distance/rating/popularity
- Real-time order tracking via WebSockets (Laravel Reverb)
- Customer and restaurant staff interfaces

## Essential Commands

```bash
# Development (runs Vite, Reverb WebSocket server, and queue worker)
npm run dev:all

# Database reset with seeding
php artisan mfs                    # Wipes DB, runs migrations, seeds
php artisan mfs --restaurants=20   # Custom restaurant count

# Formatting (auto-runs on commit via Husky)
npm run format:all                 # Format both frontend and backend

# Testing
./vendor/bin/pest                  # Run all tests
./vendor/bin/pest tests/Feature/SomeTest.php           # Single test file
./vendor/bin/pest --filter="test name"                 # Filter by test name

# Generate Ziggy routes after modifying routes/web.php
php artisan ziggy:generate

# Thesis compilation (Typst)
typst compile typst/main.typ
```

## Critical Rules

### Styling: NO TAILWIND

**Tailwind CSS is strictly prohibited** in component styling despite being in package.json. All styling must use:

- Semantic class names in JSX (e.g., `className="restaurant-card"`)
- SCSS partials in `resources/css/` (follow BEM-like naming)
- Import new partials in `resources/css/main.scss`

### TypeScript

- **No `any`** - use proper types or `unknown`
- Import models from `@/types/models` - never redefine locally
- All component props require explicit interfaces

### Commit Conventions

Follow **Conventional Commits 1.0.0**: `type(scope): description`

- Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`, `test`
- Scopes: `FE`, `BE`, `API`, `Auth`, `thesis` (for Typst content)
- Example: `feat(FE): implement restaurant menu card component`

## Architecture

### Backend (Laravel)

- **Controllers**: Thin controllers, delegate to Services/Actions
- **FormRequests**: Required for all input validation
- **Eloquent**: Use `with()` to prevent N+1 queries

### Frontend Structure

```
resources/js/
├── Components/
│   ├── UI/        # "Atoms" - generic reusable (Button, Input, Card)
│   └── Shared/    # "Molecules" - domain-specific (RestaurantCard, StarRating)
├── Layouts/       # Page wrappers (CustomerLayout, AdminLayout)
├── Pages/         # Inertia pages mirror backend routes
│   ├── Customer/Restaurants/{Index,Show}.tsx
│   ├── Customer/Orders/{Index,Show}.tsx
│   └── Auth/{Login,Register}.tsx
├── Hooks/         # Custom hooks (useCart, useAuth)
└── types/         # TypeScript definitions (models.d.ts)
```

### SCSS Structure

```
resources/css/
├── main.scss          # Imports all partials
├── _variables.scss    # Aggregates variable partials
├── variables/         # Color and layout variables
├── components/        # Component styles (_buttons.scss, etc.)
├── layouts/           # Layout styles
└── pages/             # Page-specific styles
```

### Real-Time (WebSockets)

Uses Laravel Reverb. Start with `php artisan reverb:start` and `php artisan queue:work`.

## Typst Thesis Guidelines

When working in `typst/` directory, switch to academic writing mode:

### Writing Voice

- **No first-person**: Never use "I", "we", "our"
- **No second-person**: Never address reader as "you"
- **No contractions**: Use "cannot" not "can't"
- **Formal tone**: Avoid colloquialisms

### Required Functions

````typst
#import "../config.typ": source_code_link, code_example

// Link to source files (never hardcode GitHub URLs)
#source_code_link("routes/channels.php")

// Keep explanatory text with code blocks (MANDATORY)
#code_example[
  The system uses events for updates.
  ```php
  class OrderUpdated implements ShouldBroadcast { }
````

]

```

### Formatting
- Headings: `=`, `==`, `===` (never use bold as pseudo-headings)
- Bold: `*text*` / Italic: `_text_`
- Citations: `@citationkey`
- Figures: Use `#figure()` with `<fig:label>`, reference with `@fig:label`

## Key Documentation Files

- `docs/dev-documentation.md` - Developer setup and commands
- `docs/fe-project-structure.md` - Frontend architecture
- `docs/ts-guidelines.md` - TypeScript standards
- `docs/css-documentation.md` - SCSS rules and structure
- `typst/README.md` - Thesis formatting guide
```
