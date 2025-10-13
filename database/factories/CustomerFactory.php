<?php

namespace Database\Factories;

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
            // Perform actions after creating the customer (e.g., assigning roles, sending welcome email).
        });
    }
}
