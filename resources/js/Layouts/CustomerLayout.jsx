import { Link } from '@inertiajs/react';
import { MapPinIcon, ShoppingCartIcon, UserIcon } from '@heroicons/react/24/outline';

export default function CustomerLayout({ children }) {
    return (
        <div className="customer-layout">
            <main className="main-content">{children}</main>

            <nav className="bottom-nav">
                <NavLink
                    href={route('restaurants.index')}
                    active={route().current('restaurants.index')}
                    icon={MapPinIcon}
                    label="Explore"
                />
                <NavLink
                    href="#"
                    active={false}
                    icon={ShoppingCartIcon}
                    label="Orders"
                />
                <NavLink
                    href="#"
                    active={false}
                    icon={UserIcon}
                    label="Profile"
                />
            </nav>
        </div>
    );
}

function NavLink({ href, active, icon: Icon, label }) {
    return (
        <Link href={href} className={`nav-item ${active ? 'active' : ''}`}>
            <Icon className="icon" />
            <span className="label">{label}</span>
        </Link>
    );
}
