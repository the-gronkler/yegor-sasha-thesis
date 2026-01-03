import React from 'react';
import { Head, useForm, Link } from '@inertiajs/react';
import AppLayout from '@/Layouts/AppLayout';
import { MenuItem, FoodType, Allergen } from '@/types/models';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';

interface Props {
  menuItem: MenuItem;
  foodTypes: FoodType[];
  allergens: Allergen[];
  queryParams?: { from?: string };
}

export default function EditMenuItem({
  menuItem,
  foodTypes,
  allergens,
  queryParams,
}: Props) {
  // Determine back URL based on query param
  const backUrl =
    queryParams?.from === 'show'
      ? route('employee.restaurant.menu-items.show', menuItem.id)
      : route('employee.menu.edit');

  const { data, setData, put, processing, errors } = useForm({
    name: menuItem.name,
    description: menuItem.description || '',
    price: menuItem.price,
    food_type_id: menuItem.food_type_id,
    is_available: menuItem.is_available,
    allergens: menuItem.allergens?.map((a) => a.id) || [],
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    put(route('employee.restaurant.menu-items.update', menuItem.id));
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
      <Head title={`Edit ${menuItem.name}`} />

      <div className="menu-item-edit-page">
        <div className="page-header">
          <div className="header-left">
            <Link href={backUrl} className="back-link" aria-label="Back">
              <ArrowLeftIcon className="icon" />
            </Link>
            <h1 className="page-title">Edit Item</h1>
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
              />
              {errors.name && (
                <div className="error-message">{errors.name}</div>
              )}
            </div>

            {/* Description */}
            <div className="form-group">
              <label htmlFor="description">Description</label>
              <textarea
                id="description"
                value={data.description}
                onChange={(e) => setData('description', e.target.value)}
                className={errors.description ? 'error' : ''}
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
                value={data.price}
                onChange={(e) => {
                  const value = e.target.value;
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
                onChange={(e) => {
                  const value = Number(e.target.value);
                  if (!Number.isNaN(value)) {
                    setData('food_type_id', value);
                  }
                }}
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
                {processing ? 'Saving...' : 'Save Changes'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </AppLayout>
  );
}
