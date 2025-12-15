import { Head, Link } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout';
import { Order, PaginatedResponse, OrderStatusEnum } from '@/types/models';

interface Props {
  orders: PaginatedResponse<Order>;
}

export default function OrdersIndex({ orders }: Props) {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit',
    });
  };

  const getStatusClass = (statusId: number) => {
    let suffix: string;
    switch (statusId) {
      case OrderStatusEnum.Placed:
      case OrderStatusEnum.Accepted:
        suffix = 'pending';
        break;
      case OrderStatusEnum.Preparing:
        suffix = 'preparing';
        break;
      case OrderStatusEnum.Ready:
      case OrderStatusEnum.Fulfilled:
        suffix = 'ready';
        break;
      case OrderStatusEnum.Cancelled:
      case OrderStatusEnum.Declined:
        suffix = 'cancelled';
        break;
      default:
        suffix = 'completed';
    }
    return `order-card__status--${suffix}`;
  };

  const calculateTotal = (order: Order) => {
    if (!order.menu_items) return 0;
    return order.menu_items.reduce((sum, item) => {
      const quantity = item.pivot?.quantity || 0;
      return sum + item.price * quantity;
    }, 0);
  };

  const calculateItemCount = (order: Order) => {
    if (!order.menu_items) return 0;
    return order.menu_items.reduce((sum, item) => {
      return sum + (item.pivot?.quantity || 0);
    }, 0);
  };

  return (
    <CustomerLayout>
      <Head title="My Orders" />

      <div className="orders-index">
        <div className="orders-index__header">
          <h1>My Orders</h1>
        </div>

        {orders.data.length === 0 ? (
          <div className="orders-index__empty">
            <p>You haven't placed any orders yet.</p>
            <Link href={route('restaurants.index')} className="btn-primary">
              Browse Restaurants
            </Link>
          </div>
        ) : (
          <div className="orders-index__list">
            {orders.data.map((order) => (
              <div key={order.id} className="order-card">
                <div className="order-card__header">
                  <div>
                    <h3 className="order-card__restaurant">
                      {order.restaurant?.name}
                    </h3>
                    <span className="order-card__date">
                      {formatDate(order.created_at)}
                    </span>
                  </div>
                  <span
                    className={`order-card__status ${getStatusClass(
                      order.order_status_id,
                    )}`}
                  >
                    {order.status?.name}
                  </span>
                </div>

                <div className="order-card__details">
                  <span className="order-card__items-count">
                    {calculateItemCount(order)} items
                  </span>
                  <span className="order-card__total">
                    €{calculateTotal(order).toFixed(2)}
                  </span>
                </div>

                {/* Future feature: View Order Details */}
                {/* <div className="order-card__actions">
                    <Link href={route('orders.show', order.id)} className="order-card__view-btn">
                        View Details
                    </Link>
                </div> */}
              </div>
            ))}
          </div>
        )}
      </div>
    </CustomerLayout>
  );
}
