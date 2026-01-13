<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Restaurant;
use App\Models\Review;
use Illuminate\Database\Seeder;

class CustomerSeeder extends Seeder
{
    public function run(?int $count = null, ?int $reviewsPerCustomer = null, ?int $ordersPerCustomer = null, ?callable $progressCallback = null): void
    {
        $count ??= config('seeding.customers');
        $reviewsPerCustomer ??= config('seeding.reviews_per_customer');
        $ordersPerCustomer ??= config('seeding.orders_per_customer');

        $restaurantCount = Restaurant::count();

        for ($i = 1; $i <= $count; $i++) {
            Customer::factory()
                ->hasOrders($ordersPerCustomer)
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
                    Restaurant::inRandomOrder()->value('id'),
                    fn () => ['rank' => rand(1, 5)],
                    'favoriteRestaurants'
                )
                ->create();

            if ($progressCallback) {
                $progressCallback($i, $count);
            }
        }
    }
}
