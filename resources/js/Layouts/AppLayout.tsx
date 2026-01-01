import { PropsWithChildren } from 'react';
import BottomNav from '@/Components/Shared/BottomNav';

interface CustomerLayoutProps extends PropsWithChildren {}

export default function AppLayout({ children }: CustomerLayoutProps) {
  return (
    <div className="customer-layout">
      <main className="main-content">{children}</main>

      <BottomNav />
    </div>
  );
}
