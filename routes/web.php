<?php

use App\Http\Controllers\Customer\CartController;
use App\Http\Controllers\Customer\CheckoutController;
use App\Http\Controllers\Customer\MapController;
use App\Http\Controllers\Customer\OrderController;
use App\Http\Controllers\Customer\ProfileController;
use App\Http\Controllers\Customer\RestaurantController;
use App\Http\Controllers\Customer\ReviewController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth', 'verified'])->group(function () {
    // Customer-side: Restaurants
    Route::get('/', [RestaurantController::class, 'index'])->name('restaurants.index');
    Route::get('/map', [MapController::class, 'index'])->name('map.index');
    Route::get('/restaurants/{restaurant}', [RestaurantController::class, 'show'])->name('restaurants.show');

    // Cart (for current customer)
    Route::prefix('cart')->name('cart.')->group(function () {
        Route::get('/', [CartController::class, 'index'])->name('index');
        Route::post('/add-item', [CartController::class, 'addItem'])->name('addItem');
        Route::post('/update-quantity', [CartController::class, 'updateItemQuantity'])->name('updateItemQuantity');
        Route::delete('/remove-item', [CartController::class, 'removeItem'])->name('removeItem');
        Route::put('/add-note/{order}', [CartController::class, 'addNote'])->name('addNote');
    });

    // Checkout
    Route::prefix('checkout')->name('checkout.')->group(function () {
        Route::get('/{order}', [CheckoutController::class, 'show'])->name('show');
        Route::post('/{order}', [CheckoutController::class, 'process'])->name('process');
    });

    // Orders: finished / unfinished
    Route::prefix('orders')->name('orders.')->group(function () {
        Route::get('/', [OrderController::class, 'index'])->name('index'); // finished orders
        // Route::get('/unfinished', [OrderController::class, 'unfinished'])->name('unfinished'); // status == In Cart
        // Route::get('/old', [OrderController::class, 'old'])->name('old'); // unlimited older orders
        Route::delete('/cart/{order}', [OrderController::class, 'destroyCart'])->name('destroyCart');
        Route::get('/{order}', [OrderController::class, 'show'])->name('show');
    });

    // Reviews for customer
    Route::resource('reviews', ReviewController::class)
        ->only(['index', 'store', 'update', 'destroy'])
        ->names([
            'index' => 'reviews.index',
            'store' => 'reviews.store',
            'update' => 'reviews.update',
            'destroy' => 'reviews.destroy',
        ]);

    // Profile
    Route::prefix('profile')->name('profile.')->group(function () {
        Route::get('/', [ProfileController::class, 'show'])->name('show');
        Route::put('/', [ProfileController::class, 'update'])->name('update');
        Route::delete('/', [ProfileController::class, 'destroy'])->name('destroy');
        Route::get('/favorites', [ProfileController::class, 'favorites'])->name('favorites');
    });
});

// Admin / Restaurant management
Route::middleware(['auth', 'can:manage-restaurant'])->prefix('restaurant')->name('restaurant.')->group(function () {
    Route::resource('menu-categories', App\Http\Controllers\Restaurant\Admin\MenuCategoryController::class);
    Route::resource('menu-items', App\Http\Controllers\Restaurant\Admin\MenuItemController::class);
    Route::resource('workers', App\Http\Controllers\Restaurant\Admin\WorkerController::class);

    Route::put('/menu-items/{item}/status', [App\Http\Controllers\Restaurant\Admin\MenuItemController::class, 'updateStatus'])
        ->name('menu-items.updateStatus');

    Route::put('/orders/{order}/status', [App\Http\Controllers\Restaurant\Admin\OrderController::class, 'updateStatus'])
        ->name('orders.updateStatus');
});
