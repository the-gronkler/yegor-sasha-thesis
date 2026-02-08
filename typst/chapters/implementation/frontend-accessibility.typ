#import "../../config.typ": code_example, source_code_link

==== Accessibility Implementation

Accessibility is enforced at the UI component layer to ensure consistent patterns across the application. The implementation prioritizes semantic HTML, ARIA attributes, keyboard navigation, and focus management.

===== Semantic HTML Structure

Components use semantic HTML elements that communicate roles to assistive technologies @WCAG21 @WAIARIA without requiring additional annotations. Button components use `<button>` rather than styled `<div>` with click handlers. Navigation structures use `<nav>` landmarks, content sections use `<main>`, `<aside>`, and `<section>` with appropriate headings, enabling screen reader users to navigate by landmarks.

===== Descriptive ARIA Labels for Context

Interactive elements receive descriptive `aria-label` attributes when visible text alone does not convey full context. For example, cart item removal buttons include item names: `aria-label={`Remove ${item.name} from cart`}`, disambiguating when multiple similar buttons exist on the page.

===== Form Label Association

All form inputs associate with visible labels using explicit `htmlFor` attributes matching input `id` values, enabling clicking labels to focus inputs and ensuring screen readers announce labels when inputs receive focus.

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
