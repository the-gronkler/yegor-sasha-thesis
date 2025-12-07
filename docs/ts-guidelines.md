# TypeScript & Code Structure Guidelines

This document outlines the strict guidelines for TypeScript usage and code structure in this project. All frontend development must adhere to these standards to ensure consistency, type safety, and maintainability.

## 1. File Extensions & Naming

- **Components & Pages**: Must use `.tsx` extension.
- **Hooks & Utilities**: Must use `.ts` extension (unless they return JSX, then `.tsx`).
- **Type Definitions**: Must use `.d.ts` for declaration files or `.ts` for exported types.
- **Naming Convention**:
    - **Components/Pages**: `PascalCase` (e.g., `RestaurantCard.tsx`, `UserProfile.tsx`).
    - **Hooks**: `camelCase` prefixed with `use` (e.g., `useAuth.ts`).
    - **Utilities**: `camelCase` (e.g., `formatDate.ts`).
    - **Types**: `PascalCase` (e.g., `User`, `PaginatedResponse`).

## 2. Type Definitions

### A. Centralized Models

- **Database Models**: All interfaces reflecting database tables must be defined in `resources/js/types/models.d.ts`.
- **Do NOT** redefine models locally in components. Import them.

    ```typescript
    // ✅ Correct
    import { User } from "@/types/models";

    // ❌ Incorrect
    interface User {
        id: number;
        name: string;
    }
    ```

### B. Component Props

- **Explicit Interfaces**: Every component must define an interface for its props.
- **Exporting Props**: Export the props interface if it might be reused or needed for testing.
- **Naming**: Use `[ComponentName]Props`.

    ```typescript
    interface ButtonProps {
        label: string;
        onClick: () => void;
    }

    export default function Button({ label, onClick }: ButtonProps) { ... }
    ```

### C. Page Props (Inertia)

- **Extending PageProps**: Page components must define a props interface that extends the global `PageProps` (if accessing global data) or simply defines the specific data passed from the controller.

    ```typescript
    import { PageProps } from '@/types';
    import { Restaurant } from '@/types/models';

    interface DashboardProps extends PageProps {
        restaurants: Restaurant[];
    }

    export default function Dashboard({ auth, restaurants }: DashboardProps) { ... }
    ```

## 3. Strict Typing Rules

- **No `any`**: The use of `any` is strictly forbidden. Use `unknown` if the type is truly not known yet, or define a proper generic.
- **No Implicit `any`**: All function parameters must have explicit types.
- **Optional Fields**: Use `?` for optional properties. Do not use `| undefined` unless explicitly required by a library.

    ```typescript
    // ✅ Correct
    interface User {
        middleName?: string;
    }

    // ❌ Avoid
    interface User {
        middleName: string | undefined;
    }
    ```

- **Event Handlers**: Use React's built-in types for events.

    ```typescript
    import { FormEventHandler, ChangeEvent } from 'react';

    const handleSubmit: FormEventHandler = (e) => { ... };
    const handleChange = (e: ChangeEvent<HTMLInputElement>) => { ... };
    ```

## 4. Component Structure

Components should follow this ordering:

1.  **Imports**:
    - External libraries (React, Inertia, etc.)
    - Internal Components
    - Hooks/Utils
    - Types
    - Styles (if CSS modules/imports are used)
2.  **Interfaces**: Prop definitions.
3.  **Component Definition**:
    - Destructuring props.
    - Hooks (`useState`, `useEffect`, custom hooks).
    - Helper functions (handlers).
    - Return statement (JSX).
4.  **Exports**: Default export for the component.

## 5. Inertia & Laravel Integration

- **Routes**: Use the global `route()` helper. Ensure `ziggy-js` types are configured if using advanced features.
- **Forms**: Use the `useForm` hook from `@inertiajs/react`.
    - **Type the Form Data**: Pass a generic to `useForm` to ensure type safety for `data`, `setData`, etc.

    ```typescript
    interface LoginForm {
        email: string;
        remember: boolean;
    }

    const { data, setData, post } = useForm<LoginForm>({
        email: "",
        remember: false,
    });
    ```

## 6. Null Safety

- **Optional Chaining**: Use `?.` when accessing nested properties that might be undefined (especially relationships loaded via Eloquent).
    ```typescript
    const primaryImage = restaurant.images?.find((img) => img.is_primary);
    ```
- **Null Coalescing**: Use `??` to provide default values for null/undefined.
    ```typescript
    const rating = restaurant.rating ?? 0;
    ```

## 7. Global Namespace

- **Window Object**: If extending the `window` object (e.g., for `axios` or `Ziggy`), definitions must be placed in `resources/js/types/global.d.ts`.

## 8. Formatting

We use **Prettier** to enforce consistent code formatting.

- **Configuration**: [`.prettierrc`](../.prettierrc)
- **Command**: To format all files, run:
    ```powershell
    npm run format
    ```
