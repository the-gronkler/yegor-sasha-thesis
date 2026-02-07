<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Restaurant;
use App\Models\Review;
use App\Models\ReviewImage;
use Illuminate\Database\Seeder;

class ReviewSeeder extends Seeder
{
    public function run(?callable $progressCallback = null): void
    {
        $restaurants = Restaurant::all();
        $customerIds = Customer::pluck('user_id')->toArray();

        if (empty($customerIds)) {
            return;
        }

        $sampleImageUrl = url('images/seed/sample-review.png');
        $processed = 0;

        foreach ($restaurants as $restaurant) {
            $reviewCount = rand(2, min(14, count($customerIds)));

            $selectedCustomerIds = collect($customerIds)
                ->shuffle()
                ->take($reviewCount);

            $reviewIndex = 0;

            foreach ($selectedCustomerIds as $customerId) {
                $review = Review::factory()->create([
                    'customer_user_id' => $customerId,
                    'restaurant_id' => $restaurant->id,
                ]);

                if ($reviewIndex % 3 === 0) {
                    ReviewImage::create([
                        'review_id' => $review->id,
                        'image' => $sampleImageUrl,
                    ]);
                }

                $reviewIndex++;
            }

            $restaurant->recalculateRating();
            $processed++;

            if ($progressCallback) {
                $progressCallback($processed, $restaurants->count());
            }
        }
    }
}
