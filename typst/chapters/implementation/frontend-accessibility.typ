#import "../../config.typ": code_example, source_code_link

==== Accessibility Implementation

Accessibility is enforced at the UI component layer to ensure consistent patterns across the application. The implementation prioritizes semantic HTML, ARIA attributes, keyboard navigation, and focus management.

===== Semantic HTML Structure

Components use native semantic HTML elements (`<button>`, `<nav>`, `<main>`, `<section>`) that communicate roles to assistive technologies @WCAG21 @WAIARIA without requiring additional ARIA annotations. This preference for native semantics over generic `<div>` containers with manual role attributes improves screen reader compatibility and reduces maintenance burden. Navigation structures use `<nav>` landmarks, and content regions use `<main>`, `<aside>`, and `<section>` with appropriate headings, enabling users to navigate by landmarks and skip irrelevant content.

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

All form inputs associate with visible labels using explicit `htmlFor`/`id` attribute pairs, enabling label clicks to focus inputs and ensuring screen readers announce labels on focus. Validation errors connect to inputs through `aria-describedby`, and `aria-invalid` marks fields with errors so that screen readers announce the error state without requiring users to search for error text. This pattern integrates with the `useForm`-based error handling described in the form handling implementation.

===== Focus Management and Keyboard Navigation

All interactive elements support keyboard-only navigation using standard tab order, Enter/Space activation, and Escape dismissal for modals. Visible focus indicators are applied through CSS `:focus` styles, with `:focus-visible` used to suppress outlines on mouse clicks while preserving them for keyboard users. Modal dialogs trap focus within the modal while open and return focus to the triggering element on dismissal, preventing keyboard navigation from escaping to obscured background content.
