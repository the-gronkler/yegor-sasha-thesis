<?php

namespace Database\Factories;

use App\Models\FoodType;
use App\Models\Restaurant;
use Illuminate\Database\Eloquent\Factories\Factory;

class FoodTypeFactory extends Factory
{
    protected $model = FoodType::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->word(),
            'restaurant_id' => Restaurant::inRandomOrder()->value('id'),
        ];
    }
}
