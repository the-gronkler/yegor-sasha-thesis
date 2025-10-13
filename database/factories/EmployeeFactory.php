<?php

namespace Database\Factories;

use App\Models\Employee;
use App\Models\Restaurant;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\DB;

/**
 * @extends Factory<Employee>
 */

class EmployeeFactory extends Factory
{
    protected $restaurantId;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     * @throws \Exception
     */
    public function definition(): array
    {
        // Use the provided restaurant ID or throw exception
        if (!isset($this->restaurantId))
             throw new \Exception('Restaurant ID not set for EmployeeFactory. Use ->forRestaurant($restaurantId) method to set it.');

        $restaurantId = $this->restaurantId;

        return [
            'user_id' => User::factory()->id,
            'restaurant_id' => $restaurantId,
            'is_admin' => false //fake()->boolean(),
        ];
    }

    /**
     * MANDATORY: cannot have orphaned employees
     * Use this last in the chain to ensure the restaurant ID is set, i.e.:
     * Employee::factory()
     * ->count(1)
     * ->admin()
     * ->forRestaurant($restaurant->id)     <-- this must be last
     * ->create();
     *
     * @param  int  $restaurantId
     * @return $this
     */
    public function forRestaurant(int $restaurantId)
    {
        $this->restaurantId = $restaurantId;

        return $this;
    }

    public function admin()
    {
        return $this->state(function (array $attributes) {
            return [
                'is_admin' => true,
            ];
        });
    }


    /**
     * Configure the model factory.
     *
     * @return $this
     */
//    public function configure()
//    {
//        return $this->afterCreating(function ($employee) {
//            // You might want to perform actions after creating the employee, like assigning roles or permissions.
//        });
//    }
}
