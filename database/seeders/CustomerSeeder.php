<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Restaurant;
use Illuminate\Database\Seeder;

class CustomerSeeder extends Seeder
{
    public function run(?int $count = null, ?int $ordersPerCustomer = null, ?callable $progressCallback = null): void
    {
        $count ??= config('seeding.customers');
        $ordersPerCustomer ??= config('seeding.orders_per_customer');

        // Use batch creation for better performance
        // Use smaller batches (10) due to complex relationships (orders, favorites)
        // This balances performance with memory usage and progress tracking
        $created = 0;
        $batchSize = 10;

        while ($created < $count) {
            $remaining = $count - $created;
            $batchCount = min($batchSize, $remaining);

            Customer::factory()
                ->count($batchCount)
                ->hasOrders($ordersPerCustomer)
                ->hasAttached(
                    Restaurant::inRandomOrder()->value('id'),
                    fn () => ['rank' => rand(1, 5)],
                    'favoriteRestaurants'
                )
                ->create();

            $created += $batchCount;

            if ($progressCallback) {
                $progressCallback($created, $count);
            }
        }
    }
}
