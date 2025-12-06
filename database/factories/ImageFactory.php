<?php

namespace Database\Factories;

use App\Models\Image;
use Illuminate\Database\Eloquent\Factories\Factory;

class ImageFactory extends Factory
{
    protected $model = Image::class;

    /**
     * Array of real image URLs for seeding.
     */
    protected static array $realImageUrls = [
    'https://www.foodiesfeed.com/wp-content/uploads/2023/06/burger-with-melted-cheese.jpg',
    'https://www.foodiesfeed.com/wp-content/uploads/2023/09/fresh-vegetables.jpg',
    'https://www.foodiesfeed.com/wp-content/uploads/ff-images/2025/06/crispy-fried-chicken-drumstick-in-hot-oil.webp',
    'https://www.foodiesfeed.com/wp-content/uploads/2023/05/pizza-salami.jpg',
    'https://www.foodiesfeed.com/wp-content/uploads/2023/12/pizza-salami-close-up.jpg',
    'https://www.foodiesfeed.com/wp-content/uploads/2023/05/freshly-prepared-beef-steak-with-vegetables.jpg',
    'https://www.foodiesfeed.com/wp-content/uploads/ff-images/2025/06/grilled-meat-wrap-with-fresh-vegetables-and-fries.webp',
    'https://www.foodiesfeed.com/wp-content/uploads/ff-images/2025/01/flavorful-shrimp-feast-with-lemon-and-corn.png',
    'https://www.foodiesfeed.com/wp-content/uploads/ff-images/2025/08/flavorful-tacos-with-guacamole-and-beer.webp',
    'https://www.foodiesfeed.com/wp-content/uploads/ff-images/2025/08/fresh-tacos-being-assembled-in-busy-kitchen.webp',
    'https://www.foodiesfeed.com/wp-content/uploads/ff-images/2025/06/colorful-sushi-rolls-floating-in-air.webp',
];

    public function definition(): array
    {
        return [
            'image' => self::$realImageUrls[array_rand(self::$realImageUrls)],
            'description' => $this->faker->sentence(),
            'restaurant_id' => null,
            'menu_item_id' => null,
            'is_primary_for_restaurant' => false,
            'is_primary_for_menu_item' => false,
        ];
    }
}
