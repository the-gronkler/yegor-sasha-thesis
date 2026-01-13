<?php

namespace Database\Seeders;

use App\Models\Restaurant;
use Illuminate\Database\Seeder;

class RestaurantSeeder extends Seeder
{
    public function run(?int $count = null, ?float $lat = null, ?float $lon = null, ?float $radius = null, ?callable $progressCallback = null): void
    {
        $count ??= config('seeding.restaurants');

        for ($i = 1; $i <= $count; $i++) {
            Restaurant::factory()
                ->center($lat ?? config('seeding.center_lat'), $lon ?? config('seeding.center_lon'))
                ->radius($radius ?? config('seeding.radius'))
                ->create();

            if ($progressCallback) {
                $progressCallback($i, $count);
            }
        }
    }
}
