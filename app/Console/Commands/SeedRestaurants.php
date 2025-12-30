<?php

namespace App\Console\Commands;

use App\Services\DatabaseSeederService;
use Illuminate\Console\Command;

class SeedRestaurants extends Command
{
    protected $signature = 'seed:restaurants
                           {--center-lat= : Center latitude (default Warsaw)}
                           {--center-lon= : Center longitude (default Warsaw)}
                           {--radius= : Radius in km for distribution}
                           {--count= : Number of restaurants to seed}';

    protected $description = 'Seed restaurants with natural clustered distribution around a center point';

    public function handle(): void
    {
        $lat = $this->option('center-lat') ? (float) $this->option('center-lat') : null;
        $lon = $this->option('center-lon') ? (float) $this->option('center-lon') : null;
        $radius = $this->option('radius') ? (float) $this->option('radius') : null;
        $count = $this->option('count') ? (int) $this->option('count') : config('seeding.restaurants');

        $displayLat = $lat ?? config('seeding.center_lat');
        $displayLon = $lon ?? config('seeding.center_lon');
        $displayRadius = $radius ?? config('seeding.radius');

        $this->info("Seeding {$count} restaurants around ({$displayLat}, {$displayLon}) with {$displayRadius}km radius...");

        $service = new DatabaseSeederService;
        $service->seedRestaurants($count, $lat, $lon, $radius);

        $this->info('Restaurant seeding completed successfully!');
    }
}
