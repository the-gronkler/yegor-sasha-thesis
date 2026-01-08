<?php

namespace Database\Factories;

use App\Models\Allergen;
use App\Models\FoodType;
use App\Models\Image;
use App\Models\MenuItem;
use App\Models\Restaurant;
use Illuminate\Database\Eloquent\Factories\Factory;

class RestaurantFactory extends Factory
{
    protected $model = Restaurant::class;

    protected ?float $centerLat = null;

    protected ?float $centerLon = null;

    protected ?float $radiusKm = null;

    /**
     * Predefined restaurant descriptions.
     */
    protected static array $restaurantDescriptions = [
        'A cozy place with a warm atmosphere and delicious food.',
        'Known for its exceptional service and mouthwatering dishes.',
        'A family-friendly restaurant offering a variety of cuisines.',
        'Perfect for a romantic dinner or a casual outing.',
        'A hidden gem with a unique menu and great ambiance.',
        'Famous for its signature dishes and friendly staff.',
        'A modern eatery with a focus on fresh, local ingredients.',
        'A vibrant spot with live music and a lively crowd.',
        'A fine dining experience with exquisite flavors.',
        'A casual spot with affordable prices and great portions.',
        'A trendy restaurant with a creative and innovative menu.',
        'A charming place with a rustic vibe and hearty meals.',
        'A seafood lover’s paradise with fresh catches daily.',
        'A vegetarian-friendly restaurant with plenty of options.',
        'A dessert haven with the best sweets in town.',
        'A steakhouse known for its perfectly cooked meats.',
        'A bustling cafe with great coffee and light bites.',
        'A fusion restaurant blending flavors from around the world.',
        'A pizza lover’s dream with authentic Italian recipes.',
        'A breakfast and brunch spot with a cozy feel.',
        'An upscale bistro with a curated wine selection.',
        'A lively diner with classic comfort food favorites.',
        'A rooftop restaurant with stunning city views.',
        'A farm-to-table eatery with seasonal specialties.',
        'A Mediterranean-inspired restaurant with bold flavors.',
        'A sushi bar offering fresh and creative rolls.',
        'A barbecue joint with smoky, tender meats.',
        'A tapas bar with small plates perfect for sharing.',
        'A gastropub with craft beers and hearty meals.',
        'A noodle house with authentic Asian recipes.',
        'A bakery cafe with freshly baked bread and pastries.',
        'A Caribbean restaurant with tropical vibes and flavors.',
        'A French patisserie with delicate desserts and coffee.',
        'A Mexican cantina with vibrant decor and spicy dishes.',
        'A health-focused cafe with smoothies and salads.',
        'A retro diner with milkshakes and burgers.',
        'A wine bar with artisanal cheese pairings.',
        'A cozy tea house with a wide selection of blends.',
        'A German beer hall with hearty sausages and pretzels.',
        'A Hawaiian-themed restaurant with poke bowls and more.',
        'A Peruvian restaurant with bold and unique flavors.',
        'A Southern-style eatery with fried chicken and biscuits.',
        'A Scandinavian cafe with minimalist decor and fresh dishes.',
        'A Moroccan restaurant with aromatic spices and tagines.',
        'A vegan bistro with creative plant-based dishes.',
        'A Brazilian steakhouse with endless meat options.',
        'A Himalayan restaurant with warm curries and momos.',
        'A Polish restaurant with pierogis and hearty soups.',
        'A Turkish grill with kebabs and fresh bread.',
        'A Lebanese restaurant with mezze and shawarma.',
    ];

    public function center(float $lat, float $lon): self
    {
        $this->centerLat = $lat;
        $this->centerLon = $lon;

        return $this;
    }

    public function radius(float $km): self
    {
        $this->radiusKm = $km;

        return $this;
    }

    private function gaussianRandom(float $mean, float $stddev): float
    {
        // Box-Muller transform for normal distribution
        // Use mt_rand() / mt_getrandmax() and ensure u1 is in (0, 1) so log(u1) is well-defined.
        do {
            $u1 = mt_rand() / mt_getrandmax();
        } while ($u1 <= 0.0 || $u1 >= 1.0);
        $u2 = mt_rand() / mt_getrandmax();
        $z0 = sqrt(-2 * log($u1)) * cos(2 * pi() * $u2);

        return $z0 * $stddev + $mean;
    }

    public function definition(): array
    {
        $centerLat = $this->centerLat ?? config('seeding.center_lat', 52.2297);
        $centerLon = $this->centerLon ?? config('seeding.center_lon', 21.0122);
        $radiusKm = $this->radiusKm ?? config('seeding.radius', 10);

        // Calculate offsets using Gaussian distribution
        $latOffset = $this->gaussianRandom(0, $radiusKm / 111); // Approx 111 km per degree latitude
        $cosLat = cos(deg2rad($centerLat));
        // Prevent division by a very small cosine near the poles, which would create huge longitude offsets
        $cosLat = max($cosLat, 0.01);
        $lonOffset = $this->gaussianRandom(0, $radiusKm / (111 * $cosLat)); // Adjust for longitude

        return [
            'name' => $this->faker->company(),
            'address' => $this->faker->address(),
            'latitude' => $centerLat + $latOffset,
            'longitude' => $centerLon + $lonOffset,
            'description' => self::$restaurantDescriptions[array_rand(self::$restaurantDescriptions)],
            'rating' => $this->faker->randomFloat(2, 1, 5),
            'opening_hours' => $this->faker->randomElement([
                '10:00 - 22:00',
                '11:00 - 23:00',
                '12:00 - 21:00',
                '09:00 - 20:00',
                '08:00 - 18:00',
            ]),
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
                    ->each(function (MenuItem $mi) {
                        // Create restaurant-level images (not linked to menu items)
                        // These will be available for selection

                        // Optionally attach allergens so seeded menu items have realistic allergen data
                        $allergenIds = Allergen::pluck('id');
                        if ($allergenIds->count() > 0) {
                            $attachCount = rand(1, min(3, $allergenIds->count()));
                            $subset = $allergenIds->random($attachCount);
                            $mi->allergens()->attach(
                                $subset->mapWithKeys(fn ($id) => [$id => []])
                            );
                        }
                    });
            }

            // Create restaurant images (not linked to specific menu items)
            // These are the images that can be selected for menu items
            $restaurantImages = Image::factory()
                ->count(rand(5, 10))
                ->create([
                    'restaurant_id' => $restaurant->id,
                    'menu_item_id' => null, // Not linked to specific menu items
                    'is_primary_for_menu_item' => false,
                    'is_primary_for_restaurant' => false,
                ]);

            // Set one as primary for restaurant
            if ($restaurantImages->count() > 0) {
                $restaurantImages->first()->update([
                    'is_primary_for_restaurant' => true,
                    'description' => 'Primary restaurant image',
                ]);
            }

            // Now assign random restaurant images to menu items via image_id
            $imageIds = $restaurantImages->pluck('id');
            foreach ($restaurant->menuItems as $mi) {
                if ($imageIds->count() > 0) {
                    $mi->update([
                        'image_id' => $imageIds->random(),
                    ]);
                }
            }
        });
    }
}
