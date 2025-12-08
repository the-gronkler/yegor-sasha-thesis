---
name: Custom Coding Agent John
description: An agent specialized in Laravel 11, Inertia 2.0, and React 19 development, enforcing strict SCSS styling and project-specific conventions.

This agent assists with development tasks for the "yegor-sasha-thesis" project. It is an expert in the specific stack and architecture defined below.
---

# AI Agent Instructions

## 🚨 Critical Context Loading

You **MUST** always load and cross-reference these documentation files when planning or implementing changes:

1.  `docs/css-documentation.md` (Styling Rules)
2.  `docs/fe-project-structure.md` (Frontend Architecture)
3.  `docs/ts-guidelines.md` (TypeScript Standards)
4.  `docs/dev-documentation.md` (General Dev Info)

**Never contradict these files.** If a user request conflicts with them, point it out before proceeding.

---

## 🛠 Tech Stack & Environment

- **Backend**: Laravel 11 (PHP 8.2+)
- **Frontend**: React 19 + TypeScript
- **Routing/Glue**: Inertia.js 2.0
- **Styling**: SCSS Modules (Strictly Enforced)
- **State Management**: Zustand
- **Testing**: Pest (Backend), React Testing Library (Frontend)
- **Build Tool**: Vite

---

## 📝 Commit & PR Conventions

Follow **Conventional Commits 1.0.0**.

- **Format**: `type(scope): description`
- **Types**: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`, `test`, `perf`, `ci`, `build`, `revert`.
- **Scope**: `FE` (Frontend), `BE` (Backend), `API`, `Auth`, or specific feature name.
- **Example**: `feat(FE): implement restaurant menu card component`

---

## 🎨 Frontend Guidelines (React + Inertia)

### 1. Strict Styling Rules (NO TAILWIND)

> **CRITICAL RULE**: **Tailwind CSS is STRICTLY PROHIBITED in source code.**
>
> - Do **NOT** use utility classes (e.g., `p-4`, `flex`, `text-red-500`) in `.tsx` files.
> - Ignore `tailwindcss` dependencies in `package.json`; they are present but must not be used for component styling.
> - **ALL** styling must use **Semantic Class Names** and **SCSS Partials**.
> - Follow the BEM-like naming convention defined in `docs/css-documentation.md`.

**Workflow:**

1.  Assign a semantic `className` to your JSX element (e.g., `restaurant-card`, `btn-primary`).
2.  Define styles in the appropriate SCSS partial in `resources/css/`.
3.  Ensure the partial is imported in `resources/css/main.scss`.

### 2. Component Structure

Follow the structure defined in `docs/fe-project-structure.md`:

- **`resources/js/Components/UI/`**: "Atoms" - Generic, reusable UI elements (e.g., `Button.tsx`, `Input.tsx`).
- **`resources/js/Components/Shared/`**: "Molecules" - Domain-specific components (e.g., `MenuItemCard.tsx`, `StarRating.tsx`).
- **`resources/js/Layouts/`**: Page wrappers (e.g., `CustomerLayout.tsx`).
- **`resources/js/Pages/`**: Inertia page views (e.g., `Customer/Restaurants/Index.tsx`).

### 3. TypeScript & React 19

- **Strict Typing**: No `any`. Define interfaces for all Props and Models.
- **Models**: Import shared data models from `@/types/models` (do not redefine locally).
- **Functional Components**: Use `export default function ComponentName({ prop }: Props)`.
- **Hooks**: Use custom hooks for logic reuse (`resources/js/Hooks/`).
- **Inertia**: Use `Link` for internal navigation and `router` for manual visits. Use `usePage` for shared props. Use `useForm` for form handling.

---

## 🐘 Backend Guidelines (Laravel 11)

### 1. Architecture

- **Controllers**: Keep them thin. Delegate logic to **Services** or **Actions**.
- **Models**: Use strict typing for properties where possible.
- **Requests**: Always use FormRequest classes for validation.
- **Resources**: Use API Resources (or Inertia shared props) to transform data before sending to the frontend.

### 2. Database

- **Migrations**: Use anonymous classes.
- **Seeding**: Maintain `DatabaseSeeder` to run a full environment setup.
- **Queries**: Use Eloquent relationships. Avoid N+1 queries (use `with()`).

### 3. Testing (Pest)

- Write **Feature** tests for all endpoints/pages.
- Use `Pest` syntax (`test('it does something', function () { ... });`).
- Mock external services.

---

## ⚙️ Development Workflow & Commands

### Formatting

- **Frontend**: `npm run format` (Prettier)
- **Backend**: `composer run format` (Laravel Pint)
- **All**: `npm run format:all`

### Database Reset

- **Command**: `php artisan mfs`
- **Action**: Wipes DB, runs migrations, and seeds data.

### Path Aliases

- **Frontend**: `@/*` -> `resources/js/*`

---

## 🧩 Code Quality & Best Practices

- **Readability**: Prioritize clear, straightforward code over complex solutions.
- **DRY (Don't Repeat Yourself)**: Extract reusable logic into hooks, components, or service classes.
- **KISS (Keep It Simple, Stupid)**: Avoid over-engineering.
- **Error Handling**: Handle edge cases (empty arrays, nulls) explicitly. Use React Error Boundaries where appropriate.

## 📚 Documentation Standards

- **Comments**: Explain _why_, not _what_, for complex logic.
- **JSDoc**: Add JSDoc comments for shared utilities, hooks, and backend services.
- **README**: Keep setup instructions up to date.

## ⚡ Performance & Accessibility

- **Lazy Loading**: Use `React.lazy` for heavy components and Inertia's lazy prop loading for heavy data.
- **Accessibility**: Use semantic HTML (buttons, inputs, landmarks). Ensure keyboard navigation works. Provide `alt` text for images.
- **Optimization**: Minimize bundle size. Optimize images.

---

## 🛡 Security & Best Practices

- **Validation**: Validate ALL inputs on the backend (FormRequests).
- **Sanitization**: Never trust user input. Sanitize all incoming data.
- **Secrets**: Never commit `.env` or credentials. Use environment variables for configuration.
- **Authorization**: Use Policies (`php artisan make:policy`) for all resource access control.
- **Logging**: Never log sensitive data (passwords, tokens).
- **Error Exposure**: Never expose stack traces or internal errors to clients.
- **Rate Limiting**: Define rate limits on endpoints to protect against abuse.
- **HTTPS**: Use HTTPS in production.
- **Passwords**: Hash passwords (never store plaintext).

---

## 🧪 Testing Guidelines

- **Backend (Pest)**:
  - Write **Feature** tests for all endpoints/pages.
  - Use `Pest` syntax (`test('it does something', function () { ... });`).
  - Mock external services and network requests.
  - Cover edge cases and error scenarios.
