import { FormEventHandler, useState } from 'react';
import AppLayout from '@/Layouts/AppLayout';
import { Head, Link, useForm, router } from '@inertiajs/react';
import {
  ArrowLeftIcon,
  PhotoIcon,
  PlusIcon,
  TrashIcon,
} from '@heroicons/react/24/outline';
import { PageProps } from '@/types';
import Button from '@/Components/UI/Button';

interface Image {
  id: number;
  url: string;
  is_primary_for_restaurant: boolean;
  description: string | null;
}

interface PhotosProps extends PageProps {
  images: Image[];
}

export default function Photos({ images }: PhotosProps) {
  const [showUploadForm, setShowUploadForm] = useState(false);
  const { data, setData, post, processing, errors, reset } = useForm({
    image: null as File | null,
    description: '',
    is_primary: false,
  });

  const handleUploadImage: FormEventHandler = (e) => {
    e.preventDefault();

    if (!data.image) {
      return;
    }

    post(route('employee.establishment.images.store'), {
      onSuccess: () => {
        reset();
        setShowUploadForm(false);
      },
    });
  };

  const handleDeleteImage = (imageId: number) => {
    if (!window.confirm('Are you sure you want to delete this image?')) {
      return;
    }

    router.delete(route('employee.establishment.images.destroy', imageId));
  };

  const handleSetPrimary = (imageId: number) => {
    router.put(route('employee.establishment.images.set-primary', imageId));
  };

  return (
    <AppLayout>
      <Head title="Manage Photos" />

      <div className="profile-page">
        {/* Header */}
        <div className="profile-header">
          <Link
            href={route('employee.establishment.index')}
            className="back-button-link"
          >
            <ArrowLeftIcon className="icon" />
            <span>Back</span>
          </Link>
          <h1 className="profile-title">Manage Photos</h1>
        </div>

        {/* Photos Management */}
        <div className="profile-card">
          <div className="section-header">
            <h3 className="section-title">Restaurant Photos</h3>
            <button
              type="button"
              onClick={() => setShowUploadForm(!showUploadForm)}
              className="btn-icon btn-add"
            >
              <PlusIcon className="icon" />
            </button>
          </div>

          {/* Upload Form */}
          {showUploadForm && (
            <form
              onSubmit={handleUploadImage}
              className="profile-form add-worker-form"
            >
              <div className="form-group">
                <label htmlFor="image">Upload Image</label>
                <input
                  id="image"
                  type="file"
                  accept="image/*"
                  className="form-input"
                  onChange={(e) =>
                    setData('image', e.target.files?.[0] || null)
                  }
                  required
                />
                {errors.image && (
                  <p className="error-message">{errors.image}</p>
                )}
              </div>

              <div className="form-group">
                <label htmlFor="description">Description (Optional)</label>
                <input
                  id="description"
                  type="text"
                  className="form-input"
                  value={data.description}
                  onChange={(e) => setData('description', e.target.value)}
                  placeholder="Describe this photo..."
                />
              </div>

              <div className="form-group checkbox-group">
                <label className="checkbox-label">
                  <input
                    type="checkbox"
                    checked={data.is_primary}
                    onChange={(e) => setData('is_primary', e.target.checked)}
                  />
                  <span>Set as primary image</span>
                </label>
              </div>

              <div className="form-actions">
                <button
                  type="button"
                  onClick={() => setShowUploadForm(false)}
                  className="btn-secondary"
                >
                  Cancel
                </button>
                <Button type="submit" disabled={processing}>
                  Upload Photo
                </Button>
              </div>
            </form>
          )}

          {/* Photos Grid */}
          <div className="photos-grid">
            {images.map((image) => (
              <div key={image.id} className="photo-item">
                <img
                  src={image.url}
                  alt={image.description || 'Restaurant photo'}
                  className="photo-image"
                />
                {image.is_primary_for_restaurant && (
                  <span className="photo-badge">Primary</span>
                )}
                <div className="photo-actions">
                  {!image.is_primary_for_restaurant && (
                    <button
                      type="button"
                      onClick={() => handleSetPrimary(image.id)}
                      className="btn-photo-action"
                    >
                      Set as Primary
                    </button>
                  )}
                  <button
                    type="button"
                    onClick={() => handleDeleteImage(image.id)}
                    className="btn-photo-action btn-danger"
                  >
                    <TrashIcon className="icon" />
                  </button>
                </div>
              </div>
            ))}

            {images.length === 0 && (
              <div className="empty-state">
                <PhotoIcon className="empty-icon" />
                <p className="empty-text">No photos yet</p>
                <p className="empty-description">
                  Add photos to showcase your restaurant
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </AppLayout>
  );
}
