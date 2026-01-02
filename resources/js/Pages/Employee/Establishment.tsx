import AppLayout from '@/Layouts/AppLayout';
import { Head, Link } from '@inertiajs/react';
import {
  UsersIcon,
  BuildingStorefrontIcon,
  PhotoIcon,
  ArrowRightIcon,
} from '@heroicons/react/24/outline';
import { Restaurant } from '@/types/models';
import { PageProps } from '@/types';

interface EstablishmentIndexProps extends PageProps {
  restaurant: Restaurant;
  stats: {
    employeeCount: number;
    menuItemCount: number;
    imageCount: number;
  };
}

export default function EstablishmentIndex({
  restaurant,
  stats,
}: EstablishmentIndexProps) {
  return (
    <AppLayout>
      <Head title="Establishment Management" />

      <div className="profile-page">
        {/* Header */}
        <div className="profile-header">
          <h1 className="profile-title">Establishment</h1>
        </div>

        {/* Restaurant Info Card */}
        <div className="profile-card profile-info-card">
          <div className="user-avatar">
            <BuildingStorefrontIcon className="avatar-icon" />
          </div>
          <div className="user-details">
            <h2 className="user-name">{restaurant.name}</h2>
            <p className="user-email">{restaurant.address}</p>
          </div>
        </div>

        {/* Management Menu */}
        <div className="profile-menu">
          {/* Workers Management */}
          <Link
            href={route('employee.establishment.workers')}
            className="profile-menu-item"
          >
            <div className="menu-item-icon">
              <UsersIcon className="icon" />
            </div>
            <div className="menu-item-content">
              <h3 className="menu-item-title">Manage Workers</h3>
              <p className="menu-item-description">
                {stats.employeeCount}{' '}
                {stats.employeeCount === 1 ? 'employee' : 'employees'}
              </p>
            </div>
            <ArrowRightIcon className="menu-item-arrow" />
          </Link>

          {/* Restaurant Data */}
          <Link
            href={route('employee.establishment.restaurant')}
            className="profile-menu-item"
          >
            <div className="menu-item-icon">
              <BuildingStorefrontIcon className="icon" />
            </div>
            <div className="menu-item-content">
              <h3 className="menu-item-title">Restaurant Information</h3>
              <p className="menu-item-description">
                Edit name, address, hours, and description
              </p>
            </div>
            <ArrowRightIcon className="menu-item-arrow" />
          </Link>

          {/* Photos Management */}
          <Link
            href={route('employee.establishment.photos')}
            className="profile-menu-item"
          >
            <div className="menu-item-icon">
              <PhotoIcon className="icon" />
            </div>
            <div className="menu-item-content">
              <h3 className="menu-item-title">Manage Photos</h3>
              <p className="menu-item-description">
                {stats.imageCount} {stats.imageCount === 1 ? 'photo' : 'photos'}
              </p>
            </div>
            <ArrowRightIcon className="menu-item-arrow" />
          </Link>
        </div>
      </div>
    </AppLayout>
  );
}
