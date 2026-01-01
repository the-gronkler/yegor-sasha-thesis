<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Restaurant;
use App\Models\Review;
use Illuminate\Database\Seeder;

class CustomerSeeder extends Seeder
{
    public function run(?int $count = null, ?int $reviewsPerCustomer = null, ?int $ordersPerCustomer = null): void
    {
        $count ??= config('seeding.customers');
        $reviewsPerCustomer ??= config('seeding.reviews_per_customer');
        $ordersPerCustomer ??= config('seeding.orders_per_customer');

        $restaurantCount = Restaurant::count();

        Customer::factory()
            ->count($count)
            ->hasOrders($ordersPerCustomer) // requires orders() on model and OrderFactory
            ->afterCreating(function (Customer $customer) use ($reviewsPerCustomer, $restaurantCount) {
                if ($restaurantCount <= 0 || $reviewsPerCustomer <= 0) {
                    return;
                }

                $reviewsToCreate = min($reviewsPerCustomer, $restaurantCount);

                $restaurants = Restaurant::inRandomOrder()->take($reviewsToCreate)->get();

                foreach ($restaurants as $restaurant) {
                    Review::factory()->create([
                        'customer_user_id' => $customer->user_id,
                        'restaurant_id' => $restaurant->id,
                    ]);
                }
            })
            ->hasAttached(
                Restaurant::inRandomOrder()->value('id'),  // requires favoriteRestaurants() on model
                fn () => ['rank' => rand(1, 5)],
                'favoriteRestaurants'
            )
            ->create();
    }
}
