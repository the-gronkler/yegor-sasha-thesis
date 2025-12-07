import { MenuItem } from '@/types/models';

interface MenuItemCardProps {
  item: MenuItem;
}

export default function MenuItemCard({ item }: MenuItemCardProps) {
  // Placeholder for availability logic.
  // Assuming available unless specified otherwise (not in current data).
  const isAvailable = true;

  const primaryImage =
    item.images?.find((img) => img.is_primary_for_menu_item) ||
    item.images?.[0];
  const imageUrl = primaryImage ? primaryImage.url : null; // Adjust path as needed

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
        <p className="menu-item-price">€{item.price}</p>
      </div>

      <button className="add-button" disabled={!isAvailable}>
        +
      </button>
    </div>
  );
}
