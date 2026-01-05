import { useChannelUpdates } from './useChannelUpdates';
import { Order } from '@/types/models';

type OrderUpdatedEvent = {
  order: Order;
};

/**
 * Listens for updates on order channels and reloads the page.
 *
 * @param orderIds - A single order ID or an array of order IDs to listen to.
 * @param shouldReload - Optional callback to determine if reload should happen based on the event.
 */
export function useOrderUpdates(
  orderIds: number | number[] | undefined,
  shouldReload?: (event: OrderUpdatedEvent) => boolean,
) {
  useChannelUpdates(orderIds, 'order', ['OrderUpdated'], shouldReload);
}
