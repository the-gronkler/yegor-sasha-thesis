<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use App\Models\MenuItem;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Inertia\Inertia;

class EmployeeMenuItemController extends Controller
{
    public function show(MenuItem $menuItem)
    {
        $user = auth()->user();

        $this->authorize('view', $menuItem);

        $menuItem->load(['allergens', 'images', 'restaurant', 'image']);

        return Inertia::render('Employee/MenuItem/Show', [
            'menuItem' => $menuItem,
            'restaurantName' => $menuItem->restaurant->name,
            'canEdit' => $user->can('update', $menuItem),
        ]);
    }

    public function edit(Request $request, MenuItem $menuItem)
    {
        $this->authorize('update', $menuItem);

        $menuItem->load(['allergens', 'images', 'foodType']);

        // Get food types for this restaurant
        $foodTypes = \App\Models\FoodType::where('restaurant_id', $menuItem->restaurant_id)->get();
        $allergens = \App\Models\Allergen::all();

        // Get all restaurant images for photo selection
        $restaurantImages = \App\Models\Image::where('restaurant_id', $menuItem->restaurant_id)
            ->whereNull('menu_item_id') // Only restaurant photos, not menu item specific ones
            ->orderBy('is_primary_for_restaurant', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return Inertia::render('Employee/MenuItem/Edit', [
            'menuItem' => $menuItem,
            'foodTypes' => $foodTypes,
            'allergens' => $allergens,
            'restaurantImages' => $restaurantImages,
            'queryParams' => $request->query(),
        ]);
    }

    public function update(Request $request, MenuItem $menuItem)
    {
        $this->authorize('update', $menuItem);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'price' => ['required', 'numeric', 'min:0'],
            'food_type_id' => [
                'required',
                Rule::exists('food_types', 'id')->where('restaurant_id', $menuItem->restaurant_id),
            ],
            'is_available' => ['required', 'boolean'],
            'allergens' => ['array'],
            'allergens.*' => ['exists:allergens,id'],
        ]);

        $menuItem->update($validated);

        if (isset($validated['allergens'])) {
            $menuItem->allergens()->sync($validated['allergens']);
            $menuItem->touch(); // Ensure 'updated' event fires if only allergens changed
        }

        return redirect()->route('employee.menu.index')->with('success', 'Menu item updated successfully.');
    }

    public function updateStatus(Request $request, MenuItem $item)
    {
        $this->authorize('updateStatus', $item);

        $validated = $request->validate([
            'is_available' => ['required', 'boolean'],
        ]);

        $item->update($validated);

        return back();
    }

    public function updatePhoto(Request $request, MenuItem $item)
    {
        $this->authorize('update', $item);

        $validated = $request->validate([
            'image_id' => [
                'nullable',
                Rule::exists('images', 'id')->where(function ($query) use ($item) {
                    $query->where('restaurant_id', $item->restaurant_id);
                }),
            ],
        ]);

        // Update the menu item's selected image
        $item->update([
            'image_id' => $validated['image_id'],
        ]);

        return back()->with('success', $validated['image_id'] ? 'Photo selected successfully.' : 'Photo removed successfully.');
    }

    public function create(Request $request)
    {
        $restaurant = $request->user()->employee?->restaurant;

        if (! $restaurant) {
            abort(403, 'User is not associated with a restaurant.');
        }

        $this->authorize('create', [MenuItem::class, $restaurant]);

        $foodTypes = \App\Models\FoodType::where('restaurant_id', $restaurant->id)->get();
        $allergens = \App\Models\Allergen::all();

        // Get all restaurant images for photo selection
        $restaurantImages = \App\Models\Image::where('restaurant_id', $restaurant->id)
            ->whereNull('menu_item_id')
            ->orderBy('is_primary_for_restaurant', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        // Get the food_type_id from query params if provided
        $foodTypeId = $request->query('food_type_id');

        return Inertia::render('Employee/MenuItem/Create', [
            'restaurant' => $restaurant,
            'foodTypes' => $foodTypes,
            'allergens' => $allergens,
            'restaurantImages' => $restaurantImages,
            'preselectedFoodTypeId' => $foodTypeId,
        ]);
    }

    public function store(Request $request)
    {
        $restaurant = $request->user()->employee?->restaurant;

        if (! $restaurant) {
            abort(403, 'User is not associated with a restaurant.');
        }

        $this->authorize('create', [MenuItem::class, $restaurant]);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'price' => ['required', 'numeric', 'min:0'],
            'food_type_id' => [
                'required',
                Rule::exists('food_types', 'id')->where('restaurant_id', $restaurant->id),
            ],
            'is_available' => ['required', 'boolean'],
            'allergens' => ['array'],
            'allergens.*' => ['exists:allergens,id'],
            'image_id' => [
                'nullable',
                Rule::exists('images', 'id')->where(function ($query) use ($restaurant) {
                    $query->where('restaurant_id', $restaurant->id);
                }),
            ],
        ]);

        $menuItem = MenuItem::create($validated);

        if (isset($validated['allergens'])) {
            $menuItem->allergens()->sync($validated['allergens']);
        }

        return redirect()->route('employee.menu.index')->with('success', 'Menu item created successfully.');
    }

    public function destroy(Request $request, MenuItem $menuItem)
    {
        $this->authorize('delete', $menuItem);

        $menuItem->delete();

        return back()->with('success', 'Menu item deleted successfully.');
    }
}
