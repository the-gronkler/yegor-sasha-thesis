import { FormEventHandler } from 'react';
import { Head, useForm, Link } from '@inertiajs/react';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';
import CustomerLayout from '@/Layouts/CustomerLayout';
import { User, Customer } from '@/types/models';

interface ProfileEditProps {
  user: User;
  customer: Customer;
}

interface ProfileFormData {
  name: string;
  surname: string;
  email: string;
  password: string;
  password_confirmation: string;
  payment_method_token: string;
}

export default function ProfileEdit({ user, customer }: ProfileEditProps) {
  const form = useForm<ProfileFormData>({
    name: user.name || '',
    surname: user.surname || '',
    email: user.email || '',
    password: '',
    password_confirmation: '',
    payment_method_token: customer?.payment_method_token || '',
  });

  const handleSubmit: FormEventHandler = (e) => {
    e.preventDefault();
    form.put(route('profile.update'), {
      preserveScroll: true,
      onSuccess: () => {
        form.reset('password', 'password_confirmation');
      },
    });
  };

  return (
    <CustomerLayout>
      <Head title="Edit Profile" />

      <div className="profile-page">
        {/* Header */}
        <div className="profile-header">
          <Link href={route('profile.show')} className="back-button-link">
            <ArrowLeftIcon className="icon" />
            <span>Back</span>
          </Link>
          <h1 className="profile-title">Edit Profile</h1>
        </div>

        {/* Profile Form */}
        <div className="profile-card">
          <form onSubmit={handleSubmit} className="profile-form">
            {/* Name */}
            <div className="form-group">
              <label htmlFor="name">Name</label>
              <input
                id="name"
                type="text"
                className="form-input"
                value={form.data.name}
                onChange={(e) => form.setData('name', e.target.value)}
                required
              />
              {form.errors.name && (
                <p className="error-message">{form.errors.name}</p>
              )}
            </div>

            {/* Surname */}
            <div className="form-group">
              <label htmlFor="surname">Surname</label>
              <input
                id="surname"
                type="text"
                className="form-input"
                value={form.data.surname}
                onChange={(e) => form.setData('surname', e.target.value)}
              />
              {form.errors.surname && (
                <p className="error-message">{form.errors.surname}</p>
              )}
            </div>

            {/* Email */}
            <div className="form-group">
              <label htmlFor="email">Email</label>
              <input
                id="email"
                type="email"
                className="form-input"
                value={form.data.email}
                onChange={(e) => form.setData('email', e.target.value)}
                required
              />
              {form.errors.email && (
                <p className="error-message">{form.errors.email}</p>
              )}
            </div>

            {/* Payment Method Token */}
            <div className="form-group">
              <label htmlFor="payment_method_token">Payment Method</label>
              <input
                id="payment_method_token"
                type="text"
                className="form-input"
                placeholder="e.g., Card ending in 1234"
                value={form.data.payment_method_token}
                onChange={(e) =>
                  form.setData('payment_method_token', e.target.value)
                }
              />
              {form.errors.payment_method_token && (
                <p className="error-message">
                  {form.errors.payment_method_token}
                </p>
              )}
            </div>

            {/* Change Password Section */}
            <div className="section-divider">
              <h3 className="section-title">Change Password</h3>
            </div>

            {/* New Password */}
            <div className="form-group">
              <label htmlFor="password">New Password</label>
              <input
                id="password"
                type="password"
                className="form-input"
                placeholder="Leave blank to keep current password"
                value={form.data.password}
                onChange={(e) => form.setData('password', e.target.value)}
                autoComplete="new-password"
              />
              {form.errors.password && (
                <p className="error-message">{form.errors.password}</p>
              )}
            </div>

            {/* Confirm Password */}
            <div className="form-group">
              <label htmlFor="password_confirmation">Confirm Password</label>
              <input
                id="password_confirmation"
                type="password"
                className="form-input"
                value={form.data.password_confirmation}
                onChange={(e) =>
                  form.setData('password_confirmation', e.target.value)
                }
                autoComplete="new-password"
              />
              {form.errors.password_confirmation && (
                <p className="error-message">
                  {form.errors.password_confirmation}
                </p>
              )}
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={form.processing}
              className="btn-submit"
            >
              {form.processing ? 'Saving...' : 'Save Changes'}
            </button>
          </form>
        </div>
      </div>
    </CustomerLayout>
  );
}
