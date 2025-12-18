import { PropsWithChildren, useEffect } from 'react';
import BottomNav from '@/Components/Shared/BottomNav';

interface MapLayoutProps extends PropsWithChildren {}

export default function MapLayout({ children }: MapLayoutProps) {
  useEffect(() => {
    const html = document.documentElement;
    const body = document.body;

    const prevHtmlOverflow = html.style.overflow;
    const prevBodyOverflow = body.style.overflow;

    html.style.overflow = 'hidden';
    body.style.overflow = 'hidden';

    // optional but helps on mobile “bounce”
    html.style.overscrollBehavior = 'none';
    body.style.overscrollBehavior = 'none';

    return () => {
      html.style.overflow = prevHtmlOverflow;
      body.style.overflow = prevBodyOverflow;
      html.style.overscrollBehavior = '';
      body.style.overscrollBehavior = '';
    };
  }, []);

  return (
    <div className="map-layout">
      <main className="main-content">{children}</main>

      <BottomNav />
    </div>
  );
}
