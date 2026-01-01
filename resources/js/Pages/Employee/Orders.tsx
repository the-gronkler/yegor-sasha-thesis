import AppLayout from '@/Layouts/AppLayout';
import { Head } from '@inertiajs/react';

export default function OrdersIndex() {
  return (
    <AppLayout>
      <Head title="Orders" />
      <div className="employee-page">
        <h1>Orders</h1>
        <p>Orders management placeholder.</p>
      </div>
    </AppLayout>
  );
}
