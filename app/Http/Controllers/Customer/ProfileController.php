<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Services\GeoService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Inertia\Inertia;

class ProfileController extends Controller
{
    protected GeoService $geoService;

    public function __construct(GeoService $geoService)
    {
        $this->geoService = $geoService;
    }

    /**
     * Show the profile overview page with navigation menu.
     */
    public function show(Request $request)
    {
        $user = $request->user();
        $this->authorize('view', $user);

        $customer = $user->customer;

        // Get stats for the overview
        $favoriteCount = $customer->favoriteRestaurants()->count();
        $orderCount = $customer->orders()->whereHas('status', function ($q) {
            $q->where('name', '!=', 'In Cart');
        })->count();

        return Inertia::render('Customer/Profile/Index', [
            'user' => $user->only(['id', 'name', 'surname', 'email']),
            'stats' => [
                'favoriteCount' => $favoriteCount,
                'orderCount' => $orderCount,
            ],
        ]);
    }

    /**
     * Show the profile edit form.
     */
    public function edit(Request $request)
    {
        $user = $request->user();
        $this->authorize('update', $user);

        $customer = $user->customer;

        return Inertia::render('Customer/Profile/Edit', [
            'user' => $user->only(['id', 'name', 'surname', 'email']),
            'customer' => [
                'payment_method_token' => $customer->payment_method_token,
            ],
        ]);
    }

    /**
     * Update the customer's profile data.
     */
    public function update(Request $request)
    {
        $user = $request->user();
        $this->authorize('update', $user);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'surname' => 'nullable|string|max:255',
            'email' => 'required|email|max:255|unique:users,email,'.$user->id,
            'password' => 'nullable|string|min:8|confirmed',
        ]);

        $user->name = $validated['name'];
        $user->surname = $validated['surname'] ?? null;
        $user->email = $validated['email'];
        if (! empty($validated['password'])) {
            $user->password = Hash::make($validated['password']);
        }
        $user->save();

        // Get or create customer record
        $customer = $user->customer;
        if (! $customer) {
            $customer = $user->customer()->create([
                'user_id' => $user->id,
            ]);
        }

        // Update customer details
        $this->authorize('update', $customer);
        $customer->update([
            'payment_method_token' => $request->input('payment_method_token'),
        ]);

        return back()->with('success', 'Profile updated.');
    }

    /**
     * Delete the customer's account (and related customer record).
     */
    public function destroy(Request $request)
    {
        $user = $request->user();
        $this->authorize('delete', $user);

        // Optionally you can soft-delete or cascade delete
        $user->customer()->delete();
        $user->delete();

        auth()->logout();

        return redirect()->route('home')->with('success', 'Account deleted.');
    }

    /**
     * Show favorites list page.
     */
    public function favorites(Request $request)
    {
        $user = $request->user();
        $customer = $user->customer;

        // Try to get last known coordinates from session for distance calculation
        $geo = $this->geoService->getValidGeoFromSession($request);
        $lat = $geo['lat'] ?? null;
        $lng = $geo['lng'] ?? null;

        // Get favorite restaurants with complete data
        $query = $customer->favoriteRestaurants()
            ->select([
                'restaurants.id',
                'restaurants.name',
                'restaurants.address',
                'restaurants.latitude',
                'restaurants.longitude',
                'restaurants.rating',
                'restaurants.description',
                'restaurants.opening_hours',
                'favorite_restaurants.rank',
            ])
            ->with(['images:id,restaurant_id,image,is_primary_for_restaurant'])
            ->orderBy('favorite_restaurants.rank');

        if ($lat !== null && $lng !== null) {
            $query->withDistanceTo($lat, $lng);
        }

        $favorites = $query->get()->map(function ($restaurant) {
            return [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'address' => $restaurant->address,
                'latitude' => $restaurant->latitude,
                'longitude' => $restaurant->longitude,
                'rating' => $restaurant->rating,
                'description' => $restaurant->description,
                'opening_hours' => $restaurant->opening_hours,
                'rank' => $restaurant->pivot->rank,
                'distance' => isset($restaurant->distance)
                    ? $this->geoService->formatDistance($restaurant->distance)
                    : null,
                'images' => $restaurant->images->map(fn ($img) => [
                    'id' => $img->id,
                    'url' => $img->url,
                    'is_primary_for_restaurant' => $img->is_primary_for_restaurant,
                ]),
            ];
        });

        return Inertia::render('Customer/Profile/Favorites', [
            'favorites' => $favorites,
        ]);
    }

    /**
     * Update favorite restaurant ranks.
     */
    public function updateFavoriteRanks(Request $request)
    {
        $user = $request->user();
        $customer = $user->customer;

        // Get total number of favorites to set max rank constraint
        $totalFavorites = $customer->favoriteRestaurants()->count();

        $validated = $request->validate([
            'ranks' => 'required|array',
            'ranks.*.restaurant_id' => [
                'required',
                'integer',
                'exists:restaurants,id',
                function ($attribute, $value, $fail) use ($customer) {
                    if (! $customer->favoriteRestaurants()->where('restaurant_id', $value)->exists()) {
                        $fail('The selected restaurant is not in your favorites.');
                    }
                },
            ],
            'ranks.*.rank' => "required|integer|min:1|max:{$totalFavorites}|distinct",
        ]);

        foreach ($validated['ranks'] as $item) {
            $customer->favoriteRestaurants()->updateExistingPivot(
                $item['restaurant_id'],
                ['rank' => $item['rank']]
            );
        }

        return back()->with('success', 'Favorites order updated!');
    }
}
