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
        Route::get('', fn () => redirect()->route('employee.orders.index'))->name('index');

        // Orders
        Route::get('orders', [EmployeeOrderController::class, 'index'])->name('orders.index');

        // Menu
        Route::get('menu', [MenuController::class, 'index'])->name('menu.index');

        // Establishment (Admins only)
        Route::middleware(['can:manage-restaurant'])->group(function () {
            Route::get('establishment', [EstablishmentController::class, 'index'])->name('establishment.index');
        });

        // Shared Restaurant Management (All Employees)
        Route::prefix('restaurant')->name('restaurant.')->group(function () {
            Route::resource('menu-categories', MenuCategoryController::class);
            Route::resource('menu-items', EmployeeMenuItemController::class);

            Route::put('menu-items/{item}/status', [EmployeeMenuItemController::class, 'updateStatus'])
                ->name('menu-items.updateStatus');

            Route::put('orders/{order}/status', [EmployeeOrderController::class, 'updateStatus'])
                ->name('orders.updateStatus');
        });
    });

// Restaurant Admin Routes (Admins Only)
Route::middleware(['auth', 'can:manage-restaurant'])
    ->prefix('employee/restaurant')
    ->name('employee.restaurant.')
    ->group(function () {
        Route::resource('workers', EstablishmentController::class);
    });
