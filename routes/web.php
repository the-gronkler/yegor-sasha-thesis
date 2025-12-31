<?php

use App\Http\Controllers\Customer\CartController;
use App\Http\Controllers\Customer\CheckoutController;
use App\Http\Controllers\Customer\MapController;
use App\Http\Controllers\Customer\MenuItemController;
use App\Http\Controllers\Customer\OrderController;
use App\Http\Controllers\Customer\ProfileController;
use App\Http\Controllers\Customer\RestaurantController;
use App\Http\Controllers\Customer\ReviewController;
use App\Http\Controllers\Employee\EmployeeMenuItemController;
use App\Http\Controllers\Employee\EmployeeOrderController;
use App\Http\Controllers\Employee\EstablishmentController;
use App\Http\Controllers\Employee\MenuCategoryController;
use App\Http\Controllers\Employee\MenuController;
use App\Http\Middleware\BlockEmployees;
use App\Http\Middleware\EnsureUserIsCustomer;
use App\Http\Middleware\EnsureUserIsEmployee;
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

// Employee routes
Route::middleware(['auth', 'verified', EnsureUserIsEmployee::class])->group(function () {
    // Redirect /employee to the first tab (Orders)
    Route::get('/employee', function () {
        return redirect()->route('employee.orders.index');
    })->name('employee.index');

    Route::prefix('employee')->name('employee.')->group(function () {
        // Orders
        Route::get('/orders', [EmployeeOrderController::class, 'index'])->name('orders.index');

        // Menu
        Route::get('/menu', [MenuController::class, 'index'])->name('menu.index');

        // Establishment (Admins only)
        Route::middleware(['can:manage-restaurant'])->group(function () {
            Route::get('/establishment', [EstablishmentController::class, 'index'])->name('establishment.index');
        });
    });

    // Shared Restaurant Management (All Employees)
    Route::prefix('restaurant')->name('restaurant.')->group(function () {
        Route::resource('menu-categories', MenuCategoryController::class);
        Route::resource('menu-items', EmployeeMenuItemController::class);

        Route::put('/menu-items/{item}/status', [EmployeeMenuItemController::class, 'updateStatus'])
            ->name('menu-items.updateStatus');

        Route::put('/orders/{order}/status', [EmployeeOrderController::class, 'updateStatus'])
            ->name('orders.updateStatus');
    });
});

// Restaurant Admin Routes (Admins Only)
Route::middleware(['auth', 'can:manage-restaurant'])->prefix('restaurant')->name('restaurant.')->group(function () {
    Route::resource('workers', EstablishmentController::class);
});
