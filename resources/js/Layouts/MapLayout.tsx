import { PropsWithChildren, useEffect } from 'react';
import BottomNav from '@/Components/Shared/BottomNav';

// Global counter to handle multiple MapLayout instances
let mapLayoutCount = 0;

interface MapLayoutProps extends PropsWithChildren {}

export default function MapLayout({ children }: MapLayoutProps) {
  useEffect(() => {
    const html = document.documentElement;
    const body = document.body;

    mapLayoutCount++;
    let prevHtmlOverflow = '';
    let prevBodyOverflow = '';
    let prevHtmlOverscroll = '';
    let prevBodyOverscroll = '';

    if (mapLayoutCount === 1) {
      // Only modify styles when the first instance mounts
      prevHtmlOverflow = html.style.overflow;
      prevBodyOverflow = body.style.overflow;
      prevHtmlOverscroll = html.style.overscrollBehavior;
      prevBodyOverscroll = body.style.overscrollBehavior;

      html.style.overflow = 'hidden';
      body.style.overflow = 'hidden';
      html.style.overscrollBehavior = 'none';
      body.style.overscrollBehavior = 'none';
    }

    return () => {
      mapLayoutCount--;
      if (mapLayoutCount === 0) {
        // Only restore styles when the last instance unmounts
        html.style.overflow = prevHtmlOverflow;
        body.style.overflow = prevBodyOverflow;
        html.style.overscrollBehavior = prevHtmlOverscroll;
        body.style.overscrollBehavior = prevBodyOverscroll;
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
