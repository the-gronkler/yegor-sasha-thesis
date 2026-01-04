import { Head, Link } from '@inertiajs/react';
import { ArrowLeftIcon, PencilSquareIcon } from '@heroicons/react/24/outline';
import AppLayout from '@/Layouts/AppLayout';
import { MenuItem } from '@/types/models';
import MenuItemDetail from '@/Components/Shared/MenuItemDetail';

interface Props {
  menuItem: MenuItem;
  restaurantName: string;
  canEdit: boolean;
}

export default function EmployeeMenuItemShow({
  menuItem,
  restaurantName,
  canEdit,
}: Props) {
  return (
    <AppLayout>
      <Head title={menuItem.name} />

      <div className="menu-item-show-page employee-mode">
        <div className="page-header">
          <div className="header-left">
            <Link
              href={route('employee.menu.index')}
              className="back-link"
              aria-label="Back to Menu"
            >
              <ArrowLeftIcon className="icon" />
            </Link>
            <h1 className="page-title">View Menu Item</h1>
          </div>
        </div>

        <MenuItemDetail menuItem={menuItem} restaurantName={restaurantName}>
          {canEdit && (
            <div className="action-controls">
              <Link
                href={route('employee.restaurant.menu-items.edit', {
                  menu_item: menuItem.id,
                  from: 'show',
                })}
                className="edit-item-btn"
              >
                <PencilSquareIcon className="icon-sm mr-2" />
                Edit Item
              </Link>
            </div>
          )}
        </MenuItemDetail>
      </div>
    </AppLayout>
  );
}
