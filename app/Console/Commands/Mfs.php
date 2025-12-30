<?php

namespace App\Console\Commands;

use App\Services\DatabaseSeederService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;

class Mfs extends Command
{
    protected $signature = 'mfs
                           {--force : Force the operation to run when in production}
                           {--restaurants= : Number of restaurants to seed}
                           {--customers= : Number of customers to seed}
                           {--employees-min= : Minimum employees per restaurant}
                           {--employees-max= : Maximum employees per restaurant}
                           {--reviews-per-customer= : Number of reviews per customer}
                           {--orders-per-customer= : Number of orders per customer}
                           {--radius= : Radius in km for restaurant distribution}';

    protected $description = 'Runs migrate:fresh with seed, including migrations from all subdirectories';

    public function handle(): void
    {
        // Extract options early
        $restaurants = $this->option('restaurants') ? (int) $this->option('restaurants') : config('seeding.restaurants');
        $customers = $this->option('customers') ? (int) $this->option('customers') : config('seeding.customers');
        $employeesMin = $this->option('employees-min') ? (int) $this->option('employees-min') : config('seeding.employees_min');
        $employeesMax = $this->option('employees-max') ? (int) $this->option('employees-max') : config('seeding.employees_max');
        $reviewsPerCustomer = $this->option('reviews-per-customer') ? (int) $this->option('reviews-per-customer') : config('seeding.reviews_per_customer');
        $ordersPerCustomer = $this->option('orders-per-customer') ? (int) $this->option('orders-per-customer') : config('seeding.orders_per_customer');
        $radius = $this->option('radius') ? (float) $this->option('radius') : config('seeding.radius');

        $this->info('Running migrate:fresh...');

        Artisan::call('migrate:fresh', [
            '--path' => 'database/migrations/*',
            '--force' => $this->option('force'),
            '--no-interaction' => true,
        ]);

        $this->info('Seeding database...');

        $service = new DatabaseSeederService;

        // Seed static data
        $service->seedStaticData();

        // Seed dynamic data with params
        $service->seedRestaurants($restaurants, null, null, $radius);
        $service->createAdminUser();
        $service->seedCustomers($customers, $reviewsPerCustomer, $ordersPerCustomer);
        $service->seedEmployees($employeesMin, $employeesMax);

        $this->info("Seeded {$restaurants} restaurants and {$customers} customers.");
    }
}
