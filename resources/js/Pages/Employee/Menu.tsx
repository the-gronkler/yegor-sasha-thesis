import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head } from '@inertiajs/react';

export default function MenuIndex() {
  return (
    <CustomerLayout>
      <Head title="Menu Management" />
      <div className="employee-page">
        <h1>Menu Management</h1>
        <p>Menu management placeholder.</p>
      </div>
    </CustomerLayout>
  );
}
