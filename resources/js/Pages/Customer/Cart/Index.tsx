import { useState, useMemo } from 'react';
import { Head, router, Link } from '@inertiajs/react';
import {
  TrashIcon,
  MinusIcon,
  PlusIcon,
  ChevronRightIcon,
} from '@heroicons/react/24/outline';
import CustomerLayout from '@/Layouts/CustomerLayout';
import { useCart } from '@/Contexts/CartContext';
import { PageProps } from '@/types';
import { Order } from '@/types/models';

interface CartIndexProps extends PageProps {
  cartOrders: Order[];
}

export default function CartIndex({ cartOrders }: CartIndexProps) {
  const { items, totalPrice, updateQuantity, removeItem } = useCart();

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
        items: typeof items;
        notes: string;
      }
    >();

    cartOrders.forEach((order) => {
      if (order.restaurant && order.menu_items) {
        const orderItems = items.filter((item) =>
          order.menu_items?.some((mi) => mi.id === item.id),
        );

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
    // TODO: Implement individual restaurant checkout logic
    // For now, navigate to checkout with order ID
    router.visit(route('orders.checkout', { order: orderId }));
  };

  const handleCheckout = () => {
    // TODO: Implement checkout logic for all restaurants
    router.visit(route('orders.checkout'));
  };

  if (items.length === 0) {
    return (
      <CustomerLayout>
        <Head title="Cart" />
        <div className="cart-page">
          <div className="cart-header">
            <h1>Your Cart</h1>
          </div>
          <div className="empty-cart">
            <p>Your cart is empty</p>
            <Link href={route('restaurants.index')} className="btn-primary">
              Browse Restaurants
            </Link>
          </div>
        </div>
      </CustomerLayout>
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
    <CustomerLayout>
      <Head title="Cart" />
      <div className="cart-page">
        {/* Header */}
        <div className="cart-header">
          <h1>Cart</h1>
          <span className="item-count">
            {items.length} items from {itemsByRestaurant.size} restaurant
            {itemsByRestaurant.size !== 1 ? 's' : ''}
          </span>
        </div>

        {/* Cart Items Grouped by Restaurant */}
        <div className="cart-restaurants">
          {Array.from(itemsByRestaurant.entries()).map(
            ([restaurantId, data], index) => (
              <div key={restaurantId} className="restaurant-section">
                {/* Restaurant Header */}
                <div className="restaurant-header">
                  <Link
                    href={route('restaurants.show', {
                      restaurant: restaurantId,
                    })}
                    className="restaurant-link"
                  >
                    <div className="restaurant-info">
                      <h2 className="restaurant-name">
                        {data.restaurant?.name}
                      </h2>
                      <span className="item-count-small">
                        {data.items.length} item
                        {data.items.length !== 1 ? 's' : ''}
                      </span>
                    </div>
                    <ChevronRightIcon className="chevron-icon" />
                  </Link>
                </div>

                {/* Items from this restaurant */}
                <div className="cart-items">
                  {data.items.map((item) => {
                    const primaryImage =
                      item.images?.find(
                        (img) => img.is_primary_for_menu_item,
                      ) || item.images?.[0];
                    const imageUrl = primaryImage?.url;

                    return (
                      <div key={item.id} className="cart-item">
                        {imageUrl ? (
                          <img
                            src={imageUrl}
                            alt={item.name}
                            className="cart-item-image"
                          />
                        ) : (
                          <div className="cart-item-image placeholder" />
                        )}

                        <div className="cart-item-details">
                          <h3 className="cart-item-name">{item.name}</h3>
                          <p className="cart-item-price">
                            €{item.price.toFixed(2)}
                          </p>

                          {item.description && (
                            <p className="cart-item-description">
                              {item.description}
                            </p>
                          )}
                        </div>

                        <div className="cart-item-actions">
                          <div className="quantity-controls">
                            <button
                              onClick={() =>
                                handleUpdateQuantity(item.id, item.quantity - 1)
                              }
                              className="quantity-btn"
                              aria-label="Decrease quantity"
                            >
                              <MinusIcon className="icon" />
                            </button>
                            <span className="quantity">{item.quantity}</span>
                            <button
                              onClick={() =>
                                handleUpdateQuantity(item.id, item.quantity + 1)
                              }
                              className="quantity-btn"
                              aria-label="Increase quantity"
                            >
                              <PlusIcon className="icon" />
                            </button>
                          </div>

                          <button
                            onClick={() => removeItem(item.id)}
                            className="remove-btn"
                            aria-label={`Remove ${item.name}`}
                          >
                            <TrashIcon className="icon" />
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>

                {/* Notes for this restaurant */}
                <div className="restaurant-notes">
                  <h4 className="notes-title">Special Instructions</h4>
                  <textarea
                    value={notes[restaurantId] ?? data.notes}
                    onChange={(e) =>
                      setNotes((prev) => ({
                        ...prev,
                        [restaurantId]: e.target.value,
                      }))
                    }
                    placeholder={`Add special instructions for ${data.restaurant?.name}...`}
                    className="notes-input"
                    rows={3}
                  />
                  <button
                    onClick={() => handleSaveNotes(data.orderId, restaurantId)}
                    disabled={savingNotes[restaurantId]}
                    className="btn-save-notes"
                  >
                    {savingNotes[restaurantId] ? 'Saving...' : 'Save Notes'}
                  </button>
                </div>

                {/* Subtotal and Checkout for this restaurant */}
                <div className="restaurant-footer">
                  <div className="restaurant-subtotal">
                    <span className="subtotal-label">Subtotal</span>
                    <span className="subtotal-amount">
                      €
                      {restaurantSubtotals.get(restaurantId)?.toFixed(2) ||
                        '0.00'}
                    </span>
                  </div>
                  <button
                    onClick={() => handleRestaurantCheckout(data.orderId)}
                    className="btn-restaurant-checkout"
                  >
                    Checkout {data.restaurant?.name}
                  </button>
                </div>

                {/* Separator (not for last item) */}
                {index < itemsByRestaurant.size - 1 && (
                  <div className="restaurant-separator" />
                )}
              </div>
            ),
          )}
        </div>

        {/* Footer with total and checkout */}
        <div className="cart-footer">
          <div className="cart-total">
            <span className="total-label">Total</span>
            <span className="total-amount">€{totalPrice.toFixed(2)}</span>
          </div>
          <button onClick={handleCheckout} className="btn-checkout">
            Go to checkout
          </button>
        </div>
      </div>
    </CustomerLayout>
  );
}
