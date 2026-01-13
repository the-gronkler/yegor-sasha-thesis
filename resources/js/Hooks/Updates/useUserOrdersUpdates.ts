import { useChannelUpdates } from './useChannelUpdates';
import { Order } from '@/types/models';

type OrderUpdatedEvent = {
  order: Order;
};

/**
 * Listens for order updates for a specific user (all their orders) and reloads the page.
 *
 * @param userId - The user ID to listen for order updates.
 * @param shouldReload - Optional callback to determine if reload should happen based on the event.
 */
export function useUserOrdersUpdates(
  userId: number | undefined,
  shouldReload?: (event: OrderUpdatedEvent) => boolean,
) {
  useChannelUpdates(
    userId ? [userId] : undefined,
    'user',
    ['OrderUpdated'],
    shouldReload,
    true, // Private channel
  );
}
