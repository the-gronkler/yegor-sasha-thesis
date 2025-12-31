<?php

namespace App\Providers;

use App\Models\Allergen;
use App\Models\Customer;
use App\Models\Employee;
use App\Models\FavoriteRestaurant;
use App\Models\FoodType;
use App\Models\Image;
use App\Models\MenuItem;
use App\Models\MenuItemAllergen;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\OrderStatus;
use App\Models\Restaurant;
use App\Models\Review;
use App\Models\ReviewImage;
use App\Models\User;
use App\Policies\AllergenPolicy;
use App\Policies\CustomerPolicy;
use App\Policies\EmployeePolicy;
use App\Policies\FavoriteRestaurantPolicy;
use App\Policies\FoodTypePolicy;
use App\Policies\ImagePolicy;
use App\Policies\MenuItemAllergenPolicy;
use App\Policies\MenuItemPolicy;
use App\Policies\OrderItemPolicy;
use App\Policies\OrderPolicy;
use App\Policies\OrderStatusPolicy;
use App\Policies\RestaurantPolicy;
use App\Policies\ReviewImagePolicy;
use App\Policies\ReviewPolicy;
use App\Policies\UserPolicy;
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
        Allergen::class => AllergenPolicy::class,
        Customer::class => CustomerPolicy::class,
        Employee::class => EmployeePolicy::class,
        FavoriteRestaurant::class => FavoriteRestaurantPolicy::class,
        FoodType::class => FoodTypePolicy::class,
        Image::class => ImagePolicy::class,
        MenuItem::class => MenuItemPolicy::class,
        MenuItemAllergen::class => MenuItemAllergenPolicy::class,
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

        // First check if the user is an admin, and if so, allow all actions. If not, go to check policies.
        Gate::before(function ($user, $ability) {
            return $user->is_admin === true ? true : null;
        });

        Gate::define('manage-restaurant', function (User $user) {
            return $user->isEmployee() && $user->employee->is_admin;
        });
    }
}
