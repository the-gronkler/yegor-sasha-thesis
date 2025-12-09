import { PropsWithChildren } from 'react';
import { Link } from '@inertiajs/react';
import {
  MapPinIcon,
  ShoppingCartIcon,
  UserIcon,
} from '@heroicons/react/24/outline';
import { useCart } from '@/Contexts/CartContext';

interface CustomerLayoutProps extends PropsWithChildren {}

interface NavLinkProps {
  href: string;
  active: boolean;
  icon: React.ElementType;
  label: string;
  badge?: number;
}

function NavLink({ href, active, icon: Icon, label, badge }: NavLinkProps) {
  return (
    <Link href={href} className={`nav-item ${active ? 'active' : ''}`}>
      <div className="nav-icon-wrapper">
        <Icon className="icon" aria-hidden="true" />
        {badge !== undefined && badge > 0 && (
          <span className="nav-badge">{badge > 99 ? '99+' : badge}</span>
        )}
      </div>
      <span className="label">{label}</span>
    </Link>
  );
}

export default function CustomerLayout({ children }: CustomerLayoutProps) {
  const { itemCount } = useCart();

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
          href={route('cart.index')}
          active={route().current('cart.index')}
          icon={ShoppingCartIcon}
          label="Cart"
          badge={itemCount}
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
