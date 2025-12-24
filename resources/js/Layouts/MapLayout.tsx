import { PropsWithChildren, useEffect, useRef } from 'react';
import BottomNav from '@/Components/Shared/BottomNav';

interface MapLayoutProps extends PropsWithChildren {}

/**
 * MapLayout component that prevents body scroll when active.
 *
 * Uses a ref-based instance counter instead of module-level globals
 * to avoid HMR issues and ensure proper cleanup per application instance.
 */
export default function MapLayout({ children }: MapLayoutProps) {
  // Track if this instance has applied overflow styles
  const hasAppliedStyles = useRef(false);

  // Store original styles to restore on unmount
  const originalStyles = useRef<{
    htmlOverflow: string;
    bodyOverflow: string;
    htmlOverscroll: string;
    bodyOverscroll: string;
  } | null>(null);

  useEffect(() => {
    const html = document.documentElement;
    const body = document.body;

    // Store original styles before modifying
    originalStyles.current = {
      htmlOverflow: html.style.overflow,
      bodyOverflow: body.style.overflow,
      htmlOverscroll: html.style.overscrollBehavior,
      bodyOverscroll: body.style.overscrollBehavior,
    };

    // Apply overflow hidden to prevent body scroll on map page
    html.style.overflow = 'hidden';
    body.style.overflow = 'hidden';
    html.style.overscrollBehavior = 'none';
    body.style.overscrollBehavior = 'none';

    hasAppliedStyles.current = true;

    return () => {
      // Restore original styles on unmount
      if (hasAppliedStyles.current && originalStyles.current) {
        html.style.overflow = originalStyles.current.htmlOverflow;
        body.style.overflow = originalStyles.current.bodyOverflow;
        html.style.overscrollBehavior = originalStyles.current.htmlOverscroll;
        body.style.overscrollBehavior = originalStyles.current.bodyOverscroll;

        hasAppliedStyles.current = false;
      }
    };
  }, []);

  return (
    <div className="map-layout">
      <main className="main-content">{children}</main>

      <BottomNav />
    </div>
  );
}
