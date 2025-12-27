import { Head, Link } from '@inertiajs/react';
import {
  UserCircleIcon,
  HeartIcon,
  ShoppingBagIcon,
  ArrowRightIcon,
} from '@heroicons/react/24/outline';
import CustomerLayout from '@/Layouts/CustomerLayout';
import { User } from '@/types/models';
import { router } from '@inertiajs/react';
import { FormEventHandler } from 'react';

interface ProfileIndexProps {
  user: User;
  stats: {
    favoriteCount: number;
    orderCount: number;
  };
}

export default function ProfileIndex({ user, stats }: ProfileIndexProps) {
  const handleLogout: FormEventHandler = (e) => {
    e.preventDefault();
    router.post(route('logout'));
  };

  return (
    <CustomerLayout>
      <Head title="Profile" />

      <div className="profile-page">
        {/* Header */}
        <div className="profile-header">
          <h1 className="profile-title">Profile</h1>
          <button onClick={handleLogout} className="logout-button">
            Logout
          </button>
        </div>

        {/* User Info Card */}
        <div className="profile-card profile-info-card">
          <div className="user-avatar">
            <UserCircleIcon className="avatar-icon" />
          </div>
          <div className="user-details">
            <h2 className="user-name">
              {user.name} {user.surname}
            </h2>
            <p className="user-email">{user.email}</p>
          </div>
        </div>

        {/* Navigation Menu */}
        <div className="profile-menu">
          <Link href={route('profile.edit')} className="profile-menu-item">
            <div className="menu-item-icon">
              <UserCircleIcon className="icon" />
            </div>
            <div className="menu-item-content">
              <h3 className="menu-item-title">Edit Profile</h3>
              <p className="menu-item-description">
                Update your personal information and password
              </p>
            </div>
            <ArrowRightIcon className="menu-item-arrow" />
          </Link>

          <Link href={route('profile.favorites')} className="profile-menu-item">
            <div className="menu-item-icon">
              <HeartIcon className="icon" />
            </div>
            <div className="menu-item-content">
              <h3 className="menu-item-title">My Favorites</h3>
              <p className="menu-item-description">
                {stats.favoriteCount}{' '}
                {stats.favoriteCount === 1 ? 'restaurant' : 'restaurants'}
              </p>
            </div>
            <ArrowRightIcon className="menu-item-arrow" />
          </Link>

          <Link href={route('orders.index')} className="profile-menu-item">
            <div className="menu-item-icon">
              <ShoppingBagIcon className="icon" />
            </div>
            <div className="menu-item-content">
              <h3 className="menu-item-title">Order History</h3>
              <p className="menu-item-description">
                {stats.orderCount} {stats.orderCount === 1 ? 'order' : 'orders'}
              </p>
            </div>
            <ArrowRightIcon className="menu-item-arrow" />
          </Link>
        </div>
      </div>
    </CustomerLayout>
  );
}
