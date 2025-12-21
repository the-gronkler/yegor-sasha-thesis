import { Review } from '@/types/models';
import StarRating from './StarRating';

interface Props {
  review: Review;
}

export default function ReviewItem({ review }: Props) {
  return (
    <div className="review-item">
      <div className="review-header">
        <div className="review-author">{review.user_name || 'Anonymous'}</div>
        <div className="review-date">
          {new Date(review.created_at).toLocaleDateString()}
        </div>
      </div>
      <div className="review-rating">
        <StarRating rating={review.rating} />
      </div>
      <h4 className="review-title">{review.title}</h4>
      <p className="review-content">{review.content}</p>
    </div>
  );
}
