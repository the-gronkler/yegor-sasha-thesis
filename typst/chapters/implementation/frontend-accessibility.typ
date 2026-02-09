#import "../../config.typ": code_example, source_code_link
// TODO shorten this section af
==== Accessibility Implementation

Accessibility is enforced at the UI component layer to ensure consistent patterns across the application. The implementation prioritizes semantic HTML, ARIA attributes, keyboard navigation, and focus management.

===== Semantic HTML Structure

Components use semantic HTML elements that communicate roles to assistive technologies @WCAG21 @WAIARIA without requiring additional annotations. This preference for native semantics over generic containers improves compatibility with screen readers and reduces maintenance burden.

Navigation structures use `<nav>` landmarks, content sections use `<main>`, `<aside>`, and `<section>` elements with appropriate headings. This structure enables screen reader users to navigate by landmarks and skip irrelevant content.

===== Descriptive ARIA Labels

Icon-only buttons receive descriptive `aria-label` attributes to convey context to screen readers. For example, cart removal buttons include the item name: `aria-label={Remove ${item.name} from cart}`.


===== Focus Management and Keyboard Navigation

All interactive elements support keyboard-only navigation using standard tab order, Enter/Space activation, and Escape dismissal for modals. Visible focus indicators are applied through CSS `:focus` styles, with `:focus-visible` used to suppress outlines on mouse clicks while preserving them for keyboard users. Modal dialogs trap focus within the modal while open and return focus to the triggering element on dismissal, preventing keyboard navigation from escaping to obscured background content.
