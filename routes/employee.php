<?php

use App\Http\Controllers\Employee\EmployeeMenuItemController;
use App\Http\Controllers\Employee\EmployeeOrderController;
use App\Http\Controllers\Employee\EstablishmentController;
use App\Http\Controllers\Employee\MenuCategoryController;
use App\Http\Controllers\Employee\MenuController;
use App\Http\Middleware\EnsureUserIsEmployee;
use Illuminate\Support\Facades\Route;

// Employee routes
Route::middleware(['auth', 'verified', EnsureUserIsEmployee::class])
    ->prefix('employee')
    ->name('employee.')
    ->group(function () {
        // Redirect /employee to the first tab (Orders)
        Route::get('/', fn () => redirect()->route('employee.orders.index'))->name('index');

        // Orders
        Route::get('orders', [EmployeeOrderController::class, 'index'])->name('orders.index');

        // Menu
        Route::get('menu', [MenuController::class, 'index'])->name('menu.index');

        // Establishment (Admins only)
        Route::middleware(['can:manage-restaurant'])->group(function () {
            Route::get('establishment', [EstablishmentController::class, 'index'])->name('establishment.index');

            // Workers Management
            Route::get('establishment/workers', [EstablishmentController::class, 'workers'])->name('establishment.workers');
            Route::post('establishment/workers', [EstablishmentController::class, 'storeWorker'])->name('establishment.workers.store');
            Route::put('establishment/workers/{user}', [EstablishmentController::class, 'updateWorker'])->name('establishment.workers.update');
            Route::delete('establishment/workers/{user}', [EstablishmentController::class, 'destroyWorker'])->name('establishment.workers.destroy');

            // Restaurant Data Management
            Route::get('establishment/restaurant', [EstablishmentController::class, 'restaurant'])->name('establishment.restaurant');
            Route::put('establishment/restaurant', [EstablishmentController::class, 'updateRestaurant'])->name('establishment.restaurant.update');

            // Photos Management
            Route::get('establishment/photos', [EstablishmentController::class, 'photos'])->name('establishment.photos');
            Route::post('establishment/photos', [EstablishmentController::class, 'storeImage'])->name('establishment.images.store');
            Route::delete('establishment/photos/{image}', [EstablishmentController::class, 'destroyImage'])->name('establishment.images.destroy');
            Route::put('establishment/photos/{image}/primary', [EstablishmentController::class, 'setPrimaryImage'])->name('establishment.images.set-primary');
        });

        // Shared Restaurant Management (All Employees)
        Route::prefix('restaurant')->name('restaurant.')->group(function () {
            Route::resource('menu-categories', MenuCategoryController::class);
            Route::resource('menu-items', EmployeeMenuItemController::class);

            Route::put('menu-items/{item}/status', [EmployeeMenuItemController::class, 'updateStatus'])
                ->name('menu-items.updateStatus');

            Route::put('menu-items/{menuItem}/photo', [EmployeeMenuItemController::class, 'updatePhoto'])
                ->name('menu-items.update-photo');

            Route::put('orders/{order}/status', [EmployeeOrderController::class, 'updateStatus'])
                ->name('orders.updateStatus');

            // Admin-only routes
            Route::middleware('can:manage-restaurant')->group(function () {
                Route::resource('workers', EstablishmentController::class);
            });
        });
    });
