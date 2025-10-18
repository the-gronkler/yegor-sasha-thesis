<?php

namespace Database\Factories;

use App\Models\Order;
use App\Models\Customer;
use App\Models\Restaurant;
use App\Models\OrderStatus;
use Illuminate\Database\Eloquent\Factories\Factory;

class OrderFactory extends Factory
{
    protected $model = Order::class;

    public function definition(): array
    {
        return [
            'restaurant_id' => Restaurant::inRandomOrder()->value('id'),
            'customer_user_id' => Customer::factory(),
            'order_status_id' => OrderStatus::inRandomOrder()->value('id'),
            'time_placed' => now()->subMinutes(rand(0, 1000)),
            'notes' => $this->faker->optional()->sentence(),
        ];
    }

    public function configure(): static
    {
        return $this->afterCreating(function (Order $order) {
            $menuItems = $order->restaurant->menuItems;
            if ($menuItems->isNotEmpty()) {
                // Ensure unique menu items are selected
                $picked = $menuItems->unique()->random(rand(1, min(5, $menuItems->count())));
                $pivot = $picked->mapWithKeys(fn($item) => [
                    $item->id => ['quantity' => rand(1, 3)]
                ])->toArray();

                $order->menuItems()->attach($pivot);
            }
        });
    }
}
