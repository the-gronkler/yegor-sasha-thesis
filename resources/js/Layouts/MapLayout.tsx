import { PropsWithChildren } from 'react';
import BottomNav from '@/Components/Shared/BottomNav';

interface MapLayoutProps extends PropsWithChildren {}

export default function MapLayout({ children }: MapLayoutProps) {
  return (
    <div className="map-layout">
      <main className="main-content">{children}</main>

      <BottomNav />
    </div>
  );
}
