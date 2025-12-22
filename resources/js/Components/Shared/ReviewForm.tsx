import { useForm } from '@inertiajs/react';
import { FormEventHandler } from 'react';
import InteractiveStarRating from './InteractiveStarRating';
import Button from '@/Components/UI/Button';
import { Review } from '@/types/models';
import ImageUploader from '@/Components/UI/ImageUploader';

interface Props {
  restaurantId: number;
  review?: Review;
  onCancel?: () => void;
  onSuccess?: () => void;
}

export default function ReviewForm({
  restaurantId,
  review,
  onCancel,
  onSuccess,
}: Props) {
  const { data, setData, post, processing, errors, reset } = useForm({
    restaurant_id: restaurantId,
    rating: review?.rating || 0,
    title: review?.title || '',
    content: review?.content || '',
    images: [] as File[],
    deleted_image_ids: [] as number[],
    // Method spoofing is required for file uploads via PUT/PATCH in Laravel
    // because PHP only parses multipart/form-data for POST requests.
    _method: review ? 'put' : undefined,
  });

  const submit: FormEventHandler = (e) => {
    e.preventDefault();
    if (review) {
      post(route('reviews.update', review.id), {
        onSuccess: () => {
          reset();
          onSuccess?.();
        },
        // Force Inertia to submit the request as FormData because this form includes file uploads (images)
        forceFormData: true,
      });
    } else {
      post(route('reviews.store'), {
        onSuccess: () => {
          reset();
          onSuccess?.();
        },
      });
    }
  };

  const handleAddFiles = (newFiles: File[]) => {
    setData('images', [...data.images, ...newFiles]);
  };

  const handleRemoveFile = (index: number) => {
    const newImages = [...data.images];
    newImages.splice(index, 1);
    setData('images', newImages);
  };

  const handleRemoveExisting = (imageId: number) => {
    setData('deleted_image_ids', [...data.deleted_image_ids, imageId]);
  };

  const existingImages =
    review?.images?.filter((img) => !data.deleted_image_ids.includes(img.id)) ||
    [];

  return (
    <div className="review-form-container">
      <h3 className="section-title">
        {review ? 'Edit Your Review' : 'Write a Review'}
      </h3>
      <form onSubmit={submit}>
        {errors.general && (
          <div className="form-error global-error">{errors.general}</div>
        )}
        <div className="form-group">
          <label className="form-label">Rating</label>
          <InteractiveStarRating
            rating={data.rating}
            onRatingChange={(rating) => setData('rating', rating)}
          />
          {errors.rating && <div className="form-error">{errors.rating}</div>}
        </div>

        <div className="form-group">
          <label htmlFor="title" className="form-label">
            Title
          </label>
          <input
            id="title"
            type="text"
            value={data.title}
            onChange={(e) => setData('title', e.target.value)}
            className="form-input"
            placeholder="Summarize your experience"
          />
          {errors.title && <div className="form-error">{errors.title}</div>}
        </div>

        <div className="form-group">
          <label htmlFor="content" className="form-label">
            Review
          </label>
          <textarea
            id="content"
            value={data.content}
            onChange={(e) => setData('content', e.target.value)}
            className="form-textarea"
            placeholder="Tell us more about your visit"
          />
          {errors.content && <div className="form-error">{errors.content}</div>}
        </div>

        <div className="form-group">
          <label className="form-label">Photos</label>
          <ImageUploader
            files={data.images}
            existingImages={existingImages}
            onAddFiles={handleAddFiles}
            onRemoveFile={handleRemoveFile}
            onRemoveExisting={handleRemoveExisting}
            error={errors.images}
          />
        </div>

        <div className="form-actions">
          {review && (
            <Button
              type="button"
              variant="secondary"
              onClick={onCancel}
              disabled={processing}
            >
              Cancel
            </Button>
          )}
          <Button disabled={processing}>
            {review ? 'Update Review' : 'Submit Review'}
          </Button>
        </div>
      </form>
    </div>
  );
}
