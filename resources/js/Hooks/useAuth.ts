import { usePage } from '@inertiajs/react';
import { PageProps } from '@/types';
import { useLoginModal } from '@/Contexts/LoginModalContext';

export function useAuth() {
  const { props } = usePage<PageProps>();
  const auth = props.auth || {};
  const user = auth.user;
  const restaurantId = auth.restaurant_id;
  const isRestaurantAdmin = auth.isRestaurantAdmin;
  const { openLoginModal } = useLoginModal();

  const isAuthenticated = !!user;
  const isEmployee = !!restaurantId;

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

  return {
    user,
    isAuthenticated,
    isEmployee,
    restaurantId,
    isRestaurantAdmin,
    requireAuth,
    login,
  };
}
