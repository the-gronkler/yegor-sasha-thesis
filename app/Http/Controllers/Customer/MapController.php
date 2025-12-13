<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Restaurant;
use Inertia\Inertia;
use Inertia\Response;

class MapController extends Controller
{
    public function index(): Response
    {
        $this->authorize('viewAny', Restaurant::class);

        // TODO: limit number of restaurants by geolocation.
        // Right now it loads all the additinal data for searching on fe, but i feel that there is a better approach.
        // Anyways, this is a design issue for later
        $restaurants = Restaurant::with(['images', 'foodTypes.menuItems'])
            ->select([
                'id',
                'name',
                'address',
                'latitude',
                'longitude',
                'rating',
                'description',
                'opening_hours',
            ])
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->latest('rating')
            ->get()
            ->map(fn (Restaurant $restaurant) => [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'address' => $restaurant->address,
                'latitude' => (float) $restaurant->latitude,
                'longitude' => (float) $restaurant->longitude,
                'rating' => $restaurant->rating,
                'description' => $restaurant->description,
                'opening_hours' => $restaurant->opening_hours,
                'images' => $restaurant->images->map(fn ($img) => [
                    'id' => $img->id,
                    'url' => $img->image,
                    'is_primary_for_restaurant' => $img->is_primary_for_restaurant,
                ]),
                'food_types' => $restaurant->foodTypes->map(fn ($ft) => [
                    'id' => $ft->id,
                    'name' => $ft->name,
                    'menu_items' => $ft->menuItems->map(fn ($mi) => [
                        'id' => $mi->id,
                        'name' => $mi->name,
                    ]),
                ]),
            ]);

        return Inertia::render('Customer/Map/Index', [
            'restaurants' => $restaurants,
        ]);
    }
}
