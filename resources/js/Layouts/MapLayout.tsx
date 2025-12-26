import { PropsWithChildren, useEffect, useRef } from 'react';
import BottomNav from '@/Components/Shared/BottomNav';

interface MapLayoutProps extends PropsWithChildren {}

/**
 * MapLayout component that prevents body scroll when active.
 *
 * Toggles 'is-map-active' class on html/body to handle overflow via CSS.
 */
export default function MapLayout({ children }: MapLayoutProps) {
  useEffect(() => {
    const html = document.documentElement;
    const body = document.body;

    // Apply class to prevent scroll
    html.classList.add('is-map-active');
    body.classList.add('is-map-active');

    return () => {
      // Remove class on unmount
      html.classList.remove('is-map-active');
      body.classList.remove('is-map-active');
    };
  }, []);

  return (
    <div className="map-layout">
      <main className="main-content">{children}</main>

      <BottomNav />
    </div>
  );
}
