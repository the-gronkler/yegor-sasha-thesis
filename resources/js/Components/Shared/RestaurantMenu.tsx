import { Restaurant } from '@/types/models';
import MenuItemCard from '@/Components/Shared/MenuItemCard';
import SearchInput from '@/Components/UI/SearchInput';
import { useRestaurantMenu } from '@/Hooks/useRestaurantMenu';

interface Props {
  restaurant: Restaurant;
  mode?: 'customer' | 'employee';
}

export default function RestaurantMenu({
  restaurant,
  mode = 'customer',
}: Props) {
  const { query, setQuery, displayedCategories } =
    useRestaurantMenu(restaurant);

  return (
    <div className="restaurant-menu-list">
      <div className="menu-search">
        <SearchInput
          value={query}
          onChange={setQuery}
          placeholder="Search menu..."
        />
      </div>

      {displayedCategories?.length ? (
        displayedCategories.map((category) => (
          <div key={category.id} className="menu-category">
            <h3 className="category-title">{category.name}</h3>

            <div className="menu-items-list">
              {category.menu_items.map((item) => (
                <MenuItemCard
                  key={item.id}
                  item={item}
                  restaurantId={restaurant.id}
                  mode={mode}
                />
              ))}
            </div>
          </div>
        ))
      ) : query ? (
        <div className="no-results">
          <p>No menu items found matching "{query}".</p>
        </div>
      ) : (
        <div className="no-results">
          <p>No menu items available.</p>
        </div>
      )}
    </div>
  );
}
