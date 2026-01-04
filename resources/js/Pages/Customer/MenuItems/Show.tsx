import { Head, Link } from '@inertiajs/react';
import {
  ArrowLeftIcon,
  MinusIcon,
  PlusIcon,
} from '@heroicons/react/24/outline';
import AppLayout from '@/Layouts/AppLayout';
import { MenuItem } from '@/types/models';
import { PageProps } from '@/types';
import { useCart } from '@/Contexts/CartContext';
import { useAuth } from '@/Hooks/useAuth';
import MenuItemDetail from '@/Components/Shared/MenuItemDetail';

interface MenuItemShowProps extends PageProps {
  menuItem: MenuItem;
  restaurantId: number;
  restaurantName: string;
}

export default function MenuItemShow({
  menuItem,
  restaurantId,
  restaurantName,
}: MenuItemShowProps) {
  const { addItem, updateQuantity, items } = useCart();
  const { requireAuth } = useAuth();

  // Check if item is already in cart and get quantity
  const cartItem = items.find((i) => i.id === menuItem.id);
  const quantityInCart = cartItem?.quantity || 0;

  const handleAddToCart = () => {
    requireAuth(() => {
      if (menuItem.is_available) {
        addItem(menuItem, restaurantId);
      }
    });
  };

  const handleRemoveFromCart = () => {
    requireAuth(() => {
      if (quantityInCart > 0) {
        updateQuantity(menuItem.id, quantityInCart - 1);
      }
    });
  };

  return (
    <AppLayout>
      <Head title={menuItem.name} />

      <div className="menu-item-show-page">
        {/* Header with Back Button */}
        <div className="menu-item-header">
          <Link
            href={route('restaurants.show', restaurantId)}
            className="back-button"
          >
            <ArrowLeftIcon className="icon" />
          </Link>
          <h2 className="header-title">View Menu Item</h2>
        </div>

        <MenuItemDetail menuItem={menuItem} restaurantName={restaurantName}>
          {/* Quantity Controls */}
          <div className="quantity-controls">
            <h3 className="section-title">Quantity</h3>
            <div className="quantity-buttons">
              <button
                className="quantity-btn decrease-btn"
                onClick={handleRemoveFromCart}
                disabled={quantityInCart === 0}
                aria-label="Decrease quantity"
              >
                <MinusIcon className="icon" />
              </button>

              <span className="quantity-display">{quantityInCart}</span>

              <button
                className="quantity-btn increase-btn"
                onClick={handleAddToCart}
                disabled={!menuItem.is_available}
                aria-label="Increase quantity"
              >
                <PlusIcon className="icon" />
              </button>
            </div>
            {!menuItem.is_available && (
              <p className="unavailable-text">Currently Unavailable</p>
            )}
          </div>
        </MenuItemDetail>
      </div>
    </AppLayout>
  );
}
