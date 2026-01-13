<?php

use App\Http\Controllers\Api\RestaurantMapController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| These routes are loaded by the RouteServiceProvider and are assigned
| to the "api" middleware group. All routes are prefixed with /api.
|
*/

// Restaurant map endpoints (lightweight data for vector tile interactions)
Route::prefix('restaurants')->group(function () {
    // Get minimal restaurant data for map popup
    Route::get('/{restaurant}/map-card', [RestaurantMapController::class, 'show'])
        ->name('api.restaurants.map-card');
});
