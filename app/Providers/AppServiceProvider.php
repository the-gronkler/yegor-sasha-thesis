<?php

namespace App\Providers;

use App\Enums\OrderStatus;
use App\Models\Order;
use Illuminate\Support\Facades\Log;
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
        if (str_contains(config('app.url'), 'https://')) {
            \Illuminate\Support\Facades\URL::forceScheme('https');
        }

        if ($this->app->runningInConsole()) {
            $this->loadMigrationsFrom(
                collect(glob(database_path('migrations/*'), GLOB_ONLYDIR))
                    ->flatten()
                    ->toArray()
            );
        }

        // Share validation errors and flash messages with all Inertia responses
        Inertia::share([
            'cart' => function () {
                if (! auth()->check()) {
                    return null;
                }

                $user = auth()->user();
                $customer = $user->customer;

                if (! $customer) {
                    Log::warning("Authenticated user {$user->id} attempted to access cart but has no customer record.");

                    return null;
                }

                // Return all cart orders (one per restaurant)
                return Order::with(['menuItems.images', 'restaurant'])
                    ->where('customer_user_id', $customer->user_id)
                    ->where('order_status_id', OrderStatus::InCart)
                    ->get();
            },
            'errors' => function () {
                return session()->get('errors')
                    ? session()->get('errors')->getBag('default')->getMessages()
                    : (object) [];
            },
            'flash' => function () {
                return [
                    'success' => session('success'),
                    'error' => session('error'),
                    'warning' => session('warning'),
                    'info' => session('info'),
                ];
            },
        ]);
    }
}
