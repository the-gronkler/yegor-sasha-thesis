import { useState } from 'react';
import { router } from '@inertiajs/react';
import {
  PhotoIcon,
  CheckCircleIcon,
  ChevronDownIcon,
  ChevronUpIcon,
} from '@heroicons/react/24/outline';
import { Image } from '@/types/models';

interface MenuItemPhotosProps {
  menuItemId?: number; // undefined for create mode
  restaurantImages: Image[]; // All restaurant photos
  selectedImageId: number | null; // Currently selected photo for this menu item
  onSelectImage?: (imageId: number | null) => void; // Callback for create mode
}

export default function MenuItemPhotos({
  menuItemId,
  restaurantImages,
  selectedImageId,
  onSelectImage,
}: MenuItemPhotosProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  const handleSelectPhoto = (imageId: number) => {
    if (menuItemId) {
      // Edit mode - save to database
      router.put(
        route('employee.restaurant.menu-items.update-photo', {
          menu_item: menuItemId,
        }),
        {
          image_id: imageId,
        },
        {
          preserveScroll: true,
        },
      );
    } else if (onSelectImage) {
      // Create mode - update form state
      onSelectImage(imageId);
    }
  };

  const handleRemovePhoto = () => {
    if (menuItemId) {
      // Edit mode - save to database
      router.put(
        route('employee.restaurant.menu-items.update-photo', {
          menu_item: menuItemId,
        }),
        {
          image_id: null,
        },
        {
          preserveScroll: true,
        },
      );
    } else if (onSelectImage) {
      // Create mode - update form state
      onSelectImage(null);
    }
  };

  // Sort images: primary restaurant images first, then by creation date (newest first)
  const sortedImages = [...restaurantImages].sort((a, b) => {
    // Primary restaurant images first
    if (a.is_primary_for_restaurant && !b.is_primary_for_restaurant) return -1;
    if (!a.is_primary_for_restaurant && b.is_primary_for_restaurant) return 1;

    // Then by creation date (newest first)
    return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
  });

  // Get selected image for preview
  const selectedImage = restaurantImages.find(
    (img) => img.id === selectedImageId,
  );

  return (
    <div className="menu-item-photos">
      <div className="section-header">
        <h3 className="section-title">Menu Item Photo</h3>
        {selectedImageId && (
          <button
            type="button"
            onClick={handleRemovePhoto}
            className="btn-secondary-small"
          >
            Remove Selected
          </button>
        )}
      </div>

      {/* Selected Photo Preview */}
      {selectedImage && (
        <div className="selected-photo-preview">
          <img
            src={selectedImage.url}
            alt={selectedImage.description || 'Selected menu item photo'}
            className="preview-image"
          />
          <div className="preview-badge">
            <CheckCircleIcon className="icon-xs" />
            Currently Selected
          </div>
        </div>
      )}

      {/* Collapsible Photo Selector */}
      <div className="photo-selector">
        <button
          type="button"
          className="selector-toggle"
          onClick={() => setIsExpanded(!isExpanded)}
        >
          <span className="toggle-text">
            {selectedImage
              ? 'Change Photo'
              : 'Choose Photo (' + restaurantImages.length + ' available)'}
          </span>
          {isExpanded ? (
            <ChevronUpIcon className="icon-sm" />
          ) : (
            <ChevronDownIcon className="icon-sm" />
          )}
        </button>

        {isExpanded && (
          <div className="photos-grid">
            {sortedImages.map((image) => {
              const isSelected = image.id === selectedImageId;
              return (
                <div
                  key={image.id}
                  className={`photo-item ${isSelected ? 'selected' : ''}`}
                  onClick={() => handleSelectPhoto(image.id)}
                >
                  <img
                    src={image.url}
                    alt={image.description || 'Restaurant photo'}
                    className="photo-image"
                  />
                  <div className="photo-overlay">
                    <span className="select-text">
                      {isSelected ? 'Selected' : 'Click to select'}
                    </span>
                  </div>
                </div>
              );
            })}

            {restaurantImages.length === 0 && (
              <div className="empty-state">
                <PhotoIcon className="empty-icon" />
                <p className="empty-text">No restaurant photos available</p>
                <p className="empty-description">
                  Upload photos in the Restaurant Photos section first
                </p>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
