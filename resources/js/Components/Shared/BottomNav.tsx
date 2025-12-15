import { Link } from '@inertiajs/react';
import {
  MapPinIcon,
  ShoppingCartIcon,
  UserIcon,
  BuildingStorefrontIcon,
  ClipboardDocumentListIcon,
} from '@heroicons/react/24/outline';
import { useCart } from '@/Contexts/CartContext';

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

export default function BottomNav() {
  const { itemCount } = useCart();

  return (
    <nav className="bottom-nav">
      <NavLink
        href={route('map.index')}
        active={route().current('map.index')}
        icon={MapPinIcon}
        label="Explore"
      />
      <NavLink
        href={route('restaurants.index')}
        active={route().current('restaurants.index')}
        icon={BuildingStorefrontIcon}
        label="Restaurants"
      />
      <NavLink
        href={route('cart.index')}
        active={route().current('cart.index')}
        icon={ShoppingCartIcon}
        label="Cart"
        badge={itemCount}
      />
      <NavLink
        href={route('orders.index')}
        active={route().current('orders.index')}
        icon={ClipboardDocumentListIcon}
        label="Orders"
      />
      <NavLink
        href={route('profile.show')}
        active={route().current('profile.show')}
        icon={UserIcon}
        label="Profile"
      />
    </nav>
  );
}
