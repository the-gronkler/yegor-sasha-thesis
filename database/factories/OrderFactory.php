<?php

namespace Database\Factories;

use App\Models\Customer;
use App\Models\Order;
use App\Models\OrderStatus;
use App\Models\Restaurant;
use Illuminate\Database\Eloquent\Factories\Factory;

class OrderFactory extends Factory
{
    protected $model = Order::class;

    /**
     * Predefined order notes.
     */
    protected static array $orderNotes = [
        'Please deliver to the back door.',
        'No onions, please.',
        'Extra spicy.',
        'Leave the food at the doorstep.',
        'Add extra napkins.',
        'Please include utensils.',
        'No cheese on the burger.',
        'Gluten-free options only.',
        'Call upon arrival.',
        'Add extra sauce.',
        'No peanuts due to allergies.',
        'Deliver as soon as possible.',
        'Please separate the sauces.',
        'No pickles on the sandwich.',
        'Add extra toppings.',
        'Make it well-done.',
        'Please include a receipt.',
        'No dairy products.',
        'Add extra dressing on the side.',
        'Deliver between 6 PM and 7 PM.',
    ];

    public function definition(): array
    {
        return [
            'restaurant_id' => Restaurant::inRandomOrder()->value('id'),
            'customer_user_id' => Customer::factory(),
            'order_status_id' => OrderStatus::inRandomOrder()->value('id'),
            'time_placed' => now()->subMinutes(rand(0, 1000)),
            'notes' => rand(0, 1) ? self::$orderNotes[array_rand(self::$orderNotes)] : null,
        ];
    }

    public function configure(): static
    {
        return $this->afterCreating(function (Order $order) {
            $menuItems = $order->restaurant->menuItems;
            if ($menuItems->isNotEmpty()) {
                // Ensure unique menu items are selected
                $picked = $menuItems->random(rand(1, min(5, $menuItems->count())));
                $pivot = $picked->mapWithKeys(fn ($item) => [
                    $item->id => ['quantity' => rand(1, 3)],
                ])->toArray();

                $order->menuItems()->attach($pivot);
            }
        });
    }
}
