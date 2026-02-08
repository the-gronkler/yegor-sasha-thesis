import AppLayout from '@/Layouts/AppLayout';
import { Head, router } from '@inertiajs/react';
import {
  UserCircleIcon,
  BuildingOfficeIcon,
  EnvelopeIcon,
} from '@heroicons/react/24/outline';
import { FormEventHandler } from 'react';

interface Admin {
  name: string;
  surname: string;
  email: string;
}

interface WorkerProfileProps {
  user: {
    name: string;
    surname: string;
    email: string;
  };
  restaurant: {
    name: string;
  };
  admins: Admin[];
}

export default function WorkerProfile({
  user,
  restaurant,
  admins,
}: WorkerProfileProps) {
  const handleLogout: FormEventHandler = (e) => {
    e.preventDefault();
    router.post(route('logout'));
  };

  return (
    <AppLayout>
      <Head title="Worker Profile" />

      <div className="profile-page">
        {/* Header */}
        <div className="profile-header">
          <h1 className="profile-title">Worker Profile</h1>
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

        {/* Restaurant Info Card */}
        <div className="profile-card worker-info-card">
          <div className="section-header">
            <h3 className="section-title">Employment Information</h3>
          </div>
          <div className="info-row">
            <div className="info-icon">
              <BuildingOfficeIcon className="icon" />
            </div>
            <div className="info-content">
              <p className="info-label">Restaurant</p>
              <p className="info-value">{restaurant.name}</p>
            </div>
          </div>
        </div>

        {/* Admins Contact Card */}
        {admins && admins.length > 0 && (
          <div className="profile-card worker-admins-card">
            <div className="section-header">
              <h3 className="section-title">Restaurant Administrators</h3>
            </div>
            <div className="admins-list">
              {admins.map((admin, index) => (
                <div key={index} className="admin-item">
                  <div className="admin-icon">
                    <UserCircleIcon className="icon" />
                  </div>
                  <div className="admin-info">
                    <p className="admin-name">
                      {admin.name} {admin.surname}
                    </p>
                    <a href={`mailto:${admin.email}`} className="admin-email">
                      <EnvelopeIcon className="email-icon" />
                      {admin.email}
                    </a>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </AppLayout>
  );
}
