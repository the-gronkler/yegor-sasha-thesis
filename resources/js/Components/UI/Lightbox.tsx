import { useEffect, useState, useCallback } from 'react';
import {
  XMarkIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
} from '@heroicons/react/24/outline';

interface LightboxProps {
  images: { id: number; url: string }[];
  initialIndex: number;
  isOpen: boolean;
  onClose: () => void;
}

export default function Lightbox({
  images,
  initialIndex,
  isOpen,
  onClose,
}: LightboxProps) {
  const [currentIndex, setCurrentIndex] = useState(initialIndex);

  useEffect(() => {
    setCurrentIndex(initialIndex);
  }, [initialIndex]);

  const prevImage = useCallback(() => {
    setCurrentIndex((prev) => (prev === 0 ? images.length - 1 : prev - 1));
  }, [images.length]);

  const nextImage = useCallback(() => {
    setCurrentIndex((prev) => (prev === images.length - 1 ? 0 : prev + 1));
  }, [images.length]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (!isOpen) return;
      if (e.key === 'Escape') onClose();
      if (e.key === 'ArrowLeft') prevImage();
      if (e.key === 'ArrowRight') nextImage();
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose, prevImage, nextImage]);

  if (!isOpen) return null;

  return (
    <div
      className="lightbox-overlay"
      onClick={onClose}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ' || e.key === 'Spacebar') {
          onClose();
        }
      }}
    >
      <button
        className="lightbox-close"
        onClick={onClose}
        aria-label="Close lightbox"
      >
        <XMarkIcon className="icon" />
      </button>

      <div className="lightbox-content" onClick={(e) => e.stopPropagation()}>
        {images.length > 1 && (
          <button
            className="lightbox-nav prev"
            onClick={prevImage}
            aria-label="Previous image"
          >
            <ChevronLeftIcon className="icon" />
          </button>
        )}

        <img
          src={images[currentIndex].url}
          alt={`Image ${currentIndex + 1}`}
          className="lightbox-image"
        />

        {images.length > 1 && (
          <button
            className="lightbox-nav next"
            onClick={nextImage}
            aria-label="Next image"
          >
            <ChevronRightIcon className="icon" />
          </button>
        )}

        <div className="lightbox-counter">
          {currentIndex + 1} / {images.length}
        </div>
      </div>
    </div>
  );
}
