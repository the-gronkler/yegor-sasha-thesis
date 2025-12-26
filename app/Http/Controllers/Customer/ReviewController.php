<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class ReviewController extends Controller
{
    /**
     * Display a listing of reviews (for the authenticated customer).
     */
    public function index(Request $request)
    {
        $this->authorize('viewAny', Review::class);

        $customerUserId = Auth::id(); // assuming customers use users table
        $reviews = Review::with('restaurant:id,name,address')
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
        ]);

        try {
            Review::create([
                'customer_user_id' => Auth::id(),
                'restaurant_id' => $validated['restaurant_id'],
                'rating' => $validated['rating'],
                'title' => $validated['title'],
                'content' => $validated['content'] ?? null,
            ]);
        } catch (\Illuminate\Database\UniqueConstraintViolationException $e) {
            return back()->withErrors(['general' => 'You have already reviewed this restaurant. Edit your existing review instead.']);
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
        ]);

        $review->update([
            'rating' => $validated['rating'],
            'title' => $validated['title'],
            'content' => $validated['content'] ?? null,
        ]);

        return back()->with('success', 'Review updated successfully.');
    }

    /**
     * Remove the specified review.
     */
    public function destroy(Review $review)
    {
        $this->authorize('delete', $review);

        $review->delete();

        return back()->with('success', 'Review deleted successfully.');
    }
}
