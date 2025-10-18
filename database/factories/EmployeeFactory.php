<?php

namespace Database\Factories;

use App\Models\Employee;
use App\Models\Restaurant;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Employee>
 */
class EmployeeFactory extends Factory
{
    protected $model = Employee::class;

    public function definition(): array
    {
        return [
            'user_id'       => User::factory(),
            'restaurant_id' => Restaurant::inRandomOrder()->value('id'),
            'is_admin'      => false,
        ];
    }

    /**
     * Indicates the employee is an admin.
     */
    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_admin' => true,
        ]);
    }

    // Optionally if you want a method to force a specific restaurant instance:
    public function forRestaurant(Restaurant $restaurant): static
    {
        return $this->state(fn (array $attributes) => [
            'restaurant_id' => $restaurant->id,
        ]);
    }

    public function configure(): static
    {
        return $this->afterCreating(function (Employee $employee) {
            // You might want to do something after creation, e.g. assign permissions
        });
    }
}
