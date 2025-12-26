interface Props {
  rating: number;
  onRatingChange: (rating: number) => void;
}

export default function InteractiveStarRating({
  rating,
  onRatingChange,
}: Props) {
  const stars = [1, 2, 3, 4, 5];

  return (
    <div className="interactive-star-rating">
      {stars.map((star) => (
        <button
          key={star}
          type="button"
          onClick={() => onRatingChange(star)}
          className={`star-btn ${star <= rating ? 'active' : ''}`}
        >
          ★
        </button>
      ))}
    </div>
  );
}
