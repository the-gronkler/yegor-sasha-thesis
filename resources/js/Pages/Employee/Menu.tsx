import AppLayout from '@/Layouts/AppLayout';
import { Head, Link } from '@inertiajs/react';
import { Restaurant } from '@/types/models';
import RestaurantMenu from '@/Components/Shared/RestaurantMenu';
import { PencilSquareIcon } from '@heroicons/react/24/outline';

interface Props {
  restaurant: Restaurant;
  isRestaurantAdmin: boolean;
}

export default function EmployeeMenu({ restaurant, isRestaurantAdmin }: Props) {
  return (
    <AppLayout>
      <Head title="Menu Management" />

      <div className="employee-menu-page">
        <div className="page-header">
          <h1 className="page-title">Menu Management</h1>
          {isRestaurantAdmin && (
            <Link
              href={route('employee.menu.edit')}
              className="btn-secondary"
              aria-label="Edit Menu Mode"
            >
              <PencilSquareIcon className="icon-sm" />
              Edit Menu
            </Link>
          )}
        </div>

        <RestaurantMenu restaurant={restaurant} mode="employee" />
      </div>
    </AppLayout>
  );
}
