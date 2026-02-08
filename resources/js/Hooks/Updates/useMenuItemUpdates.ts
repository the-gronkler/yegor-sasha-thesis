import { useChannelUpdates } from './useChannelUpdates';
import { MenuItem } from '@/types/models';

type MenuItemUpdatedEvent = {
  menuItem: MenuItem;
};

/**
 * Listens for menu item updates on restaurant channels and reloads the page.
 *
 * @param restaurantIds - A single restaurant ID or an array of restaurant IDs to listen to.
 * @param shouldReload - Optional callback to determine if reload should happen based on the event.
 */
export function useMenuItemUpdates(
  restaurantIds: number | number[] | undefined,
  shouldReload?: (event: MenuItemUpdatedEvent) => boolean,
) {
  useChannelUpdates(
    restaurantIds,
    'restaurant',
    ['MenuItemUpdated'],
    shouldReload,
  );
}
