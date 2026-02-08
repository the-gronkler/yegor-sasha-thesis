#import "../../config.typ": code_example, source_code_link

==== Accessibility Implementation

Accessibility is enforced at the UI component layer to ensure consistent patterns across the application. The implementation prioritizes semantic HTML, ARIA attributes, keyboard navigation, and focus management.

===== Semantic HTML Structure

Components use semantic HTML elements that communicate roles to assistive technologies without requiring additional annotations. This preference for native semantics over generic containers improves compatibility with screen readers and reduces maintenance burden.

#code_example[
  Button components use `<button>` elements rather than styled `<div>` with click handlers.

  ```typescript
  // Correct: semantic button with implicit ARIA role
  <button
    type="button"
    onClick={handleAddToCart}
    className="btn-primary"
  >
    Add to Cart
  </button>

  // Incorrect: generic div requiring manual ARIA
  // <div onClick={handleAddToCart} role="button" tabIndex={0}>
  //   Add to Cart
  // </div>
  ```
]

Navigation structures use `<nav>` landmarks, content sections use `<main>`, `<aside>`, and `<section>` elements with appropriate headings. This structure enables screen reader users to navigate by landmarks and skip irrelevant content.

===== Descriptive ARIA Labels for Context

Interactive elements receive descriptive `aria-label` attributes when visible text alone does not convey full context. This is particularly important for icon-only buttons and actions that depend on surrounding data.

#code_example[
  Cart item removal buttons include item name in ARIA label for clarity.

  ```typescript
  <button
    type="button"
    onClick={() => removeFromCart(item.id)}
    aria-label={`Remove ${item.name} from cart`}
    className="btn-icon-danger"
  >
    <TrashIcon />
  </button>
  ```
]

Without the descriptive label, screen readers would announce only "button" or the button's class name, providing no indication of what the button removes. The pattern includes dynamic data (item name) to disambiguate when multiple similar buttons exist on the page.

===== Form Label Association

All form inputs associate with visible labels using explicit `htmlFor` attributes matching input `id` values. This enables clicking labels to focus inputs and ensures screen readers announce labels when inputs receive focus.

#code_example[
  Form fields use id/htmlFor association rather than implicit label wrapping.

  ```typescript
  <div className="form-field">
    <label htmlFor="restaurant-name">Restaurant Name</label>
    <input
      id="restaurant-name"
      type="text"
      value={form.data.name}
      onChange={(e) => form.setData('name', e.target.value)}
    />
  </div>
  ```
]



#code_example[
  Validation error messages are connected to inputs using `aria-describedby`, ensuring screen readers announce errors when inputs receive focus.

  ```typescript
  <input
    id="email"
    type="email"
    value={form.data.email}
    onChange={(e) => form.setData('email', e.target.value)}
    aria-describedby={form.errors.email ? 'email-error' : undefined}
    aria-invalid={!!form.errors.email}
  />
  {form.errors.email && (
    <span id="email-error" className="error-message">
      {form.errors.email}
    </span>
  )}
  ```
]

The `aria-invalid` attribute explicitly marks fields with validation errors, triggering screen reader announcements without requiring users to search for error text.

===== Focus Management and Keyboard Navigation

All interactive elements support keyboard-only navigation using standard tab order, Enter/Space activation, and Escape dismissal for modals and overlays.

Focus indicators are visible on all interactive elements through CSS `:focus` styles. This enables keyboard-only users to track their position in the interface.

#code_example[
  Focus styles provide visible indication of active element.

  ```scss
  .btn-primary:focus {
    outline: 2px solid var(--color-primary);
    outline-offset: 2px;
  }

  .btn-primary:focus:not(:focus-visible) {
    outline: none;
  }
  ```
]

The `:focus-visible` pseudo-class prevents focus outlines from appearing on mouse clicks while preserving them for keyboard navigation, balancing aesthetic preferences with accessibility requirements.

Modal dialogs trap focus within the modal while open, preventing keyboard navigation from escaping to background content. When dismissed, focus returns to the element that triggered the modal.
