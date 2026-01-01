<?php

namespace App\Console\Commands;

use App\Services\DatabaseSeederService;
use Illuminate\Console\Command;

class SeedStaticData extends Command
{
    protected $signature = 'seed:static-data';

    protected $description = 'Seed static data (allergens and order statuses)';

    public function handle(): void
    {
        $this->info('Seeding static data...');

        $service = new DatabaseSeederService;
        $service->seedStaticData();

        $this->info('Static data seeded successfully.');
    }
}
