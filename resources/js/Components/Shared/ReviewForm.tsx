import { useForm } from '@inertiajs/react';
import { FormEventHandler } from 'react';
import InteractiveStarRating from './InteractiveStarRating';
import Button from '@/Components/UI/Button';
import { Review } from '@/types/models';

interface Props {
  restaurantId: number;
  review?: Review;
  onCancel?: () => void;
  onSuccess?: () => void;
}

// TODO: add support for uploading images
export default function ReviewForm({
  restaurantId,
  review,
  onCancel,
  onSuccess,
}: Props) {
  const { data, setData, post, put, processing, errors, reset } = useForm({
    restaurant_id: restaurantId,
    rating: review?.rating || 0,
    title: review?.title || '',
    content: review?.content || '',
  });

  const submit: FormEventHandler = (e) => {
    e.preventDefault();
    if (review) {
      put(route('reviews.update', review.id), {
        onSuccess: () => {
          reset();
          onSuccess?.();
        },
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
