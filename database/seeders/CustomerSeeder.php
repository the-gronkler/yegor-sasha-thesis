<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Restaurant;
use App\Models\Review;
use Illuminate\Database\Seeder;

class CustomerSeeder extends Seeder
{
    public function run(): void
    {
        Customer::factory()
            ->count(5)
            ->hasOrders(4) // requires orders() on model and OrderFactory
            ->afterCreating(function (Customer $customer) {
                $restaurants = Restaurant::inRandomOrder()->take(2)->get();

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
