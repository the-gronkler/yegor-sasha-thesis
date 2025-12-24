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

/**
 * Helper to create a theme object from CSS variables with validation.
 * Throws an error if any required CSS variable is not found.
 *
 * @param vars Array of theme variable configurations
 * @returns Theme object with validated CSS variable values
 */
export const createTheme = <T extends Record<string, string>>(
  vars: readonly { key: string; cssVar: string }[],
): T => {
  const theme: Record<string, string> = {};

  for (const { key, cssVar } of vars) {
    const value = getCssVar(cssVar);
    if (!value) {
      throw new Error(`CSS variable ${cssVar} not found`);
    }
    theme[key] = value;
  }

  return theme as T;
};
