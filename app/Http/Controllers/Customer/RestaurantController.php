<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Restaurant;
use Illuminate\Http\Request;
use Inertia\Inertia;

class RestaurantController extends Controller
{
    /**
     * Display a listing of restaurants (e.g., the “main page”).
     */
    public function index(Request $request)
    {
        // You might paginate, or fetch subset, etc.
        $restaurants = Restaurant::with('foodTypes', 'images')
            ->select(['id', 'name', 'address', 'latitude', 'longitude', 'rating'])
            ->latest('rating')
            ->get();

        return Inertia::render('Customer/Restaurants/Index', [
            'restaurants' => $restaurants,
        ]);
    }

    /**
     * Display the specified restaurant along with its categories, menu items, allergens, images.
     */
    public function show(Request $request, Restaurant $restaurant)
    {
        // Load related data
        $restaurant->load([
            'foodTypes.menuItems.images',         // food types → menu items → images
            'menuItems.allergens',                // all allergens of menu items
            'images',                              // restaurant images
        ]);

        // Prepare data (you might map or slice properties)
        return Inertia::render('Customer/Restaurants/Show', [
            'restaurant' => [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'address' => $restaurant->address,
                'latitude' => $restaurant->latitude,
                'longitude' => $restaurant->longitude,
                'description' => $restaurant->description,
                'rating' => $restaurant->rating,
                // relations:
                'food_types' => $restaurant->foodTypes->map(fn ($ft) => [
                    'id' => $ft->id,
                    'name' => $ft->name,
                    'menu_items' => $ft->menuItems->map(fn ($mi) => [
                        'id' => $mi->id,
                        'name' => $mi->name,
                        'price' => $mi->price,
                        'description' => $mi->description,
                        'images' => $mi->images->map(fn ($img) => [
                            'id' => $img->id,
                            'url' => $img->image,   // make sure Model attribute
                            'is_primary_for_menu_item' => $img->is_primary_for_menu_item,
                        ]),
                        'allergens' => $mi->allergens->map(fn ($al) => [
                            'id' => $al->id,
                            'name' => $al->name,
                        ]),
                    ]),
                ]),
                'restaurant_images' => $restaurant->images->map(fn ($img) => [
                    'id' => $img->id,
                    'url' => $img->image,
                    'is_primary_for_restaurant' => $img->is_primary_for_restaurant,
                ]),
            ],
        ]);
    }
}
