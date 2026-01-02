import AppLayout from '@/Layouts/AppLayout';
import { Head } from '@inertiajs/react';
import { Restaurant } from '@/types/models';
import RestaurantMenu from '@/Components/Shared/RestaurantMenu';

interface Props {
  restaurant: Restaurant;
}

export default function EmployeeMenu({ restaurant }: Props) {
  return (
    <AppLayout>
      <Head title="Menu Management" />

      <div className="employee-menu-page">
        <div className="page-header">
          <h1 className="page-title">Menu Management</h1>
        </div>

        <RestaurantMenu restaurant={restaurant} mode="employee" />
      </div>
    </AppLayout>
  );
}
