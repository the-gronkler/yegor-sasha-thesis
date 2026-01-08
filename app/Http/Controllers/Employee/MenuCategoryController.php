<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use App\Models\FoodType;
use Illuminate\Http\Request;
use Inertia\Inertia;

class MenuCategoryController extends Controller
{
    public function index(Request $request)
    {
        $restaurant = $request->user()->employee->restaurant; // assuming employee→restaurant relation

        $categories = FoodType::where('restaurant_id', $restaurant->id)
            ->orderBy('name')
            ->get(['id', 'name']);

        return Inertia::render('Employee/Restaurant/MenuCategories/Index', [
            'restaurant' => ['id' => $restaurant->id, 'name' => $restaurant->name],
            'categories' => $categories,
        ]);
    }

    public function create(Request $request)
    {
        return Inertia::render('Employee/Restaurant/MenuCategories/Create');
    }

    public function store(Request $request)
    {
        $this->authorize('create', FoodType::class);

        // Securely retrieve the restaurant from the authenticated user
        // This prevents attackers from injecting an arbitrary restaurant ID
        $restaurant = $request->user()->employee?->restaurant;

        if (! $restaurant) {
            abort(403, 'User is not associated with a restaurant.');
        }

        // Validate that the user has update rights on that specific restaurant
        $this->authorize('update', $restaurant);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
        ]);

        FoodType::create([
            'restaurant_id' => $restaurant->id,
            'name' => $validated['name'],
        ]);

        return back()->with('success', 'Category created successfully.');
    }

    public function edit(Request $request, FoodType $menuCategory)
    {
        // Ensure the category belongs to this restaurant
        $this->authorize('update', $menuCategory);

        return Inertia::render('Employee/Restaurant/MenuCategories/Edit', [
            'category' => ['id' => $menuCategory->id, 'name' => $menuCategory->name],
        ]);
    }

    public function update(Request $request, FoodType $menuCategory)
    {
        $this->authorize('update', $menuCategory);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $menuCategory->update(['name' => $validated['name']]);

        return back()->with('success', 'Category updated.');
    }

    public function destroy(Request $request, FoodType $menuCategory)
    {
        $this->authorize('delete', $menuCategory);

        $menuCategory->delete();

        return back()->with('success', 'Category deleted.');
    }

    public function show(Request $request, FoodType $menuCategory)
    {
        // Ensure the category belongs to this restaurant
        $this->authorize('view', $menuCategory);

        return Inertia::render('Employee/Restaurant/MenuCategories/Show', [
            'category' => ['id' => $menuCategory->id, 'name' => $menuCategory->name],
        ]);
    }
}
