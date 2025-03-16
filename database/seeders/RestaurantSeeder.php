<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Restaurant;
use App\Models\FoodType;
use App\Models\MenuItem;
use App\Models\Image;
use App\Models\Allergen;

class RestaurantSeeder extends Seeder
{
    public function run(): void
    {
        // Create Restaurants
        $restaurant1 = Restaurant::create([
            'name' => 'Pizza Paradise',
            'address' => '123 Food Street, NY',
            'latitude' => 40.7128,
            'longitude' => -74.0060,
            'description' => 'Best pizza in town!',
            'rating' => 4.5
        ]);

        $restaurant2 = Restaurant::create([
            'name' => 'Burger Haven',
            'address' => '456 Burger Ave, LA',
            'latitude' => 34.0522,
            'longitude' => -118.2437,
            'description' => 'Delicious burgers and fries!',
            'rating' => 4.8
        ]);

        // Create Food Types
        $pizzaType = FoodType::create(['name' => 'Pizza', 'restaurant_id' => $restaurant1->id]);
        $pastaType = FoodType::create(['name' => 'Pasta', 'restaurant_id' => $restaurant1->id]);

        $burgerType = FoodType::create(['name' => 'Burger', 'restaurant_id' => $restaurant2->id]);
        $bingusType = FoodType::create(['name' => 'Bingus', 'restaurant_id' => $restaurant2->id]);
        $dessertType = FoodType::create(['name' => 'Dessert', 'restaurant_id' => $restaurant2->id]);

        // Create Menu Items (More Items Added)
        $menuItems = [
            ['Pizza Margherita', 10.99, $pizzaType, 'Classic cheese and tomato pizza.'],
            ['Pepperoni Pizza', 12.99, $pizzaType, 'Classic pepperoni pizza with extra cheese.'],
            ['Spaghetti Carbonara', 11.49, $pastaType, 'Creamy pasta with pancetta.'],
            ['Lasagna', 13.99, $pastaType, 'Rich lasagna with beef ragu.'],
            ['Cheese Burger', 9.99, $burgerType, 'Juicy beef patty with melted cheese.'],
            ['Double Bacon Burger', 11.99, $burgerType, 'Two patties, crispy bacon, and cheddar.'],
            ['Juicy Bingus Salad', 22.99, $bingusType, 'W Rizz'],
            ['Chocolate Cake', 6.49, $dessertType, 'Decadent chocolate cake slice.'],
        ];

        $menuItemModels = [];
        foreach ($menuItems as $item) {
            $menuItemModels[] = MenuItem::create([
                'restaurant_id' => $item[2]->restaurant_id,
                'name' => $item[0],
                'price' => $item[1],
                'description' => $item[3], // this is now just the string
                'food_type_id' => $item[2]->id,
            ]);
        }

        // Create Images
        foreach ($menuItemModels as $index => $menuItem) {
            Image::create([
                'description' => $menuItem->name . ' Image',
                'restaurant_id' => $menuItem->restaurant_id,
                'menu_item_id' => $menuItem->id,
                'is_primary_for_restaurant' => $index < 2, // just mark the first two as primary
                'is_primary_for_menu_item' => true,
            ]);
        }

        // Create Allergens & Attach to Menu Items
        $gluten = Allergen::firstOrCreate(['name' => 'Gluten']);
        $dairy = Allergen::firstOrCreate(['name' => 'Dairy']);

        foreach ($menuItemModels as $menuItem) {
            DB::table('menu_item_allergen')->insert([
                ['menu_item_id' => $menuItem->id, 'allergen_id' => $gluten->id],
                ['menu_item_id' => $menuItem->id, 'allergen_id' => $dairy->id],
            ]);
        }
    }
}
