import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head } from '@inertiajs/react';

export default function EstablishmentIndex() {
  return (
    <CustomerLayout>
      <Head title="Establishment" />
      <div className="employee-page">
        <h1>Establishment</h1>
        <p>Establishment settings placeholder.</p>
      </div>
    </CustomerLayout>
  );
}
