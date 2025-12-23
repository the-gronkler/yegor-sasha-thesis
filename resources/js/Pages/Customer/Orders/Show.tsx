import { Head, Link } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout';
import { Order } from '@/types/models';
import { PageProps } from '@/types';
import { formatDateTime, formatCurrency } from '@/Utils/formatters';
import { calculateOrderTotal } from '@/Utils/orderHelpers';
import OrderStatusBadge from '@/Components/Shared/OrderStatusBadge';

interface OrderShowProps extends PageProps {
  order: Order;
}

export default function OrderShow({ order }: OrderShowProps) {
  const total = calculateOrderTotal(order.menu_items);

  return (
    <CustomerLayout>
      <Head title={`Order #${order.id}`} />

      <div className="order-show-page">
        <div className="page-header">
          <h1 className="page-title">Order #{order.id}</h1>
          <p className="order-date">{formatDateTime(order.created_at)}</p>
        </div>

        <div className="order-status-card">
          <span className="status-label">Status</span>
          <OrderStatusBadge
            statusId={order.order_status_id}
            statusName={order.status?.name}
          />
        </div>

        {order.restaurant && (
          <div className="restaurant-section">
            <h2 className="section-title">Restaurant</h2>
            <Link
              href={route('restaurants.show', order.restaurant.id)}
              className="restaurant-card"
            >
              <div className="restaurant-info">
                <h3 className="restaurant-name">{order.restaurant.name}</h3>
                <span className="view-menu-link">View Menu</span>
              </div>
            </Link>
          </div>
        )}

        <div className="order-items-section">
          <h2 className="section-title">Items</h2>
          <div className="order-items-list">
            {order.menu_items?.map((item) => (
              <div key={item.id} className="order-item">
                <span className="item-quantity">{item.pivot?.quantity}x</span>
                <div className="item-details">
                  <div className="item-name">{item.name}</div>
                  <div className="item-price">{formatCurrency(item.price)}</div>
                </div>
                <div className="item-total">
                  {formatCurrency(item.price * (item.pivot?.quantity || 0))}
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="order-summary-section">
          <div className="summary-row">
            <span>Subtotal</span>
            <span>{formatCurrency(total)}</span>
          </div>
          <div className="summary-row total">
            <span>Total</span>
            <span>{formatCurrency(total)}</span>
          </div>
        </div>

        <div className="back-button-container">
          <Link href={route('orders.index')} className="btn-secondary">
            Back to Orders
          </Link>
        </div>
      </div>
    </CustomerLayout>
  );
}
