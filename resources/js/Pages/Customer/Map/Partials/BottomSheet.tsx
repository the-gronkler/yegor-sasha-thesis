import React, { useRef, useState, useEffect, useLayoutEffect } from 'react';
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import RestaurantCard from '@/Components/Shared/RestaurantCard';
import { Restaurant } from '@/types/models';

/**
 * BottomSheet (UI Component)
 *
 * Responsibilities:
 * - Renders the list of restaurants in a draggable sheet.
 * - Manages drag physics (Pointer Events) and expansion state.
 * - Handles auto-scrolling to the selected restaurant card.
 * - Purely presentational regarding data (receives restaurants as props).
 */
const COLLAPSED_PX = 105; // Minimal height - handle touches bottom nav
const EXPANDED_MAX_PX = 520; // Max expanded height
const EXPANDED_VH = 0.45; // 45vh
const TRANSITION_FALLBACK_TIMEOUT_MS = 300; // slightly longer than our CSS duration (250ms)

interface Props {
  restaurants: Restaurant[];
  selectedRestaurantId: number | null;
  onSelectRestaurant: (id: number | null) => void;
}

export default function BottomSheet({
  restaurants,
  selectedRestaurantId,
  onSelectRestaurant,
}: Props) {
  const sheetContentRef = useRef<HTMLDivElement | null>(null);
  const cardRefs = useRef<Record<number, HTMLDivElement | null>>({});

  const [expandedPx, setExpandedPx] = useState(() =>
    typeof window === 'undefined'
      ? EXPANDED_MAX_PX
      : Math.min(Math.round(window.innerHeight * EXPANDED_VH), EXPANDED_MAX_PX),
  );
  const [sheetHeight, setSheetHeight] = useState<number>(COLLAPSED_PX);
  const [isDragging, setIsDragging] = useState(false);

  // Prevent click-toggle after a drag
  const dragMovedRef = useRef(false);

  // Handle window resize for sheet height
  useEffect(() => {
    const onResize = () => {
      const nextExpanded = Math.min(
        Math.round(window.innerHeight * EXPANDED_VH),
        EXPANDED_MAX_PX,
      );
      setExpandedPx(nextExpanded);

      // Clamp current height into new bounds
      setSheetHeight((h) => Math.max(COLLAPSED_PX, Math.min(h, nextExpanded)));
    };

    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

  const isExpanded = sheetHeight > (COLLAPSED_PX + expandedPx) / 2;

  const toggleSheet = () => {
    // Ignore click if we just dragged
    if (dragMovedRef.current) {
      dragMovedRef.current = false;
      return;
    }
    setSheetHeight((h) => (h <= COLLAPSED_PX + 2 ? expandedPx : COLLAPSED_PX));
  };

  // Calculate offset for transform animation (keep cards at natural size)
  const sheetOffsetPx = Math.max(0, expandedPx - sheetHeight);

  const onHandlePointerDown = (e: React.PointerEvent<HTMLButtonElement>) => {
    e.preventDefault(); // helps on some browsers to avoid accidental scroll/tap behaviors

    const pointerId = e.pointerId;
    e.currentTarget.setPointerCapture(pointerId); // keep receiving events

    dragMovedRef.current = false;

    const startY = e.clientY;
    const startH = sheetHeight;

    setIsDragging(true);

    const onMove = (ev: Event) => {
      const pe = ev as PointerEvent;
      if (pe.pointerId !== pointerId) return; // IMPORTANT: only respond to the active pointer

      const dy = pe.clientY - startY; // Dragging down => dy positive => height decreases
      const next = Math.max(COLLAPSED_PX, Math.min(expandedPx, startH - dy));

      if (Math.abs(dy) > 6) dragMovedRef.current = true;
      setSheetHeight(next);
    };

    const onUp = (ev?: Event) => {
      const pe = ev as PointerEvent | undefined;
      if (pe && pe.pointerId !== pointerId) return; // IMPORTANT: only respond to the active pointer

      setIsDragging(false);

      // Snap to nearest state
      setSheetHeight((h) =>
        h > (COLLAPSED_PX + expandedPx) / 2 ? expandedPx : COLLAPSED_PX,
      );

      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerup', onUp);
      window.removeEventListener('pointercancel', onUp);
    };

    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);
    window.addEventListener('pointercancel', onUp);
  };

  useLayoutEffect(() => {
    if (selectedRestaurantId == null) return;

    let cancelled = false;

    const id = selectedRestaurantId;
    const el = cardRefs.current[id];
    const container = sheetContentRef.current;

    if (!el || !container) return;

    // +-------------+
    // | STEP 1: WAIT |
    // +-------------+

    // Promise that resolves after the CSS transition end
    const waitForTransition = new Promise<void>((resolve) => {
      const handler = (event: TransitionEvent) => {
        // Only respond to padding/min-height/gap transitions
        if (
          event.propertyName.startsWith('padding') ||
          event.propertyName === 'min-height' ||
          event.propertyName === 'gap'
        ) {
          el.removeEventListener('transitionend', handler);
          if (!cancelled) resolve();
        }
      };
      el.addEventListener('transitionend', handler);

      // Fallback timeout (in case no transitionend fires for some reason)
      const timeoutId = setTimeout(() => {
        el.removeEventListener('transitionend', handler);
        if (!cancelled) resolve();
      }, TRANSITION_FALLBACK_TIMEOUT_MS);

      return () => {
        cancelled = true;
        clearTimeout(timeoutId);
        el.removeEventListener('transitionend', handler);
      };
    });

    waitForTransition.then(() => {
      if (cancelled) return;

      // +------------------------+
      // | STEP 2: SCROLL TO VIEW |
      // +------------------------+

      const containerRect = container.getBoundingClientRect();
      const elRect = el.getBoundingClientRect();

      const currentScroll = container.scrollTop;
      const offsetTop = elRect.top - containerRect.top;

      const targetScroll =
        currentScroll +
        offsetTop -
        (containerRect.height / 2 - elRect.height / 2);

      const clamped = Math.max(
        0,
        Math.min(targetScroll, container.scrollHeight - container.clientHeight),
      );

      container.scrollTo({
        top: clamped,
        behavior: 'smooth',
      });
    });

    return () => {
      cancelled = true;
    };
  }, [selectedRestaurantId]);

  return (
    <div
      className={`map-bottom-sheet ${isDragging ? 'is-dragging' : ''} ${isExpanded ? 'is-expanded' : 'is-collapsed'}`}
      style={
        {
          height: `${expandedPx}px`, // constant physical height
          '--sheet-offset': `${sheetOffsetPx}px`, // slide down to "collapse"
        } as React.CSSProperties & { '--sheet-offset': string }
      }
    >
      <button
        type="button"
        className="sheet-handle"
        aria-label={
          isExpanded ? 'Collapse restaurant list' : 'Expand restaurant list'
        }
        aria-expanded={isExpanded}
        aria-controls="restaurants-sheet"
        onClick={toggleSheet}
        onPointerDown={onHandlePointerDown}
      >
        <span className="sheet-handle-bar" aria-hidden="true" />
      </button>

      <div
        id="restaurants-sheet"
        className="sheet-content"
        ref={sheetContentRef}
      >
        {restaurants.length === 0 ? (
          <div className="sheet-empty-state">
            <MagnifyingGlassIcon className="empty-icon" />
            <h2>No restaurants found</h2>
            <p>Try adjusting your search or expanding the radius.</p>
          </div>
        ) : (
          restaurants.map((restaurant) => (
            <RestaurantCard
              key={restaurant.id}
              restaurant={restaurant}
              selected={restaurant.id === selectedRestaurantId}
              onSelect={() => onSelectRestaurant(restaurant.id)}
              containerRef={(el) => (cardRefs.current[restaurant.id] = el)}
            />
          ))
        )}
      </div>
    </div>
  );
}
