import { MenuItem } from '@/types/models';
import { useCart } from '@/Contexts/CartContext';
import { router } from '@inertiajs/react';
import { useAuth } from '@/Hooks/useAuth';
import Toggle from '@/Components/UI/Toggle';
import { PencilIcon } from '@heroicons/react/24/outline';

interface MenuItemCardProps {
  item: MenuItem;
  restaurantId: number;
  mode?: 'customer' | 'employee' | 'employee-edit';
}

export default function MenuItemCard({
  item,
  restaurantId,
  mode = 'customer',
}: MenuItemCardProps) {
  const { addItem, updateQuantity, items } = useCart();
  const { requireAuth } = useAuth();

  // Check if item is already in cart and get quantity
  const cartItem = items.find((i) => i.id === item.id);
  const quantityInCart = cartItem?.quantity || 0;

  const isAvailable = item.is_available;

  const primaryImage =
    item.images?.find((img) => img.is_primary_for_menu_item) ||
    item.images?.[0];
  const imageUrl = primaryImage ? primaryImage.url : null;

  const handleAddToCart = () => {
    requireAuth(() => {
      if (isAvailable) {
        addItem(item, restaurantId);
      }
    });
  };

  const handleRemoveFromCart = () => {
    requireAuth(() => {
      if (quantityInCart > 0) {
        updateQuantity(item.id, quantityInCart - 1);
      }
    });
  };

  const handleEditClick = (e?: React.MouseEvent) => {
    e?.stopPropagation();
    router.visit(route('employee.restaurant.menu-items.edit', item.id));
  };

  const handleCardClick = () => {
    if (mode === 'customer') {
      router.visit(
        route('restaurants.menu-items.show', [restaurantId, item.id]),
      );
    } else if (mode === 'employee-edit') {
      handleEditClick();
    }
  };

  const handleAvailabilityToggle = (checked: boolean) => {
    router.put(
      route('employee.restaurant.menu-items.updateStatus', item.id),
      {
        is_available: checked,
      },
      {
        preserveScroll: true,
      },
    );
  };

  return (
    <div
      className={`menu-item-card ${!isAvailable ? 'unavailable' : ''} ${
        mode === 'employee' || mode === 'employee-edit' ? 'employee-mode' : ''
      }`}
    >
      <div className="menu-item-content" onClick={handleCardClick}>
        {imageUrl ? (
          <img src={imageUrl} alt={item.name} className="menu-item-image" />
        ) : (
          <div className="menu-item-image" /> // Placeholder
        )}

        <div className="menu-item-details">
          <h4 className="menu-item-name">{item.name}</h4>
          <p className="menu-item-description">{item.description}</p>
          <p className="menu-item-price">€{item.price.toFixed(2)}</p>
        </div>
      </div>

      <div className="menu-item-actions">
        {mode === 'customer' && (
          <>
            {quantityInCart > 0 && (
              <button
                className="quantity-btn remove-button"
                onClick={handleRemoveFromCart}
                aria-label={`Remove one ${item.name} from cart`}
              >
                -
              </button>
            )}

            <button
              className="quantity-btn add-button"
              disabled={!isAvailable}
              onClick={handleAddToCart}
              aria-label={`Add ${item.name} to cart`}
            >
              +
              {quantityInCart > 0 && (
                <span className="item-count">{quantityInCart}</span>
              )}
            </button>
          </>
        )}

        {mode === 'employee' && (
          <div className="employee-actions">
            <Toggle
              checked={isAvailable}
              onChange={handleAvailabilityToggle}
              label={isAvailable ? 'Available' : 'Unavailable'}
            />
          </div>
        )}

        {mode === 'employee-edit' && (
          <div className="employee-actions">
            <button
              className="edit-button"
              onClick={handleEditClick}
              aria-label="Edit menu item"
            >
              <PencilIcon className="icon" />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
