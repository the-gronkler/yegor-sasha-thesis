import { MenuItem } from '@/types/models';
import { useCart } from '@/Contexts/CartContext';

interface MenuItemCardProps {
  item: MenuItem;
  restaurantId: number;
}

export default function MenuItemCard({
  item,
  restaurantId,
}: MenuItemCardProps) {
  const { addItem, items } = useCart();

  // Check if item is already in cart and get quantity
  const cartItem = items.find((i) => i.id === item.id);
  const quantityInCart = cartItem?.quantity || 0;

  // Placeholder for availability logic.
  // Assuming available unless specified otherwise (not in current data).
  //   TODO: implement actual availability check
  const isAvailable = true;

  const primaryImage =
    item.images?.find((img) => img.is_primary_for_menu_item) ||
    item.images?.[0];
  const imageUrl = primaryImage ? primaryImage.url : null;

  const handleAddToCart = () => {
    if (isAvailable) {
      addItem(item, restaurantId);
    }
  };

  return (
    <div className={`menu-item-card ${!isAvailable ? 'unavailable' : ''}`}>
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

      <button
        className="add-button"
        disabled={!isAvailable}
        onClick={handleAddToCart}
        aria-label={`Add ${item.name} to cart`}
      >
        +
        {quantityInCart > 0 && (
          <span className="item-count">{quantityInCart}</span>
        )}
      </button>
    </div>
  );
}
