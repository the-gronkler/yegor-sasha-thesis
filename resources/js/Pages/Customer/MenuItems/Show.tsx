import { Head, Link } from '@inertiajs/react';
import {
  ArrowLeftIcon,
  MinusIcon,
  PlusIcon,
} from '@heroicons/react/24/outline';
import CustomerLayout from '@/Layouts/CustomerLayout';
import { MenuItem } from '@/types/models';
import { PageProps } from '@/types';
import { useCart } from '@/Contexts/CartContext';
import { useAuth } from '@/Hooks/useAuth';

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

  const primaryImage =
    menuItem.images?.find((img) => img.is_primary_for_menu_item) ||
    menuItem.images?.[0];
  const imageUrl = primaryImage ? primaryImage.url : null;

  const handleAddToCart = () => {
    requireAuth(() => {
      addItem(menuItem, restaurantId);
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
    <CustomerLayout>
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

        {/* Item Image */}
        <div className="menu-item-image-section">
          {imageUrl ? (
            <img src={imageUrl} alt={menuItem.name} className="item-image" />
          ) : (
            <div className="item-image-placeholder">
              <span>No Image Available</span>
            </div>
          )}
        </div>

        {/* Item Details Card */}
        <div className="menu-item-details-card">
          <div className="restaurant-name-tag">{restaurantName}</div>

          <h1 className="item-name">{menuItem.name}</h1>

          <div className="item-price">€{menuItem.price.toFixed(2)}</div>

          {menuItem.description && (
            <div className="item-description-section">
              <h3 className="section-title">Description</h3>
              <p className="item-description">{menuItem.description}</p>
            </div>
          )}

          {menuItem.allergens && menuItem.allergens.length > 0 && (
            <div className="item-allergens-section">
              <h3 className="section-title">Allergens</h3>
              <div className="allergens-list">
                {menuItem.allergens.map((allergen) => (
                  <span key={allergen.id} className="allergen-badge">
                    {allergen.name}
                  </span>
                ))}
              </div>
            </div>
          )}

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
                aria-label="Increase quantity"
              >
                <PlusIcon className="icon" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </CustomerLayout>
  );
}
