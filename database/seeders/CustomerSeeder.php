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
            ->count(30)
            ->hasOrders(4) // requires orders() on model and OrderFactory
            ->hasAttached(
                Restaurant::factory()->count(3),  // requires favoriteRestaurants() on model
                fn () => ['rank' => rand(1, 5)],
                'favoriteRestaurants'
            )
            ->create();
    }
}
