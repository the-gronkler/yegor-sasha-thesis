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
     * Storage disk for restaurant images.
     */
    private const RESTAURANT_IMAGES_DISK = 'r2';

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

        // Verify and get the employee record (aborts with 403 if not found)
        $employee = $this->getEmployeeForRestaurant($user, $restaurant);

        // Prevent removing own admin privileges
        if ($employee->user_id === $currentUser->id && $validated['is_admin'] === false) {
            return back()->withErrors([
                'is_admin' => 'You cannot remove your own admin privileges.',
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

        // Verify and get the employee record (aborts with 403 if not found)
        $employee = $this->getEmployeeForRestaurant($user, $restaurant);

        // Prevent self-deletion
        if ($employee->user_id === $currentUser->id) {
            return back()->with('error', 'You cannot remove yourself.');
        }

        // Delete employee record and clean up orphaned user account if needed
        DB::transaction(function () use ($employee, $user) {
            // Delete the employee record for this restaurant
            $employee->delete();

            // If the user has no other employee records or customer record, delete the user
            // to avoid orphaned accounts that can't be cleaned up
            $hasOtherEmployeeRecords = Employee::where('user_id', $user->id)->exists();
            $hasCustomerRecord = $user->customer()->exists();

            if (! $hasOtherEmployeeRecords && ! $hasCustomerRecord) {
                $user->delete();
            }
        });

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
            'latitude' => ['nullable', 'numeric', 'min:-90', 'max:90'],
            'longitude' => ['nullable', 'numeric', 'min:-180', 'max:180'],
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
        $path = $request->file('image')->store('restaurants', self::RESTAURANT_IMAGES_DISK);

        try {
            // Wrap database operations in transaction
            DB::transaction(function () use ($validated, $restaurant, $path) {
                // Create image record
                $image = Image::create([
                    'restaurant_id' => $restaurant->id,
                    'image' => $path,
                    'description' => $validated['description'] ?? null,
                    'is_primary_for_restaurant' => $validated['is_primary'] ?? false,
                ]);

                // If this is set as primary, update all other images
                if ($validated['is_primary'] ?? false) {
                    $this->setRestaurantPrimaryImage($restaurant, $image);
                }
            });
        } catch (\Throwable $e) {
            // Roll back stored file if database operations fail
            Storage::disk(self::RESTAURANT_IMAGES_DISK)->delete($path);
            throw $e;
        }

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
        $this->ensureImageBelongsToRestaurant($image, $restaurant);

        // Delete the file from storage
        Storage::disk(self::RESTAURANT_IMAGES_DISK)->delete($image->image);

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
        $this->ensureImageBelongsToRestaurant($image, $restaurant);

        // Set this image as primary and unset others
        $this->setRestaurantPrimaryImage($restaurant, $image);

        return back()->with('success', 'Primary image updated successfully.');
    }

    /**
     * Ensure the image belongs to the given restaurant.
     *
     * @param  \App\Models\Restaurant  $restaurant
     *
     * @throws \Symfony\Component\HttpKernel\Exception\HttpException
     */
    private function ensureImageBelongsToRestaurant(Image $image, $restaurant): void
    {
        if ($image->restaurant_id !== $restaurant->id) {
            abort(403, 'This image does not belong to your restaurant.');
        }
    }

    /**
     * Get employee record for a user, ensuring they belong to the restaurant.
     *
     * This method prevents information leakage by returning a 403 Forbidden
     * instead of 404 Not Found when the employee doesn't exist, making it
     * impossible for attackers to enumerate user IDs.
     *
     * @param  \App\Models\Restaurant  $restaurant
     *
     * @throws \Symfony\Component\HttpKernel\Exception\HttpException
     */
    private function getEmployeeForRestaurant(User $user, $restaurant): Employee
    {
        $employee = Employee::where('user_id', $user->id)
            ->where('restaurant_id', $restaurant->id)
            ->first();

        if (! $employee) {
            abort(403, 'This user is not an employee of your restaurant.');
        }

        return $employee;
    }

    /**
     * Set the primary image for a restaurant.
     *
     * Atomically updates all images for the restaurant so that only the
     * specified image is marked as primary. Uses a single UPDATE query
     * with a CASE statement for optimal performance.
     *
     * @param  \App\Models\Restaurant  $restaurant
     */
    private function setRestaurantPrimaryImage($restaurant, Image $image): void
    {
        Image::where('restaurant_id', $restaurant->id)
            ->update([
                'is_primary_for_restaurant' => DB::raw(
                    'CASE WHEN id = '.(int) $image->id.' THEN TRUE ELSE FALSE END'
                ),
            ]);
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
