import { Head, useForm, Link } from '@inertiajs/react';
import AppLayout from '@/Layouts/AppLayout';
import { Order } from '@/types/models';
import { FormEvent } from 'react';

interface CheckoutIndexProps {
  order: Order;
  subtotal: number;
  total: number;
}

export default function CheckoutIndex({
  order,
  subtotal,
  total,
}: CheckoutIndexProps) {
  const { post, processing } = useForm();

  const items = order.menu_items || [];

  if (items.length === 0) {
    return (
      <AppLayout>
        <Head title="Checkout" />
        <div className="checkout-page">
          <div className="checkout-container">
            <div className="empty-checkout">
              <p>This order has no items.</p>
              <Link href={route('restaurants.index')} className="back-link">
                Browse Restaurants
              </Link>
            </div>
          </div>
        </div>
      </AppLayout>
    );
  }

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    post(route('checkout.process', { order: order.id }));
  };

  return (
    <AppLayout>
      <Head title="Checkout" />

      <div className="checkout-page">
        <div className="checkout-container">
          <h1 className="page-title">Checkout</h1>

          <div className="checkout-content">
            <div className="order-summary">
              <h2 className="section-title">Order Summary</h2>
              <div className="restaurant-info">
                <h3>{order.restaurant?.name}</h3>
                <p>{order.restaurant?.address}</p>
              </div>

              <div className="items-list">
                {items.map((item) => (
                  <div key={item.id} className="summary-item">
                    <div className="item-info">
                      <span className="item-quantity">
                        {item.pivot?.quantity}x
                      </span>
                      <span className="item-name">{item.name}</span>
                    </div>
                    <span className="item-price">
                      €{(item.price * (item.pivot?.quantity ?? 1)).toFixed(2)}
                    </span>
                  </div>
                ))}
              </div>

              <div className="cost-breakdown">
                <div className="cost-row">
                  <span>Subtotal</span>
                  <span>€{subtotal.toFixed(2)}</span>
                </div>
                <div className="cost-row total">
                  <span>Total</span>
                  <span>€{total.toFixed(2)}</span>
                </div>
              </div>
            </div>

            <div className="payment-section">
              <h2 className="section-title">Payment</h2>
              <div className="payment-method">
                <p>
                  Payment Method: <strong>Credit Card (Simulated)</strong>
                </p>
              </div>

              <form onSubmit={handleSubmit}>
                <button
                  type="submit"
                  className="pay-button"
                  disabled={processing}
                >
                  {processing ? 'Processing...' : `Pay €${total.toFixed(2)}`}
                </button>
              </form>

              <Link href={route('cart.index')} className="back-link">
                Back to Cart
              </Link>
            </div>
          </div>
        </div>
      </div>
    </AppLayout>
  );
}
