import { useState, useMemo } from 'react';
import { router, usePage } from '@inertiajs/react';
import { PageProps } from '@/types';
import { Review } from '@/types/models';

/**
 * Custom hook to manage restaurant reviews.
 *
 * This hook separates the current user's review from other reviews and provides
 * state and handlers for managing the review editing and deletion process.
 *
 * @param {Review[]} reviews - The list of reviews for the restaurant.
 * @returns {object} An object containing:
 *   - userReview: The review belonging to the authenticated user, if it exists.
 *   - otherReviews: The list of reviews from other users.
 *   - isEditingReview: Boolean indicating if the user is currently editing their review.
 *   - setIsEditingReview: Function to set the editing state.
 *   - handleDeleteReview: Function to delete the user's review.
 */
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
