import { useMemo } from 'react';
import { router } from '@inertiajs/react';
import { useCart } from '@/Contexts/CartContext';

/**
 * Custom hook to manage cart state for a specific restaurant.
 *
 * This hook filters the global cart items to find those belonging to the specified
 * restaurant, calculates the total item count and total price for that restaurant,
 * and provides a navigation handler to the cart page.
 *
 * @param {number} restaurantId - The ID of the restaurant to filter cart items for.
 * @returns {object} An object containing:
 *   - cartItemCount: The total number of items in the cart for this restaurant.
 *   - cartTotal: The total price of items in the cart for this restaurant.
 *   - handleGoToCart: A function to navigate to the cart page for this restaurant.
 */
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
