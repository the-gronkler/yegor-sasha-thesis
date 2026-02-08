import { useEffect, useRef } from 'react';
import { router } from '@inertiajs/react';

/**
 * Generic hook for listening to broadcast updates on channels.
 *
 * @param ids - A single ID or an array of IDs to listen to.
 * @param channelPrefix - The prefix for the channel name (e.g., 'restaurant', 'order').
 * @param eventNames - The names of the events to listen for.
 * @param shouldReload - Optional callback to determine if reload should happen based on the event.
 * @param isPrivate - Whether to use a private channel (requires auth). Defaults to false (public).
 */
export function useChannelUpdates<T>(
  ids: number | number[] | undefined,
  channelPrefix: string,
  eventNames: string[],
  shouldReload?: (event: T) => boolean,
  isPrivate: boolean = false,
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
    (Array.isArray(ids) ? ids : [ids])
      .filter((id): id is number => typeof id === 'number' && id > 0)
      .sort((a, b) => a - b),
  );

  useEffect(() => {
    const uniqueIds = JSON.parse(stableIdsKey) as number[];

    if (uniqueIds.length === 0) return;

    if (!window.Echo) {
      console.warn('Echo is not available. Skipping channel updates.');
      return;
    }

    uniqueIds.forEach((id) => {
      const channelName = `${channelPrefix}.${id}`;
      const channel = isPrivate
        ? window.Echo.private(channelName)
        : window.Echo.channel(channelName);

      eventNames.forEach((eventName) => {
        channel.listen(eventName, (event: T) => {
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
    });

    return () => {
      if (reloadTimeoutRef.current) {
        clearTimeout(reloadTimeoutRef.current);
      }
      uniqueIds.forEach((id) => {
        window.Echo.leave(`${channelPrefix}.${id}`);
      });
    };
  }, [stableIdsKey, channelPrefix, isPrivate, ...eventNames]);
}
