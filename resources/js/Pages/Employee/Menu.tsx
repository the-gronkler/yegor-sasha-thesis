import AppLayout from '@/Layouts/AppLayout';
import { Head } from '@inertiajs/react';
import { Restaurant } from '@/types/models';
import RestaurantMenu from '@/Components/Shared/RestaurantMenu';
import { PencilSquareIcon, Cog6ToothIcon } from '@heroicons/react/24/outline';
import { useState } from 'react';

interface Props {
  restaurant: Restaurant;
  isRestaurantAdmin: boolean;
}

export default function EmployeeMenu({ restaurant, isRestaurantAdmin }: Props) {
  const [isEditMode, setIsEditMode] = useState(false);
  const [isManagingCategories, setIsManagingCategories] = useState(false);

  const primaryImage =
    restaurant.images?.find((img) => img.is_primary_for_restaurant) ||
    restaurant.images?.[0];
  const bannerUrl = primaryImage ? primaryImage.url : null;

  return (
    <AppLayout>
      <Head title="Menu Management" />

      <div className="employee-menu-page">
        {/* Banner */}
        <div
          className="restaurant-banner"
          style={bannerUrl ? { backgroundImage: `url(${bannerUrl})` } : {}}
        >
          <div className="banner-actions">
            {/* Could add back button here if needed */}
          </div>
        </div>

        {/* Header Card - Overlaps Banner */}
        <div className="page-header">
          <h1 className="page-title">{restaurant.name} Menu Management</h1>
          <div className="edit-buttons">
            {isRestaurantAdmin && isEditMode && (
              <button
                onClick={() => setIsManagingCategories(!isManagingCategories)}
                className="btn-secondary"
                aria-label="Manage Categories"
              >
                <Cog6ToothIcon className="icon-sm" />
                {isManagingCategories ? 'Done Managing' : 'Manage Categories'}
              </button>
            )}
            {isRestaurantAdmin && (
              <button
                onClick={() => setIsEditMode(!isEditMode)}
                className="btn-secondary"
                aria-label="Toggle Edit Menu Mode"
              >
                <PencilSquareIcon className="icon-sm" />
                {isEditMode ? 'Exit Edit' : 'Edit Menu'}
              </button>
            )}
          </div>
        </div>

        <RestaurantMenu
          restaurant={restaurant}
          mode={isEditMode ? 'employee-edit' : 'employee'}
          isRestaurantAdmin={isRestaurantAdmin}
          isManagingCategories={isManagingCategories}
        />
      </div>
    </AppLayout>
  );
}
