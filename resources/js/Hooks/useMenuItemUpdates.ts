import { useEffect, useRef } from 'react';
import { router } from '@inertiajs/react';
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
  // Use a ref to track the latest callback to avoid re-subscribing when the function reference changes
  const shouldReloadRef = useRef(shouldReload);
  const reloadTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    shouldReloadRef.current = shouldReload;
  }, [shouldReload]);

  // Normalize IDs to a stable string key to prevent unnecessary re-renders
  // This handles cases where the input switches between single ID and array, or array order changes
  const stableIdsKey = JSON.stringify(
    (Array.isArray(restaurantIds) ? restaurantIds : [restaurantIds])
      .filter((id): id is number => typeof id === 'number' && id > 0)
      .sort((a, b) => a - b),
  );

  useEffect(() => {
    const uniqueIds = JSON.parse(stableIdsKey) as number[];

    if (uniqueIds.length === 0) return;

    uniqueIds.forEach((id) => {
      const channel = window.Echo.channel(`restaurant.${id}`);

      channel.listen('MenuItemUpdated', (event: MenuItemUpdatedEvent) => {
        // Use the ref to access the latest callback
        if (shouldReloadRef.current && !shouldReloadRef.current(event)) {
          return;
        }

        // Debounce the reload to prevent multiple requests from rapid updates
        if (reloadTimeoutRef.current) {
          clearTimeout(reloadTimeoutRef.current);
        }

        reloadTimeoutRef.current = setTimeout(() => {
          router.reload({
            preserveScroll: true,
          });
        }, 200);
      });
    });

    return () => {
      if (reloadTimeoutRef.current) {
        clearTimeout(reloadTimeoutRef.current);
      }
      uniqueIds.forEach((id) => {
        window.Echo.leave(`restaurant.${id}`);
      });
    };
  }, [stableIdsKey]);
}
