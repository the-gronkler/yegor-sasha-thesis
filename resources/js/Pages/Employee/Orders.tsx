import { useState, useEffect, useMemo } from 'react';
import AppLayout from '@/Layouts/AppLayout';
import { Head, router } from '@inertiajs/react';
import {
  ClockIcon,
  CheckCircleIcon,
  FireIcon,
  ArchiveBoxIcon,
  UserIcon,
  FunnelIcon,
  XCircleIcon,
  XMarkIcon,
  CheckBadgeIcon,
} from '@heroicons/react/24/outline';
import { PageProps } from '@/types';
import { useRestaurantOrdersUpdates } from '@/Hooks/Updates/useRestaurantOrdersUpdates';

interface OrderItem {
  id: number;
  name: string;
  quantity: number;
  price: number;
}

interface Order {
  id: number;
  customer_name: string;
  customer_email: string;
  status_id: number;
  status_name: string;
  time_placed: string;
  notes: string | null;
  items: OrderItem[];
  total: number;
}

interface OrdersByStatus {
  new: Order[];
  accepted: Order[];
  declined: Order[];
  preparing: Order[];
  ready: Order[];
  cancelled: Order[];
  fulfilled: Order[];
}

interface AvailableStatus {
  id: number;
  name: string;
  isActive: boolean;
}

interface OrdersProps extends PageProps {
  orders: Order[];
  ordersByStatus: OrdersByStatus;
  availableStatuses: AvailableStatus[];
  currentFilter: number[];
  defaultActiveStatuses: number[];
}

export default function OrdersIndex({
  ordersByStatus,
  availableStatuses,
  currentFilter,
  defaultActiveStatuses,
  auth,
}: OrdersProps) {
  const [expandedOrderId, setExpandedOrderId] = useState<number | null>(null);
  const [showFilters, setShowFilters] = useState(false);

  // Enable live updates for all restaurant orders
  useRestaurantOrdersUpdates(auth.user.restaurant_id);

  // Ensure currentFilter is always an array (safety check)
  const filterArray = Array.isArray(currentFilter) ? currentFilter : [];

  // Create a stable reference for the filter array
  const filterKey = useMemo(
    () => [...filterArray].sort((a, b) => a - b).join(','),
    [filterArray.join(',')],
  );

  const [selectedStatuses, setSelectedStatuses] =
    useState<number[]>(filterArray);

  // Sync selectedStatuses with currentFilter when it changes (from server response)
  useEffect(() => {
    setSelectedStatuses(filterArray);
  }, [filterKey]);

  // Create stable keys for filter comparisons
  const defaultFilterKey = useMemo(
    () => [...defaultActiveStatuses].sort((a, b) => a - b).join(','),
    [defaultActiveStatuses.join(',')],
  );

  const allStatusIds = useMemo(
    () => availableStatuses.map((s) => s.id),
    [availableStatuses.length],
  );

  const allStatusKey = useMemo(
    () => [...allStatusIds].sort((a, b) => a - b).join(','),
    [allStatusIds.join(',')],
  );

  const isDefaultFilter = filterKey === defaultFilterKey;
  const isAllOrders = filterKey === allStatusKey;

  const handleStatusChange = (orderId: number, newStatusId: number) => {
    router.put(
      route('employee.restaurant.orders.updateStatus', orderId),
      { order_status_id: newStatusId },
      { preserveScroll: true },
    );
  };

  const handleFilterChange = (statusId: number) => {
    const newStatuses = selectedStatuses.includes(statusId)
      ? selectedStatuses.filter((id) => id !== statusId)
      : [...selectedStatuses, statusId];

    setSelectedStatuses(newStatuses);
  };

  const applyFilter = () => {
    router.get(
      route('employee.orders.index'),
      { statuses: selectedStatuses },
      { preserveScroll: true, preserveState: true },
    );
    setShowFilters(false);
  };

  const showActiveOnly = () => {
    // Update checkboxes to match active statuses
    setSelectedStatuses(defaultActiveStatuses);
    router.get(
      route('employee.orders.index'),
      {},
      { preserveScroll: true, preserveState: true },
    );
    setShowFilters(false);
  };

  const showAllOrders = () => {
    // Update checkboxes to select all statuses
    setSelectedStatuses(allStatusIds);
    router.get(
      route('employee.orders.index'),
      { statuses: 'all' },
      { preserveScroll: true, preserveState: true },
    );
    setShowFilters(false);
  };

  const formatTime = (timeString: string) => {
    const date = new Date(timeString);
    return date.toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const toggleOrderDetails = (orderId: number) => {
    setExpandedOrderId(expandedOrderId === orderId ? null : orderId);
  };

  return (
    <AppLayout>
      <Head title="Orders" />

      <div className="orders-page">
        {/* Header */}
        <div className="orders-header">
          <div className="header-content">
            <div className="header-text">
              <h1 className="orders-title">Orders</h1>
              <p className="orders-subtitle">
                Manage incoming orders and update their status
              </p>
            </div>
            <button
              type="button"
              onClick={() => setShowFilters(!showFilters)}
              className="filter-toggle-btn"
            >
              <FunnelIcon className="filter-icon" />
              <span>Filter</span>
              {!isDefaultFilter && <span className="filter-badge">•</span>}
            </button>
          </div>

          {/* Filter Panel */}
          {showFilters && (
            <div className="filter-panel">
              <div className="filter-header">
                <h3 className="filter-title">Filter Orders</h3>
              </div>

              <div className="filter-quick-actions">
                <button
                  type="button"
                  onClick={showActiveOnly}
                  className={`filter-quick-btn ${isDefaultFilter ? 'active' : ''}`}
                >
                  Active Orders
                </button>
                <button
                  type="button"
                  onClick={showAllOrders}
                  className={`filter-quick-btn ${isAllOrders ? 'active' : ''}`}
                >
                  All Orders
                </button>
              </div>

              <div className="filter-statuses">
                <p className="filter-label">Or select specific statuses:</p>
                {availableStatuses.map((status) => (
                  <label key={status.id} className="filter-checkbox">
                    <input
                      type="checkbox"
                      checked={selectedStatuses.includes(status.id)}
                      onChange={() => handleFilterChange(status.id)}
                    />
                    <span className="checkbox-label">{status.name}</span>
                    {status.isActive && (
                      <span className="active-indicator">(Active)</span>
                    )}
                  </label>
                ))}
              </div>

              <div className="filter-actions">
                <button
                  type="button"
                  onClick={() => setShowFilters(false)}
                  className="btn-secondary"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={applyFilter}
                  className="btn-primary"
                  disabled={selectedStatuses.length === 0}
                >
                  Apply Filter
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Orders Board */}
        <div className="orders-board">
          {/* New Orders Column */}
          {filterArray.includes(2) && ( // Placed
            <div className="orders-column">
              <div className="column-header column-header-new">
                <ClockIcon className="column-icon" />
                <h2 className="column-title">New Orders</h2>
                <span className="column-count">
                  {ordersByStatus.new.length}
                </span>
              </div>
              <div className="column-content">
                {ordersByStatus.new.map((order) => (
                  <OrderCard
                    key={order.id}
                    order={order}
                    availableStatuses={availableStatuses}
                    onStatusChange={handleStatusChange}
                    isExpanded={expandedOrderId === order.id}
                    onToggleExpand={() => toggleOrderDetails(order.id)}
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
                    onStatusChange={handleStatusChange}
                    isExpanded={expandedOrderId === order.id}
                    onToggleExpand={() => toggleOrderDetails(order.id)}
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
                    onStatusChange={handleStatusChange}
                    isExpanded={expandedOrderId === order.id}
                    onToggleExpand={() => toggleOrderDetails(order.id)}
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
                    onStatusChange={handleStatusChange}
                    isExpanded={expandedOrderId === order.id}
                    onToggleExpand={() => toggleOrderDetails(order.id)}
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
                <span className="column-count">
                  {ordersByStatus.ready.length}
                </span>
              </div>
              <div className="column-content">
                {ordersByStatus.ready.map((order) => (
                  <OrderCard
                    key={order.id}
                    order={order}
                    availableStatuses={availableStatuses}
                    onStatusChange={handleStatusChange}
                    isExpanded={expandedOrderId === order.id}
                    onToggleExpand={() => toggleOrderDetails(order.id)}
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
                    onStatusChange={handleStatusChange}
                    isExpanded={expandedOrderId === order.id}
                    onToggleExpand={() => toggleOrderDetails(order.id)}
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
                    onStatusChange={handleStatusChange}
                    isExpanded={expandedOrderId === order.id}
                    onToggleExpand={() => toggleOrderDetails(order.id)}
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
      </div>
    </AppLayout>
  );
}

// Order Card Component
interface OrderCardProps {
  order: Order;
  availableStatuses: AvailableStatus[];
  onStatusChange: (orderId: number, statusId: number) => void;
  isExpanded: boolean;
  onToggleExpand: () => void;
  formatTime: (time: string) => string;
  formatCurrency: (amount: number) => string;
}

function OrderCard({
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
