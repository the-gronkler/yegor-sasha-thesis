<?php

namespace App\Services;

use App\Models\Review;
use App\Models\ReviewImage;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class ReviewService
{
    public function createReview(array $data, int $userId, ?array $images = []): array
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

        return ['review' => $review, 'upload_errors' => $uploadErrors];
    }

    public function updateReview(Review $review, array $data, ?array $newImages = [], ?array $deletedImageIds = []): array
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

        return ['review' => $review, 'upload_errors' => $uploadErrors];
    }

    public function deleteReview(Review $review): void
    {
        // Delete all associated images from storage
        foreach ($review->images as $image) {
            $this->deleteImageFromStorage($image->image);
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
                Log::error(
                    sprintf(
                        'Failed to upload image for review %d%s due to exception: %s',
                        $review->id,
                        $originalName ? " (filename: {$originalName})" : '',
                        $e->getMessage()
                    )
                );
                $failedUploads[] = $originalName ?? 'unknown file';

                continue;
            }

            if (! $path) {
                Log::error(
                    sprintf(
                        'Failed to upload image for review %d%s: storage returned empty path',
                        $review->id,
                        $originalName ? " (filename: {$originalName})" : ''
                    )
                );
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

    protected function deleteImageFromStorage(string $path): void
    {
        try {
            if ($path) {
                Storage::disk('r2')->delete($path);
            }
        } catch (\Exception $e) {
            Log::error("Failed to delete review image from R2: {$path}. Error: ".$e->getMessage());
        }
    }
}
