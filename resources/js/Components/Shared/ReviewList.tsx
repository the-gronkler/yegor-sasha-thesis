import { Review } from '@/types/models';
import { ReviewItem } from './ReviewItem';

interface Props {
  reviews: Review[];
}

export default function ReviewList({ reviews }: Props) {
  if (!reviews || reviews.length === 0) {
    return (
      <div className="review-list-container">
        <div className="no-reviews">
          No reviews yet. Be the first to review!
        </div>
      </div>
    );
  }

  return (
    <div className="review-list-container">
      <h3 className="section-title">Reviews</h3>
      <div className="reviews-divider">
        {reviews.map((review) => (
          <ReviewItem key={review.id} review={review} />
        ))}
      </div>
    </div>
  );
}
