import { Head, Link } from '@inertiajs/react';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';
import AppLayout from '@/Layouts/AppLayout';
import { Order, PaginatedResponse, User } from '@/types/models';
import { formatDateTime, formatCurrency } from '@/Utils/formatters';
import {
  calculateOrderTotal,
  calculateOrderItemCount,
} from '@/Utils/orderHelpers';
import OrderStatusBadge from '@/Components/Shared/OrderStatusBadge';
import { useUserOrdersUpdates } from '@/Hooks/Updates/useUserOrdersUpdates';

interface Props {
  orders: PaginatedResponse<Order>;
  auth: { user: User };
}

export default function OrdersIndex({ orders, auth }: Props) {
  // Enable live updates for all user's orders
  useUserOrdersUpdates(auth.user.id);

  return (
    <AppLayout>
      <Head title="My Orders" />

      <div className="orders-index">
        <div className="orders-index__header">
          <Link href={route('profile.show')} className="back-button-link">
            <ArrowLeftIcon className="icon" />
            <span>Profile</span>
          </Link>
          <h1>My Orders</h1>
        </div>

        {orders.data.length === 0 ? (
          <div className="orders-index__empty">
            <p>You haven't placed any orders yet.</p>
            <Link href={route('map.index')} className="btn-primary">
              Browse Restaurants
            </Link>
          </div>
        ) : (
          <div className="orders-index__list">
            {orders.data.map((order) => (
              <Link
                href={route('orders.show', order.id)}
                key={order.id}
                className="order-card"
              >
                <div className="order-card__header">
                  <div>
                    <h3 className="order-card__restaurant">
                      {order.restaurant?.name}
                    </h3>
                    <span className="order-card__date">
                      {formatDateTime(order.created_at)}
                    </span>
                  </div>
                  <OrderStatusBadge
                    statusId={order.order_status_id}
                    statusName={order.status?.name}
                  />
                </div>

                <div className="order-card__details">
                  <span className="order-card__items-count">
                    {calculateOrderItemCount(order.menu_items)} items
                  </span>
                  <span className="order-card__total">
                    {formatCurrency(calculateOrderTotal(order.menu_items))}
                  </span>
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>
    </AppLayout>
  );
}
