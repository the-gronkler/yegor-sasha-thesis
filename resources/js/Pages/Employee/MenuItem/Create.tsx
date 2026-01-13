import React, { useEffect, useRef } from 'react';
import { Head, useForm, Link } from '@inertiajs/react';
import AppLayout from '@/Layouts/AppLayout';
import { FoodType, Allergen, Image } from '@/types/models';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';
import MenuItemPhotos from '@/Components/Shared/MenuItemPhotos';

interface Props {
  foodTypes: FoodType[];
  allergens: Allergen[];
  restaurantImages: Image[];
  preselectedFoodTypeId?: number;
}

export default function CreateMenuItem({
  foodTypes,
  allergens,
  restaurantImages,
  preselectedFoodTypeId,
}: Props) {
  const backUrl = route('employee.menu.index');

  const { data, setData, post, processing, errors } = useForm({
    name: '',
    description: '',
    price: '' as string | number,
    food_type_id: preselectedFoodTypeId || (foodTypes[0]?.id ?? 0),
    is_available: true,
    allergens: [] as number[],
    image_id: null as number | null,
  });

  const descriptionRef = useRef<HTMLTextAreaElement>(null);

  // Auto-resize textarea function
  const autoResize = (textarea: HTMLTextAreaElement | null) => {
    if (textarea) {
      textarea.style.height = 'auto';
      textarea.style.height = textarea.scrollHeight + 'px';
    }
  };

  // Auto-resize on mount and when description changes
  useEffect(() => {
    autoResize(descriptionRef.current);
  }, [data.description]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    post(route('employee.restaurant.menu-items.store'));
  };

  const handleAllergenChange = (allergenId: number) => {
    const currentAllergens = [...data.allergens];
    if (currentAllergens.includes(allergenId)) {
      setData(
        'allergens',
        currentAllergens.filter((id) => id !== allergenId),
      );
    } else {
      setData('allergens', [...currentAllergens, allergenId]);
    }
  };

  return (
    <AppLayout>
      <Head title="Create Menu Item" />

      <div className="menu-item-edit-page">
        <div className="page-header">
          <div className="header-left">
            <Link href={backUrl} className="back-link" aria-label="Back">
              <ArrowLeftIcon className="icon" />
            </Link>
            <h1 className="page-title">Create Menu Item</h1>
          </div>
        </div>

        <div className="edit-form-container">
          <form onSubmit={handleSubmit} className="edit-form">
            {/* Name */}
            <div className="form-group">
              <label htmlFor="name">Name</label>
              <input
                type="text"
                id="name"
                value={data.name}
                onChange={(e) => setData('name', e.target.value)}
                className={errors.name ? 'error' : ''}
                required
              />
              {errors.name && (
                <div className="error-message">{errors.name}</div>
              )}
            </div>

            {/* Description */}
            <div className="form-group">
              <label htmlFor="description">Description</label>
              <textarea
                ref={descriptionRef}
                id="description"
                value={data.description}
                onChange={(e) => setData('description', e.target.value)}
                onInput={(e) => autoResize(e.currentTarget)}
                className={
                  errors.description
                    ? 'error auto-resize-textarea'
                    : 'auto-resize-textarea'
                }
                style={{ resize: 'none', overflow: 'hidden' }}
                rows={3}
              />
              {errors.description && (
                <div className="error-message">{errors.description}</div>
              )}
            </div>

            {/* Price */}
            <div className="form-group">
              <label htmlFor="price">Price (€)</label>
              <input
                type="number"
                id="price"
                step="0.01"
                min="0"
                required
                value={data.price}
                onChange={(e) => {
                  const value = e.target.value;
                  // @ts-ignore - Inertia's useForm types are strict about the initial type, but we need to allow empty string for controlled inputs
                  setData('price', value === '' ? '' : parseFloat(value));
                }}
                className={errors.price ? 'error' : ''}
              />
              {errors.price && (
                <div className="error-message">{errors.price}</div>
              )}
            </div>

            {/* Category */}
            <div className="form-group">
              <label htmlFor="food_type_id">Category</label>
              <select
                id="food_type_id"
                value={data.food_type_id}
                onChange={(e) =>
                  setData('food_type_id', Number(e.target.value))
                }
                className={errors.food_type_id ? 'error' : ''}
              >
                {foodTypes.map((type) => (
                  <option key={type.id} value={type.id}>
                    {type.name}
                  </option>
                ))}
              </select>
              {errors.food_type_id && (
                <div className="error-message">{errors.food_type_id}</div>
              )}
            </div>

            {/* Availability */}
            <div className="form-group checkbox-group">
              <label className="checkbox-label">
                <input
                  type="checkbox"
                  checked={data.is_available}
                  onChange={(e) => setData('is_available', e.target.checked)}
                />
                Available for order
              </label>
            </div>

            {/* Allergens */}
            <div className="form-group">
              <label>Allergens</label>
              <div className="allergens-grid">
                {allergens.map((allergen) => (
                  <label key={allergen.id} className="checkbox-label">
                    <input
                      type="checkbox"
                      checked={data.allergens.includes(allergen.id)}
                      onChange={() => handleAllergenChange(allergen.id)}
                    />
                    {allergen.name}
                  </label>
                ))}
              </div>
            </div>

            <div className="form-actions">
              <button
                type="submit"
                className="btn-primary"
                disabled={processing}
              >
                {processing ? 'Creating...' : 'Create Menu Item'}
              </button>
            </div>
          </form>

          {/* Photos Section */}
          <div className="photos-section">
            <MenuItemPhotos
              restaurantImages={restaurantImages}
              selectedImageId={data.image_id}
              onSelectImage={(imageId) => setData('image_id', imageId)}
            />
          </div>
        </div>
      </div>
    </AppLayout>
  );
}
