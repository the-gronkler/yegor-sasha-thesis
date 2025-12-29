import { Head, Link } from '@inertiajs/react';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';
import CustomerLayout from '@/Layouts/CustomerLayout';
import { Order, PaginatedResponse } from '@/types/models';
import { formatDateTime, formatCurrency } from '@/Utils/formatters';
import {
  calculateOrderTotal,
  calculateOrderItemCount,
} from '@/Utils/orderHelpers';
import OrderStatusBadge from '@/Components/Shared/OrderStatusBadge';

interface Props {
  orders: PaginatedResponse<Order>;
}

export default function OrdersIndex({ orders }: Props) {
  return (
    <CustomerLayout>
      <Head title="My Orders" />

      <div className="orders-index">
        <div className="orders-index__header">
          <Link href={route('profile.show')} className="back-button-link">
            <ArrowLeftIcon className="icon" />
            <span>Back</span>
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
    </CustomerLayout>
  );
}
