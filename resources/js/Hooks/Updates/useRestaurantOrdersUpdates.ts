import { useChannelUpdates } from './useChannelUpdates';
import { Order } from '@/types/models';

type OrderUpdatedEvent = {
  order: Order;
};

/**
 * Listens for order updates for a specific restaurant (all orders for that restaurant) and reloads the page.
 *
 * @param restaurantId - The restaurant ID to listen for order updates.
 * @param shouldReload - Optional callback to determine if reload should happen based on the event.
 */
export function useRestaurantOrdersUpdates(
  restaurantId: number | undefined,
  shouldReload?: (event: OrderUpdatedEvent) => boolean,
) {
  useChannelUpdates(
    restaurantId ? [restaurantId] : undefined,
    'restaurant',
    ['OrderUpdated'],
    shouldReload,
    true, // Private channel
  );
}
