import { useState, useMemo } from 'react';
import { Head, router, Link } from '@inertiajs/react';
import AppLayout from '@/Layouts/AppLayout';
import { useCart } from '@/Contexts/CartContext';
import { PageProps } from '@/types';
import { Order } from '@/types/models';
import CartRestaurantSection from '@/Components/Shared/CartRestaurantSection';
import { CartItemType } from '@/Components/Shared/CartItem';
import { useMenuItemUpdates } from '@/Hooks/Updates/useMenuItemUpdates';

interface CartIndexProps extends PageProps {
  cartOrders: Order[];
}

export default function CartIndex({ cartOrders }: CartIndexProps) {
  const { items, itemCount, totalPrice, updateQuantity, removeItem } =
    useCart();

  const restaurantIds = useMemo(
    () =>
      cartOrders
        .map((o) => o.restaurant?.id)
        .filter((id): id is number => id !== undefined && id !== null),
    [cartOrders],
  );
  useMenuItemUpdates(restaurantIds);

  // Initialize notes with saved notes from orders
  const [notes, setNotes] = useState<Record<number, string>>(() => {
    const initialNotes: Record<number, string> = {};
    cartOrders.forEach((order) => {
      if (order.restaurant && order.notes) {
        initialNotes[order.restaurant.id] = order.notes;
      }
    });
    return initialNotes;
  });

  const [savingNotes, setSavingNotes] = useState<Record<number, boolean>>({});

  // Group items by restaurant
  const itemsByRestaurant = useMemo(() => {
    const grouped = new Map<
      number,
      {
        restaurant: Order['restaurant'];
        orderId: number;
        items: CartItemType[];
        notes: string;
      }
    >();

    cartOrders.forEach((order) => {
      if (order.restaurant && order.menu_items) {
        const orderItems = items.filter((item) =>
          order.menu_items?.some((mi) => mi.id === item.id),
        ) as CartItemType[];

        if (orderItems.length > 0) {
          grouped.set(order.restaurant.id, {
            restaurant: order.restaurant,
            orderId: order.id,
            items: orderItems,
            notes: order.notes || '',
          });
        }
      }
    });

    return grouped;
  }, [cartOrders, items]);

  const handleUpdateQuantity = (itemId: number, newQuantity: number) => {
    if (newQuantity < 1) {
      removeItem(itemId);
    } else {
      updateQuantity(itemId, newQuantity);
    }
  };

  const handleSaveNotes = (orderId: number, restaurantId: number) => {
    const noteText = notes[restaurantId] || '';

    setSavingNotes((prev) => ({ ...prev, [restaurantId]: true }));
    router.post(
      route('cart.addNote', { order: orderId }),
      {
        _method: 'PUT',
        notes: noteText,
      },
      {
        preserveScroll: true,
        onFinish: () => {
          setSavingNotes((prev) => ({ ...prev, [restaurantId]: false }));
        },
      },
    );
  };

  const handleRestaurantCheckout = (orderId: number) => {
    router.visit(route('checkout.show', { order: orderId }));
  };

  if (items.length === 0) {
    return (
      <AppLayout>
        <Head title="Cart" />
        <div className="cart-page">
          <div className="cart-header">
            <h1>Your Cart</h1>
          </div>
          <div className="empty-cart">
            <p>Your cart is empty</p>
            <Link href={route('map.index')} className="btn-primary">
              Browse Restaurants
            </Link>
          </div>
        </div>
      </AppLayout>
    );
  }

  // Calculate subtotals per restaurant
  const restaurantSubtotals = new Map<number, number>();
  itemsByRestaurant.forEach((data, restaurantId) => {
    const subtotal = data.items.reduce(
      (sum, item) => sum + item.price * item.quantity,
      0,
    );
    restaurantSubtotals.set(restaurantId, subtotal);
  });

  return (
    <AppLayout>
      <Head title="Cart" />
      <div className="cart-page">
        {/* Header */}
        <div className="cart-header">
          <h1>Cart</h1>
          <span className="item-count">
            {itemCount} {itemCount !== 1 ? 'items' : 'item'} from{' '}
            {itemsByRestaurant.size} restaurant
            {itemsByRestaurant.size !== 1 ? 's' : ''}
          </span>
        </div>

        {/* Cart Items Grouped by Restaurant */}
        <div className="cart-restaurants">
          {Array.from(itemsByRestaurant.entries()).map(
            ([restaurantId, data], index) => (
              <div key={restaurantId}>
                <CartRestaurantSection
                  restaurant={data.restaurant!}
                  orderId={data.orderId}
                  items={data.items}
                  subtotal={restaurantSubtotals.get(restaurantId) || 0}
                  isSavingNotes={savingNotes[restaurantId] || false}
                  currentNotes={
                    notes[restaurantId] !== undefined
                      ? notes[restaurantId]
                      : data.notes
                  }
                  onUpdateQuantity={handleUpdateQuantity}
                  onRemoveItem={removeItem}
                  onSaveNotes={() =>
                    handleSaveNotes(data.orderId, restaurantId)
                  }
                  onCheckout={handleRestaurantCheckout}
                  onNotesChange={(rId, val) =>
                    setNotes((prev) => ({ ...prev, [rId]: val }))
                  }
                />
                {/* Separator (not for last item) */}
                {index < itemsByRestaurant.size - 1 && (
                  <div className="restaurant-separator" />
                )}
              </div>
            ),
          )}
        </div>

        {/* Footer with total and checkout */}
        {/* <div className="cart-footer">
          <div className="cart-total">
            <span className="total-label">Total</span>
            <span className="total-amount">€{totalPrice.toFixed(2)}</span>
          </div>
          <button onClick={handleCheckout} className="btn-checkout">
            Go to checkout
          </button>
        </div> */}
      </div>
    </AppLayout>
  );
}
