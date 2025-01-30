<?php

namespace App\Providers;

use App\Models\User;
use App\Policies\UserPolicy;
use App\Models\Alergen;
use App\Policies\AlergenPolicy;
use App\Models\Customer;
use App\Policies\CustomerPolicy;
use App\Models\Employee;
use App\Policies\EmployeePolicy;
use App\Models\FavoriteRestaurant;
use App\Policies\FavoriteRestaurantPolicy;
use App\Models\FoodType;
use App\Policies\FoodTypePolicy;
use App\Models\Image;
use App\Policies\ImagePolicy;
use App\Models\MenuItem;
use App\Policies\MenuItemPolicy;
use App\Models\MenuItemAlergen;
use App\Policies\MenuItemAlergenPolicy;
use App\Models\Order;
use App\Policies\OrderPolicy;
use App\Models\OrderItem;
use App\Policies\OrderItemPolicy;
use App\Models\OrderStatus;
use App\Policies\OrderStatusPolicy;
use App\Models\Restaurant;
use App\Policies\RestaurantPolicy;
use App\Models\Review;
use App\Policies\ReviewPolicy;
use App\Models\ReviewImage;
use App\Policies\ReviewImagePolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        User::class => UserPolicy::class,
        Alergen::class => AlergenPolicy::class,
        Customer::class => CustomerPolicy::class,
        Employee::class => EmployeePolicy::class,
        FavoriteRestaurant::class => FavoriteRestaurantPolicy::class,
        FoodType::class => FoodTypePolicy::class,
        Image::class => ImagePolicy::class,
        MenuItem::class => MenuItemPolicy::class,
        MenuItemAlergen::class => MenuItemAlergenPolicy::class,
        Order::class => OrderPolicy::class,
        OrderItem::class => OrderItemPolicy::class,
        OrderStatus::class => OrderStatusPolicy::class,
        Restaurant::class => RestaurantPolicy::class,
        Review::class => ReviewPolicy::class,
        ReviewImage::class => ReviewImagePolicy::class,
    ];

    /**
     * Register any authentication / authorization services.
     */
    public function boot(): void
    {
        $this->registerPolicies();

        //First check if the user is an admin, and if so, allow all actions. If not, go to check policies.
        Gate::before(function ($user, $ability) {
            return $user->is_admin === true ? true : null;
        });
    }
}
