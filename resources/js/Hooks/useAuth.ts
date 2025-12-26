import { usePage, router } from '@inertiajs/react';
import { PageProps } from '@/types';

export function useAuth() {
  const { props } = usePage<PageProps>();
  const user = props.auth.user;

  const isAuthenticated = !!user;

  /**
   * Executes the action if authenticated.
   * Otherwise, prompts the user to login.
   */
  const requireAuth = (action: () => void) => {
    if (isAuthenticated) {
      action();
    } else {
      if (
        confirm('You need to be logged in to perform this action. Go to login?')
      ) {
        router.visit(route('login'));
      }
    }
  };

  return { user, isAuthenticated, requireAuth };
}
