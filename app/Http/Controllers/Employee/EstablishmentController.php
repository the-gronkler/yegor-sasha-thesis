<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\Image;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Inertia\Inertia;
use Inertia\Response;

class EstablishmentController extends Controller
{
    /**
     * Display the establishment management page (admins only).
     */
    public function index(Request $request): Response
    {
        $user = $request->user();
        $restaurant = $user->employee->restaurant;

        // Load restaurant with related data
        $restaurant->load([
            'employees.user',
            'images',
            'menuItems',
        ]);

        // Count statistics
        $stats = [
            'employeeCount' => $restaurant->employees->count(),
            'menuItemCount' => $restaurant->menuItems->count(),
            'imageCount' => $restaurant->images->count(),
        ];

        return Inertia::render('Employee/Establishment', [
            'restaurant' => $this->formatRestaurant($restaurant),
            'stats' => $stats,
        ]);
    }

    /**
     * Display the workers management page.
     */
    public function workers(Request $request): Response
    {
        $user = $request->user();
        $restaurant = $user->employee->restaurant;

        // Load employees with their user data
        $restaurant->load('employees.user');

        return Inertia::render('Employee/Establishment/Workers', [
            'employees' => $restaurant->employees->map(fn ($employee) => [
                'user_id' => $employee->user_id,
                'is_admin' => $employee->is_admin,
                'name' => $employee->user->name,
                'surname' => $employee->user->surname,
                'email' => $employee->user->email,
                'created_at' => $employee->created_at->toIso8601String(),
            ]),
        ]);
    }

    /**
     * Display the restaurant information page.
     */
    public function restaurant(Request $request): Response
    {
        $user = $request->user();
        $restaurant = $user->employee->restaurant;

        return Inertia::render('Employee/Establishment/RestaurantInfo', [
            'restaurant' => [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'address' => $restaurant->address,
                'description' => $restaurant->description,
                'opening_hours' => $restaurant->opening_hours,
                'latitude' => $restaurant->latitude,
                'longitude' => $restaurant->longitude,
            ],
            'mapboxPublicKey' => config('services.mapbox.public_key'),
        ]);
    }

    /**
     * Display the photos management page.
     */
    public function photos(Request $request): Response
    {
        $user = $request->user();
        $restaurant = $user->employee->restaurant;

        // Load images
        $restaurant->load('images');

        return Inertia::render('Employee/Establishment/Photos', [
            'images' => $restaurant->images->map(fn ($image) => [
                'id' => $image->id,
                'url' => $image->url,
                'is_primary_for_restaurant' => $image->is_primary_for_restaurant,
                'description' => $image->description,
            ]),
        ]);
    }

    /**
     * Store a new worker.
     */
    public function storeWorker(Request $request): RedirectResponse
    {
        $user = $request->user();
        $restaurant = $user->employee->restaurant;

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'surname' => ['nullable', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'confirmed', 'min:8'],
            'is_admin' => ['boolean'],
        ]);

        // Create new user and employee in a transaction
        DB::transaction(function () use ($validated, $restaurant) {
            $newUser = User::create([
                'name' => $validated['name'],
                'surname' => $validated['surname'] ?? null,
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'email_verified_at' => now(),
            ]);

            Employee::create([
                'user_id' => $newUser->id,
                'restaurant_id' => $restaurant->id,
                'is_admin' => $validated['is_admin'] ?? false,
            ]);
        });

        return back()->with('success', 'Employee added successfully.');
    }

    /**
     * Update a worker's information.
     */
    public function updateWorker(Request $request, User $user): RedirectResponse
    {
        $currentUser = $request->user();
        $restaurant = $currentUser->employee->restaurant;

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'surname' => ['nullable', 'string', 'max:255'],
            'email' => ['required', 'email', Rule::unique('users', 'email')->ignore($user->id)],
            'is_admin' => ['required', 'boolean'],
        ]);

        // Find the employee record
        $employee = Employee::where('user_id', $user->id)
            ->where('restaurant_id', $restaurant->id)
            ->firstOrFail();

        // Prevent removing own admin privileges
        if ($employee->user_id === $currentUser->id && $validated['is_admin'] === false) {
            return back()->withErrors([
                'error' => 'You cannot remove your own admin privileges.',
            ]);
        }

        // Update user information
        $user->update([
            'name' => $validated['name'],
            'surname' => $validated['surname'],
            'email' => $validated['email'],
        ]);

        // Update employee admin status
        $employee->update(['is_admin' => $validated['is_admin']]);

        return back()->with('success', 'Employee information updated successfully.');
    }

    /**
     * Remove a worker.
     */
    public function destroyWorker(Request $request, User $user): RedirectResponse
    {
        $currentUser = $request->user();
        $restaurant = $currentUser->employee->restaurant;

        // Find the employee record
        $employee = Employee::where('user_id', $user->id)
            ->where('restaurant_id', $restaurant->id)
            ->firstOrFail();

        // Prevent self-deletion
        if ($employee->user_id === $currentUser->id) {
            return back()->withErrors([
                'error' => 'You cannot remove yourself.',
            ]);
        }

        $employee->delete();

        return back()->with('success', 'Employee removed successfully.');
    }

    /**
     * Update restaurant information.
     */
    public function updateRestaurant(Request $request): RedirectResponse
    {
        $user = $request->user();
        $restaurant = $user->employee->restaurant;

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'address' => ['required', 'string', 'max:500'],
            'description' => ['nullable', 'string', 'max:1000'],
            'opening_hours' => ['nullable', 'string', 'max:500'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
        ]);

        $restaurant->update($validated);

        return back()->with('success', 'Restaurant information updated successfully.');
    }

    /**
     * Store a new image.
     */
    public function storeImage(Request $request): RedirectResponse
    {
        $user = $request->user();
        $restaurant = $user->employee->restaurant;

        $validated = $request->validate([
            'image' => ['required', 'image', 'max:5120'], // 5MB max
            'description' => ['nullable', 'string', 'max:255'],
            'is_primary' => ['boolean'],
        ]);

        // Store the image
        $path = $request->file('image')->store('restaurants', 'r2');

        // If this is set as primary, unset other primary images
        if ($validated['is_primary'] ?? false) {
            Image::where('restaurant_id', $restaurant->id)
                ->update(['is_primary_for_restaurant' => false]);
        }

        // Create image record
        Image::create([
            'restaurant_id' => $restaurant->id,
            'image' => $path,
            'description' => $validated['description'] ?? null,
            'is_primary_for_restaurant' => $validated['is_primary'] ?? false,
        ]);

        return back()->with('success', 'Image uploaded successfully.');
    }

    /**
     * Delete an image.
     */
    public function destroyImage(Request $request, Image $image): RedirectResponse
    {
        $user = $request->user();
        $restaurant = $user->employee->restaurant;

        // Ensure the image belongs to this restaurant
        if ($image->restaurant_id !== $restaurant->id) {
            abort(403);
        }

        // Delete the file from storage
        Storage::disk('r2')->delete($image->image);

        $image->delete();

        return back()->with('success', 'Image deleted successfully.');
    }

    /**
     * Set an image as primary.
     */
    public function setPrimaryImage(Request $request, Image $image): RedirectResponse
    {
        $user = $request->user();
        $restaurant = $user->employee->restaurant;

        // Ensure the image belongs to this restaurant
        if ($image->restaurant_id !== $restaurant->id) {
            abort(403);
        }

        DB::transaction(function () use ($restaurant, $image) {
            // Unset all primary images for this restaurant
            Image::where('restaurant_id', $restaurant->id)
                ->update(['is_primary_for_restaurant' => false]);

            // Set this image as primary
            $image->update(['is_primary_for_restaurant' => true]);
        });

        return back()->with('success', 'Primary image updated successfully.');
    }

    /**
     * Format restaurant data for frontend.
     */
    private function formatRestaurant($restaurant): array
    {
        return [
            'id' => $restaurant->id,
            'name' => $restaurant->name,
            'address' => $restaurant->address,
            'latitude' => $restaurant->latitude,
            'longitude' => $restaurant->longitude,
            'description' => $restaurant->description,
            'rating' => $restaurant->rating,
            'opening_hours' => $restaurant->opening_hours,
            'employees' => $restaurant->employees->map(fn ($employee) => [
                'user_id' => $employee->user_id,
                'is_admin' => $employee->is_admin,
                'name' => $employee->user->name,
                'surname' => $employee->user->surname,
                'email' => $employee->user->email,
                'created_at' => $employee->created_at->toIso8601String(),
            ]),
            'images' => $restaurant->images->map(fn ($image) => [
                'id' => $image->id,
                'url' => $image->url,
                'is_primary_for_restaurant' => $image->is_primary_for_restaurant,
                'description' => $image->description,
            ]),
        ];
    }
}
