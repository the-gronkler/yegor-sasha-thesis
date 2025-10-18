<?php
namespace Database\Factories;

use App\Models\FoodType;
use App\Models\Restaurant;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class FoodTypeFactory extends Factory
{
    protected $model = FoodType::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->word(),
            'restaurant_id' => Restaurant::factory(),
        ];
    }
}
