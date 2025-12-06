import { Link } from '@inertiajs/react';

export default function CustomerLayout({ children }) {
    return (
        <div className="customer-layout">
            <main className="main-content">{children}</main>

            <nav className="bottom-nav">
                <Link href={route('restaurants.index')} className="nav-item">
                    <span className="icon">📍</span>
                    <span className="label">Explore</span>
                </Link>
                <Link href={route('orders.index')} className="nav-item">
                    <span className="icon">🛒</span>
                    <span className="label">Orders</span>
                </Link>
                <Link href={route('profile.show')} className="nav-item">
                    <span className="icon">👤</span>
                    <span className="label">Profile</span>
                </Link>
            </nav>
        </div>
    );
}
