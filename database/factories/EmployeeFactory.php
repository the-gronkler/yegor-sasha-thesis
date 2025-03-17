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
     */
    public function definition(): array
    {
        // Ensure a user is created first
        $user = User::factory()->create();

        // Use the provided restaurant ID or fetch a random one if not provided
        $restaurantId = $this->restaurantId ?? Restaurant::inRandomOrder()->first()?->id ?? Restaurant::factory()->create()->id;


        return [
            'user_id' => $user->id, // Use the ID of the created User
            'restaurant_id' => $restaurantId,
            'is_admin' => fake()->boolean(), // Generates a random boolean value (true or false)
        ];
    }

    /**
     * Indicate that the employee belongs to a specific restaurant.
     *
     * @param  int  $restaurantId
     * @return $this
     */
    public function forRestaurant(int $restaurantId)
    {
        $this->restaurantId = $restaurantId;

        return $this;
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
