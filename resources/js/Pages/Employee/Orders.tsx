import { useState } from 'react';
import AppLayout from '@/Layouts/AppLayout';
import { Head, router } from '@inertiajs/react';
import { useRestaurantOrdersUpdates } from '@/Hooks/Updates/useRestaurantOrdersUpdates';
import { formatTime, formatCurrencyUSD } from '@/Utils/formatters';
import { useOrderFilters } from '@/Hooks/useOrderFilters';
import FilterToggleButton from '@/Components/UI/FilterToggleButton';
import OrdersFilterPanel from '@/Components/Shared/OrdersFilterPanel';
import OrdersBoard from '@/Components/Shared/OrdersBoard';
import { OrdersProps } from '@/types/orders';

export default function OrdersIndex({
  ordersByStatus,
  availableStatuses,
  currentFilter,
  defaultActiveStatuses,
  auth,
}: OrdersProps) {
  const [expandedOrderId, setExpandedOrderId] = useState<number | null>(null);

  // Enable live updates for all restaurant orders
  useRestaurantOrdersUpdates(auth.restaurant_id ?? undefined);

  const {
    selectedStatuses,
    showFilters,
    setShowFilters,
    handleFilterChange,
    applyFilter: applyFilterFromHook,
    showActiveOnly: showActiveOnlyFromHook,
    showAllOrders: showAllOrdersFromHook,
    isDefaultFilter,
    isAllOrders,
    filterArray,
  } = useOrderFilters({
    currentFilter,
    defaultActiveStatuses,
    availableStatuses,
    onApplyFilter: (statuses) =>
      router.get(
        route('employee.orders.index'),
        { statuses },
        { preserveScroll: true, preserveState: true },
      ),
    onShowActive: () =>
      router.get(
        route('employee.orders.index'),
        {},
        { preserveScroll: true, preserveState: true },
      ),
    onShowAll: () =>
      router.get(
        route('employee.orders.index'),
        { statuses: 'all' },
        { preserveScroll: true, preserveState: true },
      ),
  });

  const handleStatusChange = (orderId: number, newStatusId: number) => {
    router.put(
      route('employee.restaurant.orders.updateStatus', orderId),
      { order_status_id: newStatusId },
      { preserveScroll: true },
    );
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
            <FilterToggleButton
              onClick={() => setShowFilters(!showFilters)}
              showBadge={!isDefaultFilter}
            />
          </div>

          <OrdersFilterPanel
            showFilters={showFilters}
            onClose={() => setShowFilters(false)}
            selectedStatuses={selectedStatuses}
            onFilterChange={handleFilterChange}
            onApply={applyFilterFromHook}
            onShowActive={showActiveOnlyFromHook}
            onShowAll={showAllOrdersFromHook}
            availableStatuses={availableStatuses}
            isDefaultFilter={isDefaultFilter}
            isAllOrders={isAllOrders}
          />
        </div>

        <OrdersBoard
          ordersByStatus={ordersByStatus}
          availableStatuses={availableStatuses}
          onStatusChange={handleStatusChange}
          expandedOrderId={expandedOrderId}
          onToggleExpand={toggleOrderDetails}
          formatTime={formatTime}
          formatCurrency={formatCurrencyUSD}
          filterArray={filterArray}
        />
      </div>
    </AppLayout>
  );
}
