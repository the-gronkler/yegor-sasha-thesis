#import "../../config.typ": code_example, source_code_link

==== Form Handling Implementation

Form state management uses Inertia's `useForm` hook, which provides declarative state management, automatic error handling, and integration with Laravel's validation system. This pattern appears consistently across authentication, order management, and menu editing flows.

===== Basic useForm Pattern

The hook accepts an initial state object defining all form fields and returns methods for state mutation, submission, and error handling.

#code_example[
  The registration form demonstrates the standard useForm pattern in #source_code_link("resources/js/Pages/Auth/Register.tsx").

  ```typescript
  const form = useForm({
    name: '',
    surname: '',
    email: '',
    password: '',
    password_confirmation: '',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    form.post(window.route('register.store'), {
      onFinish: () => form.reset('password', 'password_confirmation'),
    });
  };
  ```
]

The `form` object provides:
- `form.data`: Current field values
- `form.setData(field, value)`: Updates individual field
- `form.post(url, options)`: Submits form via POST request
- `form.processing`: Boolean indicating submission state
- `form.errors`: Validation errors keyed by field name
- `form.reset(...fields)`: Clears specified fields

Input elements connect to form state through controlled component pattern:

#code_example[
  Form inputs use `value` and `onChange` to connect to useForm state.

  ```typescript
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

The `useForm` hook accepts a generic type parameter defining the form data shape. This enables autocomplete for field names and type checking for values.

#code_example[
  Defining a form data interface provides type safety for all form operations.

  ```typescript
  interface MenuItemFormData {
    name: string;
    description: string;
    price: number;
    is_available: boolean;
    food_type_id: number;
    allergen_ids: number[];
  }

  const form = useForm<MenuItemFormData>({
    name: menuItem?.name ?? '',
    description: menuItem?.description ?? '',
    price: menuItem?.price ?? 0,
    is_available: menuItem?.is_available ?? true,
    food_type_id: menuItem?.food_type_id ?? 0,
    allergen_ids: menuItem?.allergens?.map(a => a.id) ?? [],
  });

  // TypeScript knows 'name' is a valid field and expects string
  form.setData('name', value);

  // TypeScript catches invalid field names at compile time
  // form.setData('invalid_field', value); // Error!
  ```
]

This prevents typos in field names and ensures values match expected types, catching errors during development rather than in production.

===== Validation Error Display

Laravel validation errors flow automatically into `form.errors`. The object keys match form field names, enabling direct error display adjacent to inputs.

The pattern for displaying errors consistently:
1. Check if error exists for field
2. Display error message in styled container
3. Optionally apply error styling to input element

#code_example[
  Error display pattern with conditional rendering and semantic classes.

  ```typescript
  <div className="form-field">
    <label htmlFor="price">Price</label>
    <input
      id="price"
      type="number"
      value={form.data.price}
      onChange={(e) => form.setData('price', parseFloat(e.target.value))}
      className={form.errors.price ? 'input-error' : ''}
    />
    {form.errors.price && (
      <span className="error-message">{form.errors.price}</span>
    )}
  </div>
  ```
]

===== Processing State for Button Feedback

The `form.processing` boolean indicates whether a submission is in progress. This value controls submit button disabled state and loading indicators, preventing duplicate submissions and providing visual feedback.

#code_example[
  Submit button uses processing state for user feedback.

  ```typescript
  <button
    type="submit"
    disabled={form.processing}
    className="btn-primary"
  >
    {form.processing ? 'Saving...' : 'Save Changes'}
  </button>
  ```
]

===== Optional Field Reset on Success

Sensitive form fields can be cleared after successful submission using `form.reset()` in the `onFinish` callback. This is particularly important for password fields that should not remain in component state after use.

#code_example[
  Password fields are reset after submission completes.

  ```typescript
  form.post(window.route('register.store'), {
    onFinish: () => form.reset('password', 'password_confirmation'),
  });
  ```
]

The `onFinish` callback executes whether submission succeeds or fails, ensuring sensitive data is cleared in both cases.
