import { useState, useMemo } from 'react';
import { router, usePage } from '@inertiajs/react';
import { PageProps } from '@/types';
import { Review } from '@/types/models';

export function useRestaurantReviews(reviews: Review[]) {
  const { auth } = usePage<PageProps>().props;
  const [isEditingReview, setIsEditingReview] = useState(false);

  const userReview = useMemo(
    () => reviews?.find((r) => r.customer_user_id === auth.user?.id),
    [reviews, auth.user?.id],
  );

  const otherReviews = useMemo(
    () => reviews?.filter((r) => r.customer_user_id !== auth.user?.id) || [],
    [reviews, auth.user?.id],
  );

  const handleDeleteReview = () => {
    if (!userReview) return;
    if (confirm('Are you sure you want to delete your review?')) {
      router.delete(route('reviews.destroy', userReview.id), {
        onSuccess: () => setIsEditingReview(false),
      });
    }
  };

  return {
    userReview,
    otherReviews,
    isEditingReview,
    setIsEditingReview,
    handleDeleteReview,
  };
}
