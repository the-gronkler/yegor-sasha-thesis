<?php

namespace Database\Factories;

use App\Models\FoodType;
use App\Models\MenuItem;
use App\Models\Restaurant;
use Illuminate\Database\Eloquent\Factories\Factory;

class MenuItemFactory extends Factory
{
    protected $model = MenuItem::class;

    public function definition(): array
    {
        return [
            'restaurant_id' => Restaurant::inRandomOrder()->value('id'),
            'name' => $this->faker->word(),
            'price' => $this->faker->randomFloat(2, 1, 100),
            'description' => $this->faker->sentence(),
            'food_type_id' => FoodType::factory(),
        ];
    }
}
