import { useMemo } from 'react';
import { router } from '@inertiajs/react';
import { useCart } from '@/Contexts/CartContext';

export function useRestaurantCart(restaurantId: number) {
  const { items } = useCart();

  const restaurantCartItems = useMemo(
    () => items.filter((item) => item.restaurant_id === restaurantId),
    [items, restaurantId],
  );

  const cartItemCount = restaurantCartItems.reduce(
    (sum, item) => sum + item.quantity,
    0,
  );

  const cartTotal = restaurantCartItems.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0,
  );

  const handleGoToCart = () => {
    router.visit(route('cart.index', { restaurant_id: restaurantId }));
  };

  return {
    cartItemCount,
    cartTotal,
    handleGoToCart,
  };
}
