<?php

namespace App\Providers;

use App\Enums\OrderStatus;
use App\Models\Order;
use Illuminate\Support\ServiceProvider;
use Inertia\Inertia;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Inertia::share([
            'cart' => function () {
                if (! auth()->check()) {
                    return null;
                }

                $customer = auth()->user()->customer;
                if (! $customer) {
                    return null;
                }

                // Return all cart orders (one per restaurant)
                return Order::with(['menuItems.images', 'restaurant'])
                    ->where('customer_user_id', $customer->user_id)
                    ->where('order_status_id', OrderStatus::InCart)
                    ->get();
            },
        ]);
    }
}
