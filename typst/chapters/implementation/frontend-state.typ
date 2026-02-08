#import "../../config.typ": code_example, source_code_link

==== Global State Management with Context

React Context provides a mechanism for sharing state across components without prop drilling through intermediate layers. The implementation uses the Context API to create providers that wrap the component tree, making data and functions available to any descendant component that consumes the context.

===== Context Provider Pattern

Context providers follow a consistent implementation pattern: create a typed context, define a provider component that manages state, and export a custom hook for consumption. This pattern appears in both `CartContext` and `LoginModalContext`.

#code_example[
  The CartContext demonstrates the complete provider pattern in #source_code_link("resources/js/Contexts/CartContext.tsx").

  ```typescript
  interface CartContextType {
    items: CartItem[];
    itemCount: number;
    totalPrice: number;
    addItem: (item: MenuItem, restaurantId: number) => void;
    removeItem: (menuItemId: number) => void;
    updateQuantity: (menuItemId: number, quantity: number) => void;
    clearCart: () => void;
    isLoading: boolean;
    getOrderId: (restaurantId: number) => number | undefined;
  }

  const CartContext = createContext<CartContextType | undefined>(undefined);

  export function CartProvider({ children, initialCart }: CartProviderProps) {
    const [items, setItems] = useState<CartItem[]>(() => {
      // Initialize from server-provided cart data
      if (initialCart && Array.isArray(initialCart)) {
        return initialCart.flatMap((order) =>
          (order.menu_items || []).map((item) => ({
            ...item,
            quantity: item.pivot?.quantity || 1,
            restaurant_id: order.restaurant_id,
          }))
        );
      }
      return [];
    });

    // Derived state values
    const itemCount = items.reduce((sum, item) => sum + item.quantity, 0);
    const totalPrice = items.reduce(
      (sum, item) => sum + item.price * item.quantity,
      0
    );

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
  ```
]

The context creation uses `undefined` as the default value rather than providing mock functions. This enables the custom hook to throw an error if consumed outside a provider, catching configuration mistakes at development time.

===== Server State Initialization

Context providers accept initial state from Inertia shared props, establishing the server as the authoritative data source. The cart provider receives `initialCart` and transforms it into the client-side state structure during initialization.

#code_example[
  The useState initializer function runs once on mount, extracting cart items from server orders.

  ```typescript
  const [items, setItems] = useState<CartItem[]>(() => {
    if (initialCart && Array.isArray(initialCart)) {
      return initialCart.flatMap((order) =>
        (order.menu_items || []).map((item) => ({
          ...item,
          quantity: item.pivot?.quantity || 1,
          restaurant_id: order.restaurant_id,
        }))
      );
    }
    return [];
  });
  ```
]

This initialization pattern ensures the client state matches server state on page load before any mutations occur.

===== Synchronization with Inertia Navigation

Context state synchronizes with server state after navigation events using Inertia's event system. The provider listens for successful navigation and updates state from the new page props.

#code_example[
  The cart provider subscribes to Inertia's success event to sync state on navigation.

  ```typescript
  useEffect(() => {
    const removeListener = router.on('success', (event) => {
      const cart = event.detail.page.props.cart as Order[] | null;

      if (cart && Array.isArray(cart)) {
        setItems(
          cart.flatMap((order) =>
            (order.menu_items || []).map((item) => ({
              ...item,
              quantity: item.pivot?.quantity || 1,
              restaurant_id: order.restaurant_id,
            }))
          )
        );
      } else if (cart === null) {
        setItems([]);
      }
    });

    return () => removeListener();
  }, []);
  ```
]

This pattern maintains consistency between client and server state across page transitions. When users navigate to a different page and return, the cart reflects the server's authoritative state rather than stale client data.

===== Type-Safe Context Consumption

Components consume context through custom hooks that enforce type safety and provider presence. The custom hook pattern prevents direct `useContext` calls that could return `undefined`.

#code_example[
  Consuming components access cart state through the useCart hook.

  ```typescript
  function MenuItemCard({ item, restaurantId }: Props) {
    const { addItem, items, isLoading } = useCart();
    const itemInCart = items.find(i => i.id === item.id);

    return (
      <button
        onClick={() => addItem(item, restaurantId)}
        disabled={isLoading}
      >
        Add to Cart {itemInCart && `(${itemInCart.quantity})`}
      </button>
    );
  }
  ```
]

TypeScript verifies that `addItem`, `items`, and `isLoading` exist on the context value, and IDE autocomplete suggests all available properties and methods. If the component renders outside a `CartProvider`, the error thrown by `useCart()` provides a clear diagnostic message during development.
