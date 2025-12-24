/**
 * Helper to read CSS variables from the document root.
 * Useful for accessing SCSS variables that have been exposed as CSS custom properties.
 *
 * @param name The name of the CSS variable (e.g., '--brand-primary')
 * @returns The value of the variable, or an empty string if not found/SSR.
 */
export const getCssVar = (name: string): string => {
  if (typeof window === 'undefined') return '';
  return getComputedStyle(document.documentElement)
    .getPropertyValue(name)
    .trim();
};
