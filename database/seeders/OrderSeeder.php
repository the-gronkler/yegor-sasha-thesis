<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Order;
use App\Models\Restaurant;
use Illuminate\Database\Seeder;

class OrderSeeder extends Seeder
{
    public function run(?int $ordersPerRestaurant = null, ?callable $progressCallback = null): void
    {
        $ordersPerRestaurant ??= config('seeding.orders_per_restaurant');

        $customerIds = Customer::pluck('user_id')->toArray();

        if (empty($customerIds)) {
            return;
        }

        $total = Restaurant::count();
        $current = 0;

        Restaurant::lazy()->each(function ($restaurant) use ($customerIds, $ordersPerRestaurant, &$current, $total, $progressCallback) {
            $orderCount = rand(max(1, $ordersPerRestaurant - 2), $ordersPerRestaurant + 2);

            for ($i = 0; $i < $orderCount; $i++) {
                $customerId = $customerIds[array_rand($customerIds)];

                Order::factory()->create([
                    'restaurant_id' => $restaurant->id,
                    'customer_user_id' => $customerId,
                ]);
            }

            $current++;

            if ($progressCallback) {
                $progressCallback($current, $total);
            }
        });
    }
}
