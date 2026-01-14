<?php

namespace Database\Seeders;

use App\Models\Restaurant;
use Illuminate\Database\Seeder;

class RestaurantSeeder extends Seeder
{
    public function run(?int $count = null, ?float $lat = null, ?float $lon = null, ?float $radius = null, ?callable $progressCallback = null): void
    {
        $count ??= config('seeding.restaurants');

        // Use batch creation for much better performance
        // Create in batches of 100 to balance performance with progress updates
        $created = 0;
        $batchSize = 100;

        while ($created < $count) {
            $remaining = $count - $created;
            $batchCount = min($batchSize, $remaining);

            Restaurant::factory()
                ->center($lat ?? config('seeding.center_lat'), $lon ?? config('seeding.center_lon'))
                ->radius($radius ?? config('seeding.radius'))
                ->count($batchCount)
                ->create();

            $created += $batchCount;

            if ($progressCallback) {
                $progressCallback($created, $count);
            }
        }
    }
}
