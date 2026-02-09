<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\MenuItem;
use App\Models\Restaurant;
use Illuminate\Http\Request;
use Inertia\Inertia;

class MenuItemController extends Controller
{
    /**
     * Display the specified menu item with all details.
     */
    public function show(Request $request, Restaurant $restaurant, MenuItem $menuItem)
    {
        $this->authorize('view', $menuItem);

        // Verify the menu item belongs to the restaurant
        abort_if($menuItem->restaurant_id !== $restaurant->id, 404);

        // Load related data
        $menuItem->load([
            'allergens',
            'image', // Load selected image
        ]);

        return Inertia::render('Customer/MenuItems/Show', [
            'menuItem' => [
                'id' => $menuItem->id,
                'name' => $menuItem->name,
                'price' => $menuItem->price,
                'description' => $menuItem->description,
                'is_available' => $menuItem->is_available,
                'restaurant_id' => $menuItem->restaurant_id,
                'food_type_id' => $menuItem->food_type_id,
                'image_id' => $menuItem->image_id,
                'image' => $menuItem->image ? [
                    'id' => $menuItem->image->id,
                    'url' => $menuItem->image->url,
                ] : null,
                'allergens' => $menuItem->allergens->map(fn ($allergen) => [
                    'id' => $allergen->id,
                    'name' => $allergen->name,
                ]),
            ],
            'restaurantId' => $restaurant->id,
            'restaurantName' => $restaurant->name,
        ]);
    }
}
