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
        // Verify the menu item belongs to the restaurant
        abort_if($menuItem->restaurant_id !== $restaurant->id, 404);

        // Load related data
        $menuItem->load([
            'images',
            'allergens',
        ]);

        return Inertia::render('Customer/MenuItems/Show', [
            'menuItem' => [
                'id' => $menuItem->id,
                'name' => $menuItem->name,
                'price' => $menuItem->price,
                'description' => $menuItem->description,
                'restaurant_id' => $menuItem->restaurant_id,
                'food_type_id' => $menuItem->food_type_id,
                'images' => $menuItem->images->map(fn ($img) => [
                    'id' => $img->id,
                    'url' => $img->image,
                    'is_primary_for_menu_item' => $img->is_primary_for_menu_item,
                ]),
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
