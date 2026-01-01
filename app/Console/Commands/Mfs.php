<?php

namespace App\Console\Commands;

use App\Services\DatabaseSeederService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Validator;

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

        // Validate numeric options
        $validator = Validator::make([
            'restaurants' => $restaurants,
            'customers' => $customers,
            'employees_min' => $employeesMin,
            'employees_max' => $employeesMax,
            'reviews_per_customer' => $reviewsPerCustomer,
            'orders_per_customer' => $ordersPerCustomer,
            'radius' => $radius,
        ], [
            'restaurants' => 'required|integer|min:1',
            'customers' => 'required|integer|min:1',
            'employees_min' => 'required|integer|min:1',
            'employees_max' => 'required|integer|min:1|gte:employees_min',
            'reviews_per_customer' => 'required|integer|min:1',
            'orders_per_customer' => 'required|integer|min:1',
            'radius' => 'required|numeric|gt:0',
        ]);

        if ($validator->fails()) {
            foreach ($validator->errors()->all() as $error) {
                $this->error($error);
            }

            return;
        }

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
        $service->createDefaultEmployee();

        $this->info("Seeded {$restaurants} restaurants and {$customers} customers.");
    }
}
