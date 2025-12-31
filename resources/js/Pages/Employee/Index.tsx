import { Head } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout'; // Using CustomerLayout for now, can create EmployeeLayout later
import { PageProps } from '@/types';

interface EmployeeIndexProps extends PageProps {}

export default function EmployeeIndex({}: EmployeeIndexProps) {
  return (
    <CustomerLayout>
      <Head title="Employee Dashboard" />

      <div className="employee-dashboard">
        <h1>Welcome, Employee!</h1>
        <p>
          This is the employee dashboard. Add employee-specific features here.
        </p>
      </div>
    </CustomerLayout>
  );
}
