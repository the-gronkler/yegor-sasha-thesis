import {
  MapPinIcon,
  ShoppingCartIcon,
  UserIcon,
  ArrowRightEndOnRectangleIcon,
} from '@heroicons/react/24/outline';
import { useCart } from '@/Contexts/CartContext';
import { useAuth } from '@/Hooks/useAuth';
import IconNavItem from '@/Components/UI/IconNavItem';
import { ClipboardDocumentListIcon } from '@heroicons/react/16/solid';

export default function BottomNav() {
  const { itemCount } = useCart();
  const { isAuthenticated, login } = useAuth();

  return (
    <nav className="bottom-nav">
      <IconNavItem
        href={route('map.index')}
        active={route().current('map.index')}
        icon={MapPinIcon}
        label="Explore"
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
