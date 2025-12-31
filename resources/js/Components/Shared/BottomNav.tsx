import {
  MapPinIcon,
  ShoppingCartIcon,
  UserIcon,
  BuildingStorefrontIcon,
  ClipboardDocumentListIcon,
  ArrowRightEndOnRectangleIcon,
  HomeIcon,
  UserGroupIcon,
  QueueListIcon,
} from '@heroicons/react/24/outline';
import { useCart } from '@/Contexts/CartContext';
import { useAuth } from '@/Hooks/useAuth';
import IconNavItem from '@/Components/UI/IconNavItem';

export default function BottomNav() {
  const { itemCount } = useCart();
  const { isAuthenticated, isEmployee, isAdmin, login } = useAuth();

  if (isEmployee) {
    return (
      <nav className="bottom-nav">
        <IconNavItem
          href={route('employee.index')}
          active={route().current('employee.index')}
          icon={HomeIcon}
          label="Dashboard"
        />
        {isAdmin && (
          <>
            <IconNavItem
              href={route('restaurant.menu-items.index')}
              active={route().current('restaurant.menu-items.*')}
              icon={QueueListIcon}
              label="Menu"
            />
            <IconNavItem
              href={route('restaurant.workers.index')}
              active={route().current('restaurant.workers.*')}
              icon={UserGroupIcon}
              label="Team"
            />
          </>
        )}
        <IconNavItem
          href={route('profile.show')}
          active={route().current('profile.show')}
          icon={UserIcon}
          label="Profile"
        />
      </nav>
    );
  }

  return (
    <nav className="bottom-nav">
      <IconNavItem
        href={route('map.index')}
        active={route().current('map.index')}
        icon={MapPinIcon}
        label="Explore"
      />
      <IconNavItem
        href={route('restaurants.index')}
        active={route().current('restaurants.index')}
        icon={BuildingStorefrontIcon}
        label="Restaurants"
      />
      {isAuthenticated && (
        <>
          <IconNavItem
            href={route('cart.index')}
            active={route().current('cart.index')}
            icon={ShoppingCartIcon}
            label="Cart"
            badge={itemCount}
          />
          <IconNavItem
            href={route('orders.index')}
            active={route().current('orders.index')}
            icon={ClipboardDocumentListIcon}
            label="Orders"
          />
          <IconNavItem
            href={route('profile.show')}
            active={route().current('profile.show')}
            icon={UserIcon}
            label="Profile"
          />
        </>
      )}
      {!isAuthenticated && (
        <IconNavItem
          as="button"
          icon={ArrowRightEndOnRectangleIcon}
          label="Login"
          onClick={login}
        />
      )}
    </nav>
  );
}
