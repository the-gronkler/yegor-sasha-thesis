import { useState, useEffect, useMemo } from 'react';
import { OrdersByStatus, AvailableStatus } from '@/types/orders';

// Status ID to group name mapping
// TODO: Consider deriving this from availableStatuses if statuses become dynamic
const statusIdToGroup: Record<number, keyof OrdersByStatus> = {
  2: 'new',
  3: 'accepted',
  4: 'declined',
  5: 'preparing',
  6: 'ready',
  7: 'cancelled',
  8: 'fulfilled',
};

interface UseOptimisticOrderStatusUpdatesProps {
  ordersByStatus: OrdersByStatus;
  availableStatuses: AvailableStatus[];
  onStatusUpdate: (
    orderId: number,
    newStatusId: number,
    onSuccess: () => void,
    onError: () => void,
  ) => void;
}

export const useOptimisticOrderStatusUpdates = ({
  ordersByStatus,
  availableStatuses,
  onStatusUpdate,
}: UseOptimisticOrderStatusUpdatesProps) => {
  const [statusOverrides, setStatusOverrides] = useState<Map<number, number>>(
    new Map(),
  );

  // Flatten all orders from the grouped structure
  const allOrders = useMemo(
    () => Object.values(ordersByStatus).flat(),
    [ordersByStatus],
  );

  // Clear overrides when server data updates (e.g., from broadcasts)
  useEffect(() => {
    setStatusOverrides((prev) => {
      const newMap = new Map(prev);
      // Only clear overrides for orders that now match the server status
      prev.forEach((optimisticStatusId, orderId) => {
        const serverOrder = allOrders.find((order) => order.id === orderId);
        if (serverOrder && serverOrder.status_id === optimisticStatusId) {
          newMap.delete(orderId);
        }
      });
      return newMap;
    });
  }, [ordersByStatus, allOrders]);

  // Status ID to status name mapping
  const statusIdToName = useMemo(
    () => new Map(availableStatuses.map((s) => [s.id, s.name])),
    [availableStatuses],
  );

  // Compute displayed orders with optimistic updates applied
  const displayedOrdersByStatus = useMemo(() => {
    const grouped: OrdersByStatus = {
      new: [],
      accepted: [],
      declined: [],
      preparing: [],
      ready: [],
      cancelled: [],
      fulfilled: [],
    };

    allOrders.forEach((order) => {
      const statusId = statusOverrides.get(order.id) ?? order.status_id;
      const group =
        statusIdToGroup[statusId] ?? statusIdToGroup[order.status_id];
      const statusName = statusIdToName.get(statusId) ?? order.status_name;

      // Skip orders with completely unknown status IDs to avoid runtime errors
      if (!group) {
        return;
      }

      grouped[group].push({
        ...order,
        status_id: statusId,
        status_name: statusName,
      });
    });

    return grouped;
  }, [allOrders, statusOverrides, statusIdToName]);

  const handleStatusChange = (orderId: number, newStatusId: number) => {
    // Apply optimistic update immediately
    setStatusOverrides((prev) => new Map(prev).set(orderId, newStatusId));

    onStatusUpdate(
      orderId,
      newStatusId,
      () => {
        // Clear the optimistic override on success
        setStatusOverrides((prev) => {
          const newMap = new Map(prev);
          newMap.delete(orderId);
          return newMap;
        });
      },
      () => {
        // Revert the optimistic update on error
        setStatusOverrides((prev) => {
          const newMap = new Map(prev);
          newMap.delete(orderId);
          return newMap;
        });
      },
    );
  };

  return { displayedOrdersByStatus, handleStatusChange };
};
