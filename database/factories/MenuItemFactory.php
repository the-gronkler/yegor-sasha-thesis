<?php

namespace Database\Factories;

use App\Models\MenuItem;
use App\Models\Restaurant;
use App\Models\FoodType;
use Illuminate\Database\Eloquent\Factories\Factory;

class MenuItemFactory extends Factory
{
    protected $model = MenuItem::class;

    /**
     * Predefined menu item names.
     */
    protected static array $menuItemNames = [
        'Margherita Pizza',
        'Caesar Salad',
        'Spaghetti Carbonara',
        'Grilled Chicken Sandwich',
        'Cheeseburger',
        'Vegetable Stir Fry',
        'Beef Tacos',
        'Chicken Curry',
        'Seafood Paella',
        'Mushroom Risotto',
        'BBQ Ribs',
        'Fish and Chips',
        'Shrimp Scampi',
        'Eggplant Parmesan',
        'Lobster Bisque',
        'French Onion Soup',
        'Pancakes',
        'Waffles',
        'Avocado Toast',
        'Chocolate Lava Cake',
    ];

    /**
     * Predefined menu item descriptions.
     */
    protected static array $menuItemDescriptions = [
        'A classic dish made with fresh ingredients and a touch of love.',
        'Perfectly seasoned and cooked to perfection.',
        'A delightful combination of flavors that will tantalize your taste buds.',
        'Served with a side of crispy fries and a refreshing drink.',
        'Made with the finest ingredients for a truly unforgettable experience.',
        'A hearty meal that is both satisfying and delicious.',
        'Packed with bold flavors and a hint of spice.',
        'A traditional recipe passed down through generations.',
        'Freshly prepared and bursting with flavor.',
        'A light and healthy option for any time of the day.',
        'Rich, creamy, and absolutely indulgent.',
        'A crowd favorite that never disappoints.',
        'A perfect balance of sweet and savory.',
        'A comforting dish that feels like home.',
        'A gourmet twist on a classic favorite.',
        'A refreshing and flavorful choice for any occasion.',
        'A sweet treat to end your meal on a high note.',
        'A breakfast classic that everyone loves.',
        'A modern take on a timeless dish.',
        'A decadent dessert that is worth every calorie.',
    ];

    public function definition(): array
    {
        return [
            'restaurant_id' => Restaurant::inRandomOrder()->value('id'),
            'name' => self::$menuItemNames[array_rand(self::$menuItemNames)],
            'price' => $this->faker->randomFloat(2, 1, 100),
            'description' => self::$menuItemDescriptions[array_rand(self::$menuItemDescriptions)],
            'food_type_id' => FoodType::factory(),
        ];
    }
}
