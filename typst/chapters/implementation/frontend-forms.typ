#import "../../config.typ": code_example, source_code_link

==== Form Handling Implementation

Form state management uses Inertia's `useForm` hook, which provides declarative state management, automatic error handling, and integration with Laravel's validation system. This pattern appears consistently across authentication, order management, and menu editing flows.

===== Basic useForm Pattern

The hook accepts an initial state object defining all form fields and returns methods for state mutation, submission, and error handling (see #source_code_link("resources/js/Pages/Auth/Register.tsx")). The `form` object provides `data` (current values), `setData()` (field updates), `post()`/`put()`/`delete()` (submission), `processing` (submission state), `errors` (validation errors), and `reset()` (field clearing). Input elements connect via controlled component pattern using `value={form.data.field}` and `onChange={(e) => form.setData('field', e.target.value)}`.

===== TypeScript Generics for Type Safety

The `useForm` hook accepts a generic type parameter defining the form data shape, enabling autocomplete for field names and type checking for values. This prevents typos and ensures values match expected types, catching errors during development.

===== Validation Error Display

Laravel validation errors flow automatically into `form.errors` with keys matching form field names, enabling direct conditional rendering: `{form.errors.field && <span>{form.errors.field}</span>}`. The `form.processing` boolean controls submit button state and loading indicators, preventing duplicate submissions. Sensitive fields can be cleared after submission using `form.reset()` in the `onFinish` callback, which executes whether submission succeeds or fails.
