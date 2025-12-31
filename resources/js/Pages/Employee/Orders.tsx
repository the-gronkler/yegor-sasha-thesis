import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head } from '@inertiajs/react';

export default function OrdersIndex() {
  return (
    <CustomerLayout>
      <Head title="Orders" />
      <div className="employee-page">
        <h1>Orders</h1>
        <p>Orders management placeholder.</p>
      </div>
    </CustomerLayout>
  );
}
