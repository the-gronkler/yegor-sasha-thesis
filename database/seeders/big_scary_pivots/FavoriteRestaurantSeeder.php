<?php

namespace Database\Seeders\big_scary_pivots;

use Illuminate\Database\Seeder;
use App\Models\Customer;
use App\Models\Restaurant;

class FavoriteRestaurantSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $customers = Customer::all();
        $restaurants = Restaurant::all();

        if ($customers->isEmpty() || $restaurants->isEmpty()) {
            $this->command->warn("No customers or restaurants found. Skipping FavoriteRestaurantSeeder.");
            return;
        }

        foreach ($customers as $customer) {
            // each customer gets 1 to 5 favorites
            $count = rand(1, min(5, $restaurants->count()));
            $favRestaurants = collect(
                $restaurants->random($count)
            )->values(); // so it will be a collection in case of 1 item

            foreach ($favRestaurants as $index => $restaurant) {
                $customer->favoriteRestaurants()->attach($restaurant->id, [
                    'rank' => $index + 1,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}
