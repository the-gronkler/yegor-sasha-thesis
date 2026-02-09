#import "../../config.typ": code_example, source_code_link

==== Form Handling Implementation

Form state management uses Inertia's `useForm` hook, which provides declarative state management, automatic error handling, and integration with Laravel's validation system. This pattern appears consistently across authentication, order management, and menu editing flows.

===== Basic useForm Pattern

The hook accepts an initial state object defining all form fields and returns methods for state mutation, submission, and error handling. The returned `form` object provides `data` (current values), `setData` (field updates), `post`/`put`/`delete` (submission methods), `processing` (submission state), `errors` (validation errors keyed by field name), and `reset` (field clearing).

#code_example[
  The registration form in #source_code_link("resources/js/Pages/Auth/Register.tsx") demonstrates the standard pattern: declare form state, bind inputs via controlled components, and submit through the form object.

  ```typescript
  const form = useForm({
    name: '', email: '', password: '', password_confirmation: '',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    form.post(window.route('register.store'), {
      onFinish: () => form.reset('password', 'password_confirmation'),
    });
  };

  // Input binding via controlled component pattern
  <input
    type="email"
    value={form.data.email}
    onChange={(e) => form.setData('email', e.target.value)}
    disabled={form.processing}
  />
  {form.errors.email && (
    <span className="error-message">{form.errors.email}</span>
  )}
  ```
]

===== TypeScript Generics for Type Safety

The `useForm` hook accepts a generic type parameter (e.g., `useForm<MenuItemFormData>({...})`) that defines the form data shape. This enables autocomplete for field names and compile-time type checking for values, preventing typos and type mismatches.

The typed form interfaces follow the same conventions described in the frontend type system design; an example is visible in #source_code_link("resources/js/Pages/Employee/MenuItems/MenuItemForm.tsx").

===== Validation Error Display

Laravel validation errors flow automatically into `form.errors`, keyed by field name. The consistent display pattern checks for the presence of an error, conditionally applies an `input-error` class to the input element, and renders the error message in a styled `<span>`. This pattern is demonstrated in the basic useForm example above and applied uniformly across all forms in the application.

===== Processing State for Button Feedback

The `form.processing` boolean indicates whether a submission is in progress, controlling submit button disabled state and loading text (e.g., "Saving..." vs. "Save Changes"). This prevents duplicate submissions and provides immediate visual feedback without additional state management.

