import { ReactNode } from 'react';

export type ProviderWrapper = (children: ReactNode) => ReactNode;

/**
 * Composes a list of providers around an initial component.
 *
 * @param providers List of provider wrappers.
 * @param initialComponent The component to wrap (usually the App).
 * @returns The wrapped component tree.
 */
export function composeProviders(
  providers: ProviderWrapper[],
  initialComponent: ReactNode,
): ReactNode {
  return providers.reduceRight(
    (acc, provider) => provider(acc),
    initialComponent,
  );
}
