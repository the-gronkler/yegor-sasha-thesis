import { PencilIcon, TrashIcon } from '@heroicons/react/24/outline';
import { Review } from '@/types/models';
import ReviewList from './ReviewList';
import ReviewForm from './ReviewForm';
import ReviewItem from './ReviewItem';
import { useRestaurantReviews } from '@/Hooks/useRestaurantReviews';

interface Props {
  restaurantId: number;
  reviews: Review[];
}

export default function RestaurantReviews({ restaurantId, reviews }: Props) {
  const {
    userReview,
    otherReviews,
    isEditingReview,
    setIsEditingReview,
    handleDeleteReview,
  } = useRestaurantReviews(reviews);

  return (
    <div className="reviews-section-wrapper">
      {userReview && !isEditingReview ? (
        <div className="review-list-container user-review">
          <div className="user-review-header">
            <h3 className="section-title">Your Review</h3>
            <div className="review-actions">
              <button
                onClick={() => setIsEditingReview(true)}
                className="edit-review-btn"
              >
                <PencilIcon className="icon" />
                Edit
              </button>
              <button
                onClick={handleDeleteReview}
                className="delete-review-btn"
              >
                <TrashIcon className="icon" />
                Delete
              </button>
            </div>
          </div>
          <ReviewItem review={userReview} />
        </div>
      ) : userReview && isEditingReview ? (
        <ReviewForm
          restaurantId={restaurantId}
          review={userReview}
          onCancel={() => setIsEditingReview(false)}
          onSuccess={() => setIsEditingReview(false)}
        />
      ) : (
        <ReviewForm restaurantId={restaurantId} />
      )}
      <ReviewList reviews={otherReviews} />
    </div>
  );
}
