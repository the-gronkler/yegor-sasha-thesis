import { usePage } from '@inertiajs/react';
import { PageProps } from '@/types';
import { useLoginModal } from '@/Contexts/LoginModalContext';

export function useAuth() {
  const { props } = usePage<PageProps>();
  const user = props.auth.user;
  const { openLoginModal } = useLoginModal();

  const isAuthenticated = !!user;

  const login = () => {
    openLoginModal();
  };

  /**
   * Executes the action if authenticated.
   * Otherwise, opens the login modal.
   */
  const requireAuth = (action: () => void) => {
    if (isAuthenticated) {
      action();
    } else {
      login();
    }
  };

  return { user, isAuthenticated, requireAuth, login };
}
