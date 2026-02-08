import { PropsWithChildren } from 'react';
import BottomNav from '@/Components/Shared/BottomNav';
import Toast from '@/Components/UI/Toast';

interface AppLayoutProps extends PropsWithChildren {}

export default function AppLayout({ children }: AppLayoutProps) {
  return (
    <div className="customer-layout">
      <main className="main-content">{children}</main>

      <BottomNav />

      <Toast />
    </div>
  );
}
