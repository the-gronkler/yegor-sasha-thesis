<?php

namespace Database\Factories;

use App\Models\Restaurant;
use App\Models\FoodType;
use App\Models\MenuItem;
use App\Models\Image;
use App\Models\Allergen;
use Illuminate\Database\Eloquent\Factories\Factory;

class RestaurantFactory extends Factory
{
    protected $model = Restaurant::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->company(),
            'address' => $this->faker->address(),
            'latitude' => $this->faker->latitude(),
            'longitude' => $this->faker->longitude(),
            'description' => $this->faker->paragraph(),
            'rating' => $this->faker->randomFloat(2, 1, 5),
        ];
    }

    public function configure(): static
    {
        return $this->afterCreating(function (Restaurant $restaurant) {
            // Create some FoodTypes for this restaurant
            $foodTypes = FoodType::factory()
                ->count(rand(2, 4))
                ->create(['restaurant_id' => $restaurant->id]);

            // For each FoodType, create several MenuItems
            foreach ($foodTypes as $ft) {
                $menuCount = rand(3, 6);
                MenuItem::factory()
                    ->count($menuCount)
                    ->state([
                        'restaurant_id' => $restaurant->id,
                        'food_type_id' => $ft->id,
                    ])
                    ->create()
                    ->each(function (MenuItem $mi) use ($restaurant) {
                        // For each menu item, attach a primary image
                        Image::factory()->create([
                            'restaurant_id' => $restaurant->id,
                            'menu_item_id' => $mi->id,
                            'is_primary_for_menu_item' => true,
                            'is_primary_for_restaurant' => false,
                        ]);

                        // Optionally attach more images (non-primary)
                        $extraCount = rand(0, 2);
                        if ($extraCount > 0) {
                            Image::factory()
                                ->count($extraCount)
                                ->state([
                                    'restaurant_id' => $restaurant->id,
                                    'menu_item_id' => $mi->id,
                                    'is_primary_for_menu_item' => false,
                                    'is_primary_for_restaurant' => false,
                                ])
                                ->create();
                        }
                    });
            }

            // Mark one image as primary for restaurant (based on one menu item)
            $firstMenuItem = $restaurant->menuItems()->first();
            if ($firstMenuItem) {
                $restaurant->images()->create([
                    'menu_item_id' => $firstMenuItem->id,
                    'is_primary_for_restaurant' => true,
                    'is_primary_for_menu_item' => false,
                    'description' => 'Primary image for restaurant',
                ]);
            }

            // Attach allergens to menu items
            $allergenIds = Allergen::pluck('id');
            foreach ($restaurant->menuItems as $mi) {
                $attachCount = rand(1, min(3, $allergenIds->count()));
                $subset = $allergenIds->random($attachCount);
                $mi->alergens()->attach(
                    $subset->mapWithKeys(fn($id) => [$id => []])
                );
            }
        });
    }
}
