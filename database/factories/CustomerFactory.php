<?php

namespace Database\Factories;

use App\Models\Restaurant;
use App\Models\Review;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Customer>
 */
class CustomerFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'payment_method_token' => null,
        ];
    }

    /**
     * Indicate that the customer has no payment method token.
     *
     * @return $this
     */
    public function withPaymentMethodToken()
    {
        return $this->state(function (array $attributes) {
            return [
                'payment_method_token' => (string) Str::uuid(),
            ];
        });
    }

    /**
     * Configure the model factory.
     *
     * @return $this
     */
    public function configure()
    {
        return $this->afterCreating(function ($customer) {
            // Attach favorite restaurants if none have been attached via hasAttached
            if (! $customer->favoriteRestaurants()->exists()) {
                $restaurants = Restaurant::inRandomOrder()->take(rand(1, 3))->pluck('id');
                $pivot = $restaurants->mapWithKeys(fn ($id, $i) => [
                    $id => ['rank' => $i + 1],
                ])->toArray();
                $customer->favoriteRestaurants()->attach($pivot);
            }
        });
    }

    public function hasReviews(int $count = 3): static
    {
        return $this->afterCreating(function ($customer) use ($count) {
            $restaurants = $customer->favoriteRestaurants()->pluck('id');
            foreach ($restaurants as $restaurantId) {
                Review::factory()
                    ->count($count)
                    ->create([
                        'customer_user_id' => $customer->user_id,
                        'restaurant_id' => $restaurantId,
                    ]);
            }
        });
    }
}
