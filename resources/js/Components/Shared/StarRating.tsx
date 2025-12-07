interface StarRatingProps {
  rating: number;
}

export default function StarRating({ rating }: StarRatingProps) {
  // Create an array of 5 stars
  const stars = [1, 2, 3, 4, 5];

  return (
    <div className="star-rating">
      {stars.map((star) => (
        <span key={star} className={`star ${rating >= star ? 'filled' : ''}`}>
          ★
        </span>
      ))}
    </div>
  );
}
