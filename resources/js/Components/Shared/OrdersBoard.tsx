import {
  ClockIcon,
  CheckCircleIcon,
  FireIcon,
  ArchiveBoxIcon,
  XCircleIcon,
  XMarkIcon,
  CheckBadgeIcon,
} from '@heroicons/react/24/outline';
import { OrdersByStatus, AvailableStatus } from '@/types/orders';
import OrderCard from './OrderCard';

interface OrdersBoardProps {
  ordersByStatus: OrdersByStatus;
  availableStatuses: AvailableStatus[];
  onStatusChange: (orderId: number, statusId: number) => void;
  expandedOrderId: number | null;
  onToggleExpand: (orderId: number) => void;
  formatTime: (time: string) => string;
  formatCurrency: (amount: number) => string;
  filterArray: number[];
}

export default function OrdersBoard({
  ordersByStatus,
  availableStatuses,
  onStatusChange,
  expandedOrderId,
  onToggleExpand,
  formatTime,
  formatCurrency,
  filterArray,
}: OrdersBoardProps) {
  return (
    <div className="orders-board">
      {/* New Orders Column */}
      {filterArray.includes(2) && ( // Placed
        <div className="orders-column">
          <div className="column-header column-header-new">
            <ClockIcon className="column-icon" />
            <h2 className="column-title">New Orders</h2>
            <span className="column-count">{ordersByStatus.new.length}</span>
          </div>
          <div className="column-content">
            {ordersByStatus.new.map((order) => (
              <OrderCard
                key={order.id}
                order={order}
                availableStatuses={availableStatuses}
                onStatusChange={onStatusChange}
                isExpanded={expandedOrderId === order.id}
                onToggleExpand={() => onToggleExpand(order.id)}
                formatTime={formatTime}
                formatCurrency={formatCurrency}
              />
            ))}
            {ordersByStatus.new.length === 0 && (
              <div className="empty-column">
                <p>No new orders</p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Accepted Orders Column */}
      {filterArray.includes(3) && ( // Accepted
        <div className="orders-column">
          <div className="column-header column-header-accepted">
            <CheckCircleIcon className="column-icon" />
            <h2 className="column-title">Accepted</h2>
            <span className="column-count">
              {ordersByStatus.accepted.length}
            </span>
          </div>
          <div className="column-content">
            {ordersByStatus.accepted.map((order) => (
              <OrderCard
                key={order.id}
                order={order}
                availableStatuses={availableStatuses}
                onStatusChange={onStatusChange}
                isExpanded={expandedOrderId === order.id}
                onToggleExpand={() => onToggleExpand(order.id)}
                formatTime={formatTime}
                formatCurrency={formatCurrency}
              />
            ))}
            {ordersByStatus.accepted.length === 0 && (
              <div className="empty-column">
                <p>No accepted orders</p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Declined Orders Column */}
      {filterArray.includes(4) && ( // Declined
        <div className="orders-column">
          <div className="column-header column-header-declined">
            <XCircleIcon className="column-icon" />
            <h2 className="column-title">Declined</h2>
            <span className="column-count">
              {ordersByStatus.declined.length}
            </span>
          </div>
          <div className="column-content">
            {ordersByStatus.declined.map((order) => (
              <OrderCard
                key={order.id}
                order={order}
                availableStatuses={availableStatuses}
                onStatusChange={onStatusChange}
                isExpanded={expandedOrderId === order.id}
                onToggleExpand={() => onToggleExpand(order.id)}
                formatTime={formatTime}
                formatCurrency={formatCurrency}
              />
            ))}
            {ordersByStatus.declined.length === 0 && (
              <div className="empty-column">
                <p>No declined orders</p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Preparing Orders Column */}
      {filterArray.includes(5) && ( // Preparing
        <div className="orders-column">
          <div className="column-header column-header-preparing">
            <FireIcon className="column-icon" />
            <h2 className="column-title">Preparing</h2>
            <span className="column-count">
              {ordersByStatus.preparing.length}
            </span>
          </div>
          <div className="column-content">
            {ordersByStatus.preparing.map((order) => (
              <OrderCard
                key={order.id}
                order={order}
                availableStatuses={availableStatuses}
                onStatusChange={onStatusChange}
                isExpanded={expandedOrderId === order.id}
                onToggleExpand={() => onToggleExpand(order.id)}
                formatTime={formatTime}
                formatCurrency={formatCurrency}
              />
            ))}
            {ordersByStatus.preparing.length === 0 && (
              <div className="empty-column">
                <p>No orders in preparation</p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Ready Orders Column */}
      {filterArray.includes(6) && ( // Ready
        <div className="orders-column">
          <div className="column-header column-header-ready">
            <ArchiveBoxIcon className="column-icon" />
            <h2 className="column-title">Ready</h2>
            <span className="column-count">{ordersByStatus.ready.length}</span>
          </div>
          <div className="column-content">
            {ordersByStatus.ready.map((order) => (
              <OrderCard
                key={order.id}
                order={order}
                availableStatuses={availableStatuses}
                onStatusChange={onStatusChange}
                isExpanded={expandedOrderId === order.id}
                onToggleExpand={() => onToggleExpand(order.id)}
                formatTime={formatTime}
                formatCurrency={formatCurrency}
              />
            ))}
            {ordersByStatus.ready.length === 0 && (
              <div className="empty-column">
                <p>No ready orders</p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Cancelled Orders Column */}
      {filterArray.includes(7) && ( // Cancelled
        <div className="orders-column">
          <div className="column-header column-header-cancelled">
            <XMarkIcon className="column-icon" />
            <h2 className="column-title">Cancelled</h2>
            <span className="column-count">
              {ordersByStatus.cancelled.length}
            </span>
          </div>
          <div className="column-content">
            {ordersByStatus.cancelled.map((order) => (
              <OrderCard
                key={order.id}
                order={order}
                availableStatuses={availableStatuses}
                onStatusChange={onStatusChange}
                isExpanded={expandedOrderId === order.id}
                onToggleExpand={() => onToggleExpand(order.id)}
                formatTime={formatTime}
                formatCurrency={formatCurrency}
              />
            ))}
            {ordersByStatus.cancelled.length === 0 && (
              <div className="empty-column">
                <p>No cancelled orders</p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Fulfilled Orders Column */}
      {filterArray.includes(8) && ( // Fulfilled
        <div className="orders-column">
          <div className="column-header column-header-fulfilled">
            <CheckBadgeIcon className="column-icon" />
            <h2 className="column-title">Fulfilled</h2>
            <span className="column-count">
              {ordersByStatus.fulfilled.length}
            </span>
          </div>
          <div className="column-content">
            {ordersByStatus.fulfilled.map((order) => (
              <OrderCard
                key={order.id}
                order={order}
                availableStatuses={availableStatuses}
                onStatusChange={onStatusChange}
                isExpanded={expandedOrderId === order.id}
                onToggleExpand={() => onToggleExpand(order.id)}
                formatTime={formatTime}
                formatCurrency={formatCurrency}
              />
            ))}
            {ordersByStatus.fulfilled.length === 0 && (
              <div className="empty-column">
                <p>No fulfilled orders</p>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
