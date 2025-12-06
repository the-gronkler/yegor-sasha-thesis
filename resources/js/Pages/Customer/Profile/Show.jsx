import React from 'react';
import { Head, Link, useForm, router } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout';

export default function ProfileShow({ user, customer, favorites }) {
    const form = useForm({
        name: user.name || '',
        surname: user.surname || '',
        email: user.email || '',
        password: '',
        password_confirmation: '',
        payment_method_token: customer?.payment_method_token || '',
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        form.put(route('profile.update'), {
            preserveScroll: true,
            onSuccess: () => {
                form.reset('password', 'password_confirmation');
            },
        });
    };

    const handleLogout = (e) => {
        e.preventDefault();
        router.post(route('logout'));
    };

    return (
        <CustomerLayout>
            <Head title="My Profile" />

            <div className="profile-page">
                {/* Header */}
                <div className="profile-header">
                    <h1 className="profile-title">My Profile</h1>
                    <button onClick={handleLogout} className="logout-button">
                        Logout
                    </button>
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
                                onChange={(e) => form.setData('payment_method_token', e.target.value)}
                            />
                            {form.errors.payment_method_token && (
                                <p className="error-message">{form.errors.payment_method_token}</p>
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
                                onChange={(e) => form.setData('password_confirmation', e.target.value)}
                                autoComplete="new-password"
                            />
                            {form.errors.password_confirmation && (
                                <p className="error-message">{form.errors.password_confirmation}</p>
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

                {/* Favorites Section */}
                {favorites && favorites.length > 0 && (
                    <div className="favorites-section">
                        <div className="section-header">
                            <h2 className="section-title">My Favorite Restaurants</h2>
                            <Link href={route('profile.favorites')} className="view-all-link">
                                View All
                            </Link>
                        </div>

                        <div className="favorites-list">
                            {favorites.slice(0, 3).map((favorite) => (
                                <Link
                                    key={favorite.id}
                                    href={route('restaurants.show', favorite.id)}
                                    className="favorite-item"
                                >
                                    <span className="favorite-rank">#{favorite.rank}</span>
                                    <div className="favorite-info">
                                        <h4 className="favorite-name">{favorite.name}</h4>
                                    </div>
                                    <span className="favorite-arrow">→</span>
                                </Link>
                            ))}
                        </div>
                    </div>
                )}
            </div>
        </CustomerLayout>
    );
}
