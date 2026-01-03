<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Services\ReviewService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class ReviewController extends Controller
{
    protected ReviewService $reviewService;

    public function __construct(ReviewService $reviewService)
    {
        $this->reviewService = $reviewService;
    }

    /**
     * Display a listing of reviews (for the authenticated customer).
     */
    public function index(Request $request)
    {
        $this->authorize('viewAny', Review::class);

        $customerUserId = Auth::id(); // assuming customers use users table
        $reviews = Review::with(['restaurant:id,name,address', 'images' => function ($query) {
            $query->valid();
        }])
            ->where('customer_user_id', $customerUserId)
            ->latest()
            ->get(['id', 'rating', 'title', 'content', 'restaurant_id', 'created_at']);

        return Inertia::render('Customer/Reviews/Index', [
            'reviews' => $reviews,
        ]);
    }

    /**
     * Store a newly created review.
     */
    public function store(Request $request)
    {
        $this->authorize('create', Review::class);

        $validated = $request->validate([
            'restaurant_id' => 'required|integer|exists:restaurants,id',
            'rating' => 'required|integer|min:1|max:5',
            'title' => 'required|string|max:255',
            'content' => 'nullable|string|max:1024',
            'images' => 'nullable|array|max:'.Review::MAX_IMAGES,
            'images.*' => 'image|max:5120', // 5MB max
        ]);

        try {
            $result = $this->reviewService->createReview(
                $validated,
                Auth::id(),
                $request->file('images')
            );

            if (! empty($result->uploadErrors)) {
                return back()->with('success', 'Review submitted successfully, but some images failed to upload: '.implode(', ', $result->uploadErrors));
            }
        } catch (\Illuminate\Database\UniqueConstraintViolationException $e) {
            return back()->with('error', 'You have already reviewed this restaurant. Edit your existing review instead.');
        }

        return back()->with('success', 'Review submitted successfully.');
    }

    /**
     * Update the specified review.
     */
    public function update(Request $request, Review $review)
    {
        $this->authorize('update', $review);

        $validated = $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'title' => 'required|string|max:255',
            'content' => 'nullable|string|max:1024',
            'images' => 'nullable|array|max:'.Review::MAX_IMAGES,
            'images.*' => 'image|max:5120',
            'deleted_image_ids' => 'nullable|array',
            'deleted_image_ids.*' => 'integer|exists:review_images,id',
        ]);

        $result = $this->reviewService->updateReview(
            $review,
            $validated,
            $request->file('images'),
            $validated['deleted_image_ids'] ?? []
        );

        if (! empty($result->uploadErrors)) {
            return back()->with('success', 'Review updated successfully, but some images failed to upload: '.implode(', ', $result->uploadErrors));
        }

        return back()->with('success', 'Review updated successfully.');
    }

    /**
     * Remove the specified review.
     */
    public function destroy(Review $review)
    {
        $this->authorize('delete', $review);

        $this->reviewService->deleteReview($review);

        return back()->with('success', 'Review deleted successfully.');
    }
}
