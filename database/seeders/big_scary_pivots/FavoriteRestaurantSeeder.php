<?php

namespace Database\Seeders\big_scary_pivots;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
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
            // Each customer gets 1-1 <--(can change that) favorite restaurants
            $favRestaurants = $restaurants->random(rand(1, min(1, $restaurants->count())))->values();

            foreach ($favRestaurants as $index => $restaurant) {
                DB::table('favorite_restaurants')->insert([
                    'customer_user_id' => $customer->user_id,
                    'restaurant_id' => $restaurant->id,
                    'rank' => $index + 1, // rank starts at 1
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}
