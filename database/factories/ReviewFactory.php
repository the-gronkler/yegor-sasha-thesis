<?php

namespace Database\Factories;

use App\Models\Review;
use App\Models\Customer;
use App\Models\Restaurant;
use Illuminate\Database\Eloquent\Factories\Factory;

class ReviewFactory extends Factory
{
    protected $model = Review::class;

    /**
     * Predefined sample data for reviews.
     */
    protected static array $sampleTitles = [
        'Amazing experience!',
        'Just okay.',
        'Highly recommended!',
        'Not impressed',
        'Great food, slow service',
        'Would eat here again',
        'Terrible service!',
        'Loved everything',
    ];

    protected static array $sampleContents = [
        'The food was fantastic and the service was friendly.',
        'It was alright. Nothing special.',
        'Everything was perfect from start to finish.',
        'I had higher expectations. It didn’t live up to the hype.',
        'The burger was great, but it took forever to arrive.',
        'Very cozy place and the pizza was delicious.',
        'Honestly, the staff was rude and the food was cold.',
        'Super fresh ingredients, big portions. Loved it!',
    ];

    public function definition(): array
    {
        $i = rand(0, count(self::$sampleTitles) - 1);

        return [
            'customer_user_id' => Customer::factory(), // creates a Customer and uses its primary key
            'restaurant_id' => Restaurant::factory(),
            'rating' => rand(1, 5),
            'title' => self::$sampleTitles[$i],
            'content' => self::$sampleContents[$i],
        ];
    }

    public function configure(): static
    {
        return $this->afterCreating(function (Review $review) {
            // Create a review image
            $review->reviewImages()->create([
                'image' => $this->faker->imageDataUri(),
            ]);
        });
    }

    /**
     * Optionally, you can force using the sample pool (in case we override).
     */
    public function useSampleTexts(): static
    {
        return $this->state(fn (array $attrs) => [
            'title' => self::$sampleTitles[rand(0, count(self::$sampleTitles) - 1)],
            'content' => self::$sampleContents[rand(0, count(self::$sampleContents) - 1)],
        ]);
    }
}
