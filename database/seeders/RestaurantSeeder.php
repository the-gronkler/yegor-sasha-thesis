<?php

namespace Database\Seeders;

use App\Models\Restaurant;
use Illuminate\Database\Seeder;

class RestaurantSeeder extends Seeder
{
    public function run(?int $count = null, ?float $lat = null, ?float $lon = null, ?float $radius = null): void
    {
        $count ??= config('seeding.restaurants');
        Restaurant::factory()
            ->count($count)
            ->center($lat ?? config('seeding.center_lat'), $lon ?? config('seeding.center_lon'))
            ->radius($radius ?? config('seeding.radius'))
            ->create();
    }
}
