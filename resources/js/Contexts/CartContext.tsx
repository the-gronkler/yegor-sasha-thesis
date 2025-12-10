import {
  createContext,
  useContext,
  useState,
  useCallback,
  ReactNode,
} from 'react';
import { router } from '@inertiajs/react';
import { MenuItem, Order } from '@/types/models';

interface CartItem extends MenuItem {
  quantity: number;
  restaurant_id: number;
}

interface CartContextType {
  items: CartItem[];
  itemCount: number;
  totalPrice: number;
  addItem: (item: MenuItem, restaurantId: number) => void;
  removeItem: (menuItemId: number) => void;
  updateQuantity: (menuItemId: number, quantity: number) => void;
  clearCart: () => void;
  isLoading: boolean;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

interface CartProviderProps {
  children: ReactNode;
  initialCart?: Order[] | null;
}

export function CartProvider({ children, initialCart }: CartProviderProps) {
  const [items, setItems] = useState<CartItem[]>(() => {
    // Initialize from server-provided cart data (multiple orders)
    if (initialCart && Array.isArray(initialCart)) {
      return initialCart.flatMap((order) =>
        (order.menu_items || []).map((item) => ({
          ...item,
          quantity: item.pivot?.quantity || 1,
          restaurant_id: order.restaurant_id,
        })),
      );
    }
    return [];
  });

  const [isLoading, setIsLoading] = useState(false);

  // Calculate derived values
  const itemCount = items.reduce((sum, item) => sum + item.quantity, 0);
  const totalPrice = items.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0,
  );

  const addItem = useCallback((item: MenuItem, restaurantId: number) => {
    setIsLoading(true);

    // Optimistically update UI
    setItems((prevItems) => {
      const existingItem = prevItems.find((i) => i.id === item.id);
      if (existingItem) {
        return prevItems.map((i) =>
          i.id === item.id ? { ...i, quantity: i.quantity + 1 } : i,
        );
      }
      return [
        ...prevItems,
        { ...item, quantity: 1, restaurant_id: restaurantId },
      ];
    });

    // Send to server
    router.post(
      route('cart.addItem'),
      {
        menu_item_id: item.id,
        quantity: 1,
        restaurant_id: restaurantId,
      },
      {
        preserveScroll: true,
        preserveState: true,
        onSuccess: () => {
          setIsLoading(false);
        },
        onError: () => {
          // Revert optimistic update on error
          setItems((prevItems) => {
            const existingItem = prevItems.find((i) => i.id === item.id);
            if (existingItem && existingItem.quantity === 1) {
              return prevItems.filter((i) => i.id !== item.id);
            }
            return prevItems.map((i) =>
              i.id === item.id
                ? { ...i, quantity: Math.max(0, i.quantity - 1) }
                : i,
            );
          });
          setIsLoading(false);
        },
      },
    );
  }, []);

  const removeItem = useCallback(
    (menuItemId: number) => {
      setIsLoading(true);

      // Optimistically update UI
      const itemToRemove = items.find((i) => i.id === menuItemId);
      setItems((prevItems) => prevItems.filter((i) => i.id !== menuItemId));

      // Send to server using POST (Inertia doesn't support DELETE with body well)
      router.post(
        route('cart.removeItem'),
        {
          _method: 'DELETE',
          menu_item_id: menuItemId,
        },
        {
          preserveScroll: true,
          preserveState: true,
          onSuccess: () => {
            setIsLoading(false);
          },
          onError: () => {
            // Revert optimistic update
            if (itemToRemove) {
              setItems((prevItems) => [...prevItems, itemToRemove]);
            }
            setIsLoading(false);
          },
        },
      );
    },
    [items],
  );

  const updateQuantity = useCallback(
    (menuItemId: number, quantity: number) => {
      if (quantity <= 0) {
        removeItem(menuItemId);
        return;
      }

      setIsLoading(true);

      // Optimistically update UI
      const oldItems = items;
      setItems((prevItems) =>
        prevItems.map((i) => (i.id === menuItemId ? { ...i, quantity } : i)),
      );

      // Send to server
      const currentItem = items.find((i) => i.id === menuItemId);
      if (!currentItem) return;

      router.post(
        route('cart.updateItemQuantity'),
        {
          menu_item_id: menuItemId,
          quantity: quantity,
          restaurant_id: currentItem.restaurant_id,
        },
        {
          preserveScroll: true,
          preserveState: true,
          onSuccess: () => {
            setIsLoading(false);
          },
          onError: () => {
            // Revert optimistic update
            setItems(oldItems);
            setIsLoading(false);
          },
        },
      );
    },
    [items, removeItem],
  );

  const clearCart = useCallback(() => {
    setItems([]);
  }, []);

  return (
    <CartContext.Provider
      value={{
        items,
        itemCount,
        totalPrice,
        addItem,
        removeItem,
        updateQuantity,
        clearCart,
        isLoading,
      }}
    >
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  const context = useContext(CartContext);
  if (context === undefined) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
}
