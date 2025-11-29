<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Inertia\Inertia;

class ProfileController extends Controller
{
    /**
     * Show the customer's own profile & data.
     */
    public function show(Request $request)
    {
        $user = $request->user();
        $this->authorize('view', $user);

        $customer = $user->customer; // assuming one-to-one relationship

        // Prepare favorites maybe
        $favorites = $customer->favoriteRestaurants()
            ->select(['restaurants.id', 'restaurants.name', 'favorite_restaurants.rank'])
            ->orderBy('favorite_restaurants.rank')
            ->get();

        return Inertia::render('Customer/Profile/Show', [
            'user' => $user->only(['id', 'name', 'surname', 'email']),
            'customer' => [
                'payment_method_token' => $customer->payment_method_token,
            ],
            'favorites' => $favorites,
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
        $user->surname = $validated['surname'] ?? $user->surname;
        $user->email = $validated['email'];
        if (! empty($validated['password'])) {
            $user->password = Hash::make($validated['password']);
        }
        $user->save();

        // If you also allow updating customer details:
        if ($user->customer) {
            $this->authorize('update', $user->customer);
            $user->customer()->update([
                'payment_method_token' => $request->input('payment_method_token'),
            ]);
        }

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
     * Additional method: show favorites list if separate.
     */
    public function favorites(Request $request)
    {
        $customer = $request->user()->customer;

        $favorites = $customer->favoriteRestaurants()
            ->with('restaurant:id,name,address')
            ->orderBy('favorite_restaurants.rank')
            ->get();

        return Inertia::render('Customer/Profile/Favorites', [
            'favorites' => $favorites,
        ]);
    }
}
