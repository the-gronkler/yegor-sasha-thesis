<?php

namespace Database\Seeders\big_scary_pivots;

use App\Models\MenuItem;
use Illuminate\Database\Seeder;
use App\Models\Order;

class OrderSeeder extends Seeder
{
    public function run(): void
    {
        // Using factory that handles needed logic inside
        Order::factory()
            ->count(30)
            ->hasAttached(
                MenuItem::factory()->count(3),
                fn () => ['quantity' => rand(1, 3)], // Configuring pivot data
                'menuItems'
            )
            ->create();
    }
}
