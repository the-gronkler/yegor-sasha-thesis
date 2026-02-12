#import "../../config.typ": code_example, source_code_link

==== Global State Management with Context

React Context provides a mechanism for sharing state across components without prop drilling through intermediate layers. The implementation uses the Context API to create providers that wrap the component tree, making data and functions available to any descendant component that consumes the context.

===== Context Provider Pattern

Context providers follow a consistent pattern: define a typed context with `createContext<T | undefined>(undefined)`, wrap state management in a provider component, and export a custom hook that throws if consumed outside the provider. The `CartContext` and `LoginModalContext` both follow this structure, as shown in #source_code_link("resources/js/Contexts/CartContext.tsx").

#code_example[
  The essential provider pattern creates a typed context, a provider component managing state, and a guarded consumption hook.

  ```typescript
  const CartContext = createContext<CartContextType | undefined>(undefined);

  export function CartProvider({ children, initialCart }: CartProviderProps) {
    const [items, setItems] = useState<CartItem[]>(/* ... */);
    // Derived values: itemCount, totalPrice
    return (
      <CartContext.Provider value={{ items, itemCount, /* ... */ }}>
        {children}
      </CartContext.Provider>
    );
  }

  export function useCart() {
    const context = useContext(CartContext);
    if (!context) throw new Error('useCart must be used within a CartProvider');
    return context;
  }
  ```
]

Using `undefined` as the default context value enables the custom hook to throw a diagnostic error if consumed outside a provider, catching configuration mistakes at development time.

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

Context state remains consistent with the server across page transitions by subscribing to Inertia's `router.on('success')` event. On each successful navigation, the cart provider extracts the updated cart from the new page props and replaces client state, ensuring the displayed data always reflects the server's authoritative state rather than stale client data. The full synchronization logic is visible in #source_code_link("resources/js/Contexts/CartContext.tsx").

===== Type-Safe Context Consumption

Components access context through the custom hooks (e.g., `useCart()`), which enforce type safety and guarantee provider presence. TypeScript verifies that destructured properties exist on the context value, and IDE autocomplete suggests all available methods. If a component renders outside its provider, the hook throws a clear diagnostic error at development time. Usage examples are available in #source_code_link("resources/js/Pages/Customer/Restaurants/Show.tsx").
