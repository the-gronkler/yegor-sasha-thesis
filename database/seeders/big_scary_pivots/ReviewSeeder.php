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
        Review::factory()
            ->count(20)
            ->create();  // uses the factory’s definition with sample texts
    }
}
