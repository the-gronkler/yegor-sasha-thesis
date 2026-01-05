import { useState } from 'react';
import { router } from '@inertiajs/react';
import { Restaurant, FoodType } from '@/types/models';
import {
  XMarkIcon,
  PlusIcon,
  PencilIcon,
  TrashIcon,
} from '@heroicons/react/24/outline';

interface Props {
  restaurant: Restaurant;
  onClose: () => void;
}

export default function ManageCategoriesModal({ restaurant, onClose }: Props) {
  const categories: FoodType[] = restaurant.food_types || [];
  const [newCategoryName, setNewCategoryName] = useState('');
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editingName, setEditingName] = useState('');

  const handleAdd = () => {
    if (!newCategoryName.trim()) return;
    router.post(
      route('employee.restaurant.menu-categories.store'),
      {
        name: newCategoryName,
      },
      {
        onSuccess: () => {
          setNewCategoryName('');
          router.reload();
        },
      },
    );
  };

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
        onSuccess: () => {
          setEditingId(null);
          setEditingName('');
          router.reload();
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
        onSuccess: () => router.reload(),
      },
    );
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="manage-categories-modal"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="modal-header">
          <h2>Manage Categories</h2>
          <button className="close-btn" onClick={onClose} aria-label="Close">
            <XMarkIcon className="icon-sm" />
          </button>
        </div>
        <div className="modal-body">
          <div className="add-category">
            <input
              type="text"
              value={newCategoryName}
              onChange={(e) => setNewCategoryName(e.target.value)}
              placeholder="New category name"
            />
            <button className="btn-primary" onClick={handleAdd}>
              <PlusIcon className="icon-sm" />
              Add
            </button>
          </div>
          <ul className="categories-list">
            {categories.map((category) => (
              <li key={category.id} className="category-item">
                {editingId === category.id ? (
                  <>
                    <input
                      type="text"
                      value={editingName}
                      onChange={(e) => setEditingName(e.target.value)}
                    />
                    <button onClick={() => handleRename(category.id)}>
                      Save
                    </button>
                    <button onClick={() => setEditingId(null)}>Cancel</button>
                  </>
                ) : (
                  <>
                    <span>{category.name}</span>
                    <button
                      onClick={() => {
                        setEditingId(category.id);
                        setEditingName(category.name);
                      }}
                    >
                      <PencilIcon className="icon-sm" />
                    </button>
                    <button onClick={() => handleDelete(category.id)}>
                      <TrashIcon className="icon-sm" />
                    </button>
                  </>
                )}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}
