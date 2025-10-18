<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Restaurant;
use Illuminate\Database\Seeder;

class CustomerSeeder extends Seeder
{
    public function run(): void
    {
        Customer::factory()
            ->count(5)
            ->hasOrders(4) // requires orders() on model and OrderFactory
            ->hasReviews(2) // requires reviews() on model and ReviewFactory
            ->hasAttached(
                Restaurant::inRandomOrder()->value('id'),  // requires favoriteRestaurants() on model
                fn () => ['rank' => rand(1, 5)],
                'favoriteRestaurants'
            )
            ->create();
    }
}
