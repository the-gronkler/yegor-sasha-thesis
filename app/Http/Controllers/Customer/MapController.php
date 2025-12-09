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
        $restaurants = Restaurant::query()
            ->select(['id', 'name', 'latitude', 'longitude', 'address'])
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->get()
            ->map(fn (Restaurant $restaurant) => [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'lat' => (float) $restaurant->latitude,
                'lng' => (float) $restaurant->longitude,
                'address' => $restaurant->address,
            ]);

        return Inertia::render('Customer/Map/Index', [
            'restaurants' => $restaurants,
        ]);
    }
}
