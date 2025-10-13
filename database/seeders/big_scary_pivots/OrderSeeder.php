<?php

namespace Database\Seeders\big_scary_pivots;

use App\Models\Order;
use App\Models\MenuItem;
use App\Models\Customer;
use App\Models\Restaurant;
use App\Models\OrderStatus;
use Illuminate\Database\Seeder;

class OrderSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get customers and other necessary data
        $customers = Customer::all();
        $restaurants = Restaurant::all();
        $orderStatuses = OrderStatus::all();

        if ($customers->isEmpty() || $restaurants->isEmpty() || $orderStatuses->isEmpty()) {
            return; // Avoid running if data is missing
        }

        // Generate 10 orders
        for ($i = 0; $i < 10; $i++) {
            $customer = $customers->random();
            $restaurant = $restaurants->random();
            $status = $orderStatuses->random();

            $order = Order::create([
                'restaurant_id' => $restaurant->id,
                'customer_user_id' => $customer->user_id, // Link customer to the user ID
                'order_status_id' => $status->id,
                'notes' => fake()->optional()->sentence(),
            ]);

            // Get menu items for the specific restaurant
            $menuItems = MenuItem::where('restaurant_id', $restaurant->id)->get();

            // Attach random menu items from the same restaurant
            $order->menuItems()->attach(
                $menuItems->random(rand(1, 5))->pluck('id')->mapWithKeys(fn($id) => [$id => ['quantity' => rand(1, 3)]])
            );
        }
    }
}
