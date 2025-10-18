<?php

namespace Database\Factories;

use App\Models\FoodType;
use App\Models\Restaurant;
use Illuminate\Database\Eloquent\Factories\Factory;

class FoodTypeFactory extends Factory
{
    protected $model = FoodType::class;

    /**
     * Predefined food type names.
     */
    protected static array $foodTypes = [
        'Soup',
        'Pasta',
        'Pizza',
        'Salad',
        'Burger',
        'Sandwich',
        'Steak',
        'Sushi',
        'Tacos',
        'Curry',
        'BBQ',
        'Seafood',
        'Dessert',
        'Appetizer',
        'Breakfast',
        'Brunch',
        'Noodles',
        'Rice',
        'Wraps',
        'Grill',
    ];

    public function definition(): array
    {
        return [
            'name' => self::$foodTypes[array_rand(self::$foodTypes)],
            'restaurant_id' => Restaurant::inRandomOrder()->value('id'),
        ];
    }
}
