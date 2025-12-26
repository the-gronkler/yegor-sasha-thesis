import { useState } from 'react';
import { Review } from '@/types/models';
import Lightbox from '@/Components/UI/Lightbox';

interface Props {
  images: Review['images'];
  userName?: string;
}

export function ReviewGallery({ images, userName }: Props) {
  const [isLightboxOpen, setIsLightboxOpen] = useState(false);
  const [lightboxIndex, setLightboxIndex] = useState(0);

  const openLightbox = (index: number) => {
    setLightboxIndex(index);
    setIsLightboxOpen(true);
  };

  if (!images || images.length === 0) {
    return null;
  }

  return (
    <>
      <div className="review-images">
        {images.map((image, index) => (
          <div
            key={image.id}
            className="review-image-wrapper"
            onClick={() => openLightbox(index)}
            role="button"
            tabIndex={0}
            aria-label={`View image ${index + 1} of ${images.length}`}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                openLightbox(index);
              }
            }}
          >
            <img
              src={image.url}
              alt={`Review by ${userName || 'Anonymous'}`}
              className="review-image"
              loading="lazy"
            />
          </div>
        ))}
      </div>

      <Lightbox
        images={images}
        initialIndex={lightboxIndex}
        isOpen={isLightboxOpen}
        onClose={() => setIsLightboxOpen(false)}
      />
    </>
  );
}
