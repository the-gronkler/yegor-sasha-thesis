<?php

namespace Database\Seeders\big_scary_pivots;

use Illuminate\Database\Seeder;
use App\Models\Review;
use App\Models\Restaurant;
use App\Models\Customer;

class ReviewSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $customers = Customer::all();
        $restaurants = Restaurant::all();

        if ($customers->isEmpty() || $restaurants->isEmpty()) {
            $this->command->warn("No customers or restaurants found. Skipping ReviewSeeder.");
            return;
        }

        $sampleTitles = [
            'Amazing experience!',
            'Just okay.',
            'Highly recommended!',
            'Not impressed',
            'Great food, slow service',
            'Would eat here again',
            'Terrible service!',
            'Loved everything',
        ];

        $sampleContents = [
            'The food was fantastic and the service was friendly.',
            'It was alright. Nothing special.',
            'Everything was perfect from start to finish.',
            'I had higher expectations. It didn’t live up to the hype.',
            'The burger was great, but it took forever to arrive.',
            'Very cozy place and the pizza was delicious.',
            'Honestly, the staff was rude and the food was cold.',
            'Super fresh ingredients, big portions. Loved it!',
        ];

        // Create 20 random reviews
        for ($i = 0; $i < 20; $i++) {
            $customer = $customers->random();
            $restaurant = $restaurants->random();

            Review::create([
                'customer_user_id' => $customer->user_id,
                'restaurant_id' => $restaurant->id,
                'rating' => rand(1, 5),
                'title' => $sampleTitles[array_rand($sampleTitles)],
                'content' => $sampleContents[array_rand($sampleContents)],
            ]);
        }
    }
}
