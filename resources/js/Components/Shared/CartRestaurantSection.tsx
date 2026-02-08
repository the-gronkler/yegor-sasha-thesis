import { Link } from '@inertiajs/react';
import { ChevronRightIcon } from '@heroicons/react/24/outline';
import { Restaurant } from '@/types/models';
import CartItem, { CartItemType } from './CartItem';

interface CartRestaurantSectionProps {
  restaurant: Restaurant;
  orderId: number;
  items: CartItemType[];
  subtotal: number;
  isSavingNotes: boolean;
  currentNotes: string;
  onUpdateQuantity: (itemId: number, newQuantity: number) => void;
  onRemoveItem: (itemId: number) => void;
  onSaveNotes: (orderId: number, restaurantId: number) => void;
  onCheckout: (orderId: number) => void;
  onNotesChange: (restaurantId: number, value: string) => void;
}

export default function CartRestaurantSection({
  restaurant,
  orderId,
  items,
  subtotal,
  isSavingNotes,
  currentNotes,
  onUpdateQuantity,
  onRemoveItem,
  onSaveNotes,
  onCheckout,
  onNotesChange,
}: CartRestaurantSectionProps) {
  return (
    <div className="restaurant-section">
      {/* Restaurant Header */}
      <div className="restaurant-header">
        <Link
          href={route('restaurants.show', {
            restaurant: restaurant.id,
          })}
          className="restaurant-link"
        >
          <div className="restaurant-info">
            <h2 className="restaurant-name">{restaurant.name}</h2>
            <span className="item-count-small">
              {items.length} item{items.length !== 1 ? 's' : ''}
            </span>
          </div>
          <ChevronRightIcon className="chevron-icon" />
        </Link>
      </div>

      {/* Items from this restaurant */}
      <div className="cart-items">
        {items.map((item) => (
          // todo, when deleting, it disappears instatntly, allow users to undo within 5 seconds somehow
          <CartItem
            key={item.id}
            item={item}
            onUpdateQuantity={onUpdateQuantity}
            onRemove={onRemoveItem}
          />
        ))}
      </div>

      {/* Notes for this restaurant */}
      <div className="restaurant-notes">
        <h4 className="notes-title">Special Instructions</h4>
        <textarea
          value={currentNotes}
          onChange={(e) => onNotesChange(restaurant.id, e.target.value)}
          placeholder={`Add special instructions for ${restaurant.name}...`}
          className="notes-input"
          rows={3}
        />
        <button
          onClick={() => onSaveNotes(orderId, restaurant.id)}
          disabled={isSavingNotes}
          className="btn-save-notes"
        >
          {isSavingNotes ? 'Saving...' : 'Save Notes'}
        </button>
      </div>

      {/* Subtotal and Checkout for this restaurant */}
      <div className="restaurant-footer">
        <div className="restaurant-subtotal">
          <span className="subtotal-label">Subtotal</span>
          <span className="subtotal-amount">€{subtotal.toFixed(2)}</span>
        </div>
        <button
          onClick={() => onCheckout(orderId)}
          className="btn-restaurant-checkout"
        >
          Checkout {restaurant.name}
        </button>
      </div>
    </div>
  );
}
