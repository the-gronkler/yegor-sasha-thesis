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

        $this->authorize('update', $menuItem);

        $menuItem->load(['allergens', 'images', 'restaurant']);

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

        return Inertia::render('Employee/MenuItem/Edit', [
            'menuItem' => $menuItem,
            'foodTypes' => $foodTypes,
            'allergens' => $allergens,
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
        }

        return redirect()->route('employee.menu.edit')->with('success', 'Menu item updated successfully.');
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
}
