import { Restaurant } from '@/types/models';
import MenuItemCard from '@/Components/Shared/MenuItemCard';
import SearchInput from '@/Components/UI/SearchInput';
import { useRestaurantMenu } from '@/Hooks/useRestaurantMenu';
import {
  PencilIcon,
  TrashIcon,
  CheckIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline';
import { useState } from 'react';
import { router } from '@inertiajs/react';

interface Props {
  restaurant: Restaurant;
  mode?: 'customer' | 'employee' | 'employee-edit';
  isRestaurantAdmin?: boolean;
  isManagingCategories?: boolean;
}

export default function RestaurantMenu({
  restaurant,
  mode = 'customer',
  isRestaurantAdmin = false,
  isManagingCategories = false,
}: Props) {
  const { query, setQuery, displayedCategories } =
    useRestaurantMenu(restaurant);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editingName, setEditingName] = useState('');
  const [isAddingCategory, setIsAddingCategory] = useState(false);
  const [newCategoryName, setNewCategoryName] = useState('');

  const handleRename = (id: number) => {
    if (!editingName.trim()) return;
    router.put(
      route('employee.restaurant.menu-categories.update', {
        menu_category: id,
      }),
      {
        name: editingName,
      },
      {
        preserveScroll: true,
        onSuccess: () => {
          setEditingId(null);
          setEditingName('');
        },
      },
    );
  };

  const handleDelete = (id: number) => {
    if (!confirm('Are you sure you want to delete this category?')) return;
    router.delete(
      route('employee.restaurant.menu-categories.destroy', {
        menu_category: id,
      }),
      {
        preserveScroll: true,
      },
    );
  };

  const handleAddCategory = () => {
    if (!newCategoryName.trim()) return;
    router.post(
      route('employee.restaurant.menu-categories.store'),
      {
        name: newCategoryName,
      },
      {
        preserveScroll: true,
        onSuccess: () => {
          setNewCategoryName('');
          setIsAddingCategory(false);
        },
      },
    );
  };

  const handleAddMenuItem = (foodTypeId: number) => {
    router.visit(
      route('employee.restaurant.menu-items.create', {
        food_type_id: foodTypeId,
      }),
    );
  };

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
            <div className="category-header">
              {editingId === category.id ? (
                <div className="category-edit">
                  <input
                    type="text"
                    value={editingName}
                    onChange={(e) => setEditingName(e.target.value)}
                    autoFocus
                  />
                  <button
                    onClick={() => handleRename(category.id)}
                    aria-label="Save"
                  >
                    <CheckIcon className="icon-sm" />
                  </button>
                  <button
                    onClick={() => setEditingId(null)}
                    aria-label="Cancel"
                  >
                    <XMarkIcon className="icon-sm" />
                  </button>
                </div>
              ) : (
                <>
                  <h3 className="category-title">{category.name}</h3>
                  {isManagingCategories && isRestaurantAdmin && (
                    <div className="category-actions">
                      <button
                        onClick={() => {
                          setEditingId(category.id);
                          setEditingName(category.name);
                        }}
                        aria-label="Rename"
                      >
                        <PencilIcon className="icon-sm" />
                      </button>
                      <button
                        onClick={() => handleDelete(category.id)}
                        aria-label="Delete"
                      >
                        <TrashIcon className="icon-sm" />
                      </button>
                    </div>
                  )}
                </>
              )}
            </div>

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

            {mode === 'employee-edit' && isRestaurantAdmin && (
              <div className="add-menu-item">
                <button
                  onClick={() => handleAddMenuItem(category.id)}
                  className="btn-add-menu-item"
                >
                  + Add Menu Item
                </button>
              </div>
            )}
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

      {isManagingCategories && isRestaurantAdmin && (
        <div className="add-category">
          {isAddingCategory ? (
            <div className="category-edit">
              <input
                type="text"
                value={newCategoryName}
                onChange={(e) => setNewCategoryName(e.target.value)}
                placeholder="New category name"
                autoFocus
              />
              <button onClick={handleAddCategory} aria-label="Add">
                <CheckIcon className="icon-sm" />
              </button>
              <button
                onClick={() => setIsAddingCategory(false)}
                aria-label="Cancel"
              >
                <XMarkIcon className="icon-sm" />
              </button>
            </div>
          ) : (
            <button
              onClick={() => setIsAddingCategory(true)}
              className="btn-add-category"
            >
              + Add Category
            </button>
          )}
        </div>
      )}
    </div>
  );
}
