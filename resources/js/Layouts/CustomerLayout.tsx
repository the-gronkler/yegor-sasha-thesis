import { PropsWithChildren } from 'react';
import { Link } from '@inertiajs/react';
import {
  MapPinIcon,
  ShoppingCartIcon,
  UserIcon,
} from '@heroicons/react/24/outline';

interface CustomerLayoutProps extends PropsWithChildren {}

interface NavLinkProps {
  href: string;
  active: boolean;
  icon: React.ElementType;
  label: string;
}

function NavLink({ href, active, icon: Icon, label }: NavLinkProps) {
  return (
    <Link href={href} className={`nav-item ${active ? 'active' : ''}`}>
      <Icon className="icon" aria-hidden="true" />
      <span className="label">{label}</span>
    </Link>
  );
}

export default function CustomerLayout({ children }: CustomerLayoutProps) {
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
          href={route('orders.index')}
          active={route().current('orders.index')}
          icon={ShoppingCartIcon}
          label="Orders"
        />
        <NavLink
          href={route('profile.show')}
          active={route().current('profile.show')}
          icon={UserIcon}
          label="Profile"
        />
      </nav>
    </div>
  );
}
