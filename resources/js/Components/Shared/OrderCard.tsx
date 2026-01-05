import { UserIcon } from '@heroicons/react/24/outline';
import { Order, AvailableStatus } from '@/types/orders';

interface OrderCardProps {
  order: Order;
  availableStatuses: AvailableStatus[];
  onStatusChange: (orderId: number, statusId: number) => void;
  isExpanded: boolean;
  onToggleExpand: () => void;
  formatTime: (time: string) => string;
  formatCurrency: (amount: number) => string;
}

export default function OrderCard({
  order,
  availableStatuses,
  onStatusChange,
  isExpanded,
  onToggleExpand,
  formatTime,
  formatCurrency,
}: OrderCardProps) {
  return (
    <div className="order-card">
      <div className="order-card-header" onClick={onToggleExpand}>
        <div className="order-info">
          <div className="order-customer">
            <UserIcon className="customer-icon" />
            <span className="customer-name">{order.customer_name}</span>
          </div>
          <div className="order-time">{formatTime(order.time_placed)}</div>
        </div>
        <div className="order-total">{formatCurrency(order.total)}</div>
      </div>

      {isExpanded && (
        <div className="order-card-body">
          <div className="order-items">
            <h4 className="items-title">Items:</h4>
            {order.items.map((item) => (
              <div key={item.id} className="order-item">
                <span className="item-quantity">{item.quantity}x</span>
                <span className="item-name">{item.name}</span>
                <span className="item-price">
                  {formatCurrency(item.price * item.quantity)}
                </span>
              </div>
            ))}
          </div>

          {order.notes && (
            <div className="order-notes">
              <h4 className="notes-title">Notes:</h4>
              <p className="notes-text">{order.notes}</p>
            </div>
          )}

          <div className="order-actions">
            <label htmlFor={`status-${order.id}`} className="status-label">
              Update Status:
            </label>
            <select
              id={`status-${order.id}`}
              className="status-select"
              value={order.status_id}
              onChange={(e) =>
                onStatusChange(order.id, parseInt(e.target.value))
              }
            >
              {availableStatuses.map((status) => (
                <option key={status.id} value={status.id}>
                  {status.name}
                </option>
              ))}
            </select>
          </div>
        </div>
      )}
    </div>
  );
}
