import { TrashIcon, MinusIcon, PlusIcon } from '@heroicons/react/24/outline';
import { MenuItem } from '@/types/models';

export interface CartItemType extends MenuItem {
  quantity: number;
}

interface CartItemProps {
  item: CartItemType;
  onUpdateQuantity: (itemId: number, newQuantity: number) => void;
  onRemove: (itemId: number) => void;
}

export default function CartItem({
  item,
  onUpdateQuantity,
  onRemove,
}: CartItemProps) {
  const primaryImage =
    item.images?.find((img) => img.is_primary_for_menu_item) ||
    item.images?.[0];
  const imageUrl = primaryImage?.url;

  return (
    <div className="cart-item">
      {imageUrl ? (
        <img src={imageUrl} alt={item.name} className="cart-item-image" />
      ) : (
        <div className="cart-item-image placeholder" />
      )}

      <div className="cart-item-details">
        <h3 className="cart-item-name">{item.name}</h3>
        <p className="cart-item-price">€{item.price.toFixed(2)}</p>

        {item.description && (
          <p className="cart-item-description">{item.description}</p>
        )}
      </div>

      <div className="cart-item-actions">
        <div className="quantity-controls">
          <button
            onClick={() => onUpdateQuantity(item.id, item.quantity - 1)}
            className="quantity-btn"
            aria-label="Decrease quantity"
          >
            <MinusIcon className="icon" />
          </button>
          <span className="quantity">{item.quantity}</span>
          <button
            onClick={() => onUpdateQuantity(item.id, item.quantity + 1)}
            className="quantity-btn"
            aria-label="Increase quantity"
          >
            <PlusIcon className="icon" />
          </button>
        </div>

        <button
          onClick={() => onRemove(item.id)}
          className="remove-btn"
          aria-label={`Remove ${item.name}`}
        >
          <TrashIcon className="icon" />
        </button>
      </div>
    </div>
  );
}
