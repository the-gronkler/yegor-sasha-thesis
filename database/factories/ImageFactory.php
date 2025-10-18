<?php

namespace Database\Factories;

use App\Models\Image;
use Illuminate\Database\Eloquent\Factories\Factory;

class ImageFactory extends Factory
{
    protected $model = Image::class;

    public function definition(): array
    {
        return [
            'image' => $this->faker->imageUrl(),
            'description' => $this->faker->sentence(),
            'restaurant_id' => null,
            'menu_item_id' => null,
            'is_primary_for_restaurant' => false,
            'is_primary_for_menu_item' => false,
        ];
    }
}
