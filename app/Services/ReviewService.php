<?php

namespace App\Services;

use App\Models\Review;
use App\Models\ReviewImage;
use App\Services\Results\ReviewOperationResult;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class ReviewService
{
    public function createReview(array $data, int $userId, ?array $images = []): ReviewOperationResult
    {
        $review = Review::create([
            'customer_user_id' => $userId,
            'restaurant_id' => $data['restaurant_id'],
            'rating' => $data['rating'],
            'title' => $data['title'],
            'content' => $data['content'] ?? null,
        ]);

        $uploadErrors = [];
        if (! empty($images)) {
            $uploadErrors = $this->uploadImages($review, $images);
        }

        return new ReviewOperationResult($review, $uploadErrors);
    }

    public function updateReview(Review $review, array $data, ?array $newImages = [], ?array $deletedImageIds = []): ReviewOperationResult
    {
        $review->update([
            'rating' => $data['rating'],
            'title' => $data['title'],
            'content' => $data['content'] ?? null,
        ]);

        if (! empty($deletedImageIds)) {
            $this->deleteImages($review, $deletedImageIds);
        }

        $uploadErrors = [];
        if (! empty($newImages)) {
            $uploadErrors = $this->uploadImages($review, $newImages);
        }

        return new ReviewOperationResult($review, $uploadErrors);
    }

    public function deleteReview(Review $review): void
    {
        $failedDeletions = [];

        // Delete all associated images from storage
        foreach ($review->images as $image) {
            if (! $this->deleteImageFromStorage($image->image)) {
                $failedDeletions[] = $image->image;
            }
        }

        if (! empty($failedDeletions)) {
            Log::warning("Review {$review->id} deleted, but some images could not be removed from storage.", [
                'review_id' => $review->id,
                'failed_images' => $failedDeletions,
            ]);
        }

        $review->delete();
    }

    protected function uploadImages(Review $review, array $images): array
    {
        $failedUploads = [];

        foreach ($images as $image) {
            $originalName = method_exists($image, 'getClientOriginalName') ? $image->getClientOriginalName() : null;
            $path = null;

            try {
                $path = $image->store('reviews', 'r2');
            } catch (\Exception $e) {
                Log::error("Failed to upload image for review {$review->id}.", [
                    'review_id' => $review->id,
                    'filename' => $originalName,
                    'exception' => $e->getMessage(),
                ]);
                $failedUploads[] = $originalName ?? 'unknown file';

                continue;
            }

            if (! $path) {
                Log::error("Failed to upload image for review {$review->id}: storage returned empty path.", [
                    'review_id' => $review->id,
                    'filename' => $originalName,
                ]);
                $failedUploads[] = $originalName ?? 'unknown file';

                continue;
            }

            // Store the path, not the full URL
            ReviewImage::create([
                'review_id' => $review->id,
                'image' => $path,
            ]);
        }

        return $failedUploads;
    }

    protected function deleteImages(Review $review, array $imageIds): void
    {
        $imagesToDelete = ReviewImage::whereIn('id', $imageIds)
            ->where('review_id', $review->id)
            ->get();

        foreach ($imagesToDelete as $img) {
            $this->deleteImageFromStorage($img->image);
            $img->delete();
        }
    }

    protected function deleteImageFromStorage(string $path): bool
    {
        try {
            if ($path) {
                return Storage::disk('r2')->delete($path);
            }

            return true;
        } catch (\Exception $e) {
            Log::error("Failed to delete review image from R2: {$path}. Error: ".$e->getMessage());

            return false;
        }
    }
}
