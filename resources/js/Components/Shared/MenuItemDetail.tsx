import { MenuItem } from '@/types/models';

interface Props {
  menuItem: MenuItem;
  restaurantName: string;
  children?: React.ReactNode;
}

export default function MenuItemDetail({
  menuItem,
  restaurantName,
  children,
}: Props) {
  const imageUrl = menuItem.image?.url || null;

  return (
    <>
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

        {children}
      </div>
    </>
  );
}
