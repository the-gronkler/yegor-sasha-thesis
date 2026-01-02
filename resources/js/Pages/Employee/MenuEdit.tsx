import AppLayout from '@/Layouts/AppLayout';
import { Head, Link } from '@inertiajs/react';
import { Restaurant } from '@/types/models';
import RestaurantMenu from '@/Components/Shared/RestaurantMenu';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';

interface Props {
  restaurant: Restaurant;
}

export default function EmployeeMenuEdit({ restaurant }: Props) {
  return (
    <AppLayout>
      <Head title="Edit Menu" />

      <div className="employee-menu-page">
        <div className="page-header">
          <div className="header-left">
            <Link
              href={route('employee.menu.index')}
              className="back-link"
              aria-label="Back to Menu"
            >
              <ArrowLeftIcon className="icon" />
            </Link>
            <h1 className="page-title">Edit Menu</h1>
          </div>
        </div>

        <RestaurantMenu restaurant={restaurant} mode="employee-edit" />
      </div>
    </AppLayout>
  );
}
