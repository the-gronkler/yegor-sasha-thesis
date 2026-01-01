<?php

use App\Http\Controllers\Customer\CartController;
use App\Http\Controllers\Customer\CheckoutController;
use App\Http\Controllers\Customer\MapController;
use App\Http\Controllers\Customer\MenuItemController;
use App\Http\Controllers\Customer\OrderController;
use App\Http\Controllers\Customer\ProfileController;
use App\Http\Controllers\Customer\RestaurantController;
use App\Http\Controllers\Customer\ReviewController;
use App\Http\Middleware\BlockEmployees;
use App\Http\Middleware\EnsureUserIsCustomer;
use Illuminate\Support\Facades\Route;

// Customer-side: Restaurants (Public)
Route::middleware([BlockEmployees::class])->group(function () {
    Route::get('/', [MapController::class, 'index'])->name('map.index');

    Route::prefix('restaurants')->name('restaurants.')->group(function () {
        Route::get('/', [RestaurantController::class, 'index'])->name('index');
        Route::get('/{restaurant}', [RestaurantController::class, 'show'])->name('show');
        Route::post('/{restaurant}/favorite', [RestaurantController::class, 'toggleFavorite'])->name('toggleFavorite')->middleware('auth');
        Route::get('/{restaurant}/menu-items/{menuItem}', [MenuItemController::class, 'show'])->name('menu-items.show');
    });
});

Route::middleware(['auth', 'verified', EnsureUserIsCustomer::class])->group(function () {
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
        Route::get('/edit', [ProfileController::class, 'edit'])->name('edit');
        Route::put('/', [ProfileController::class, 'update'])->name('update');
        Route::delete('/', [ProfileController::class, 'destroy'])->name('destroy');
        Route::get('/favorites', [ProfileController::class, 'favorites'])->name('favorites');
        Route::put('/favorites/ranks', [ProfileController::class, 'updateFavoriteRanks'])->name('favorites.updateRanks');
    });
});
