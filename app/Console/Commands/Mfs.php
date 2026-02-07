<?php

namespace App\Console\Commands;

use App\Console\Helpers\ConsoleOutputHelper;
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
                           {--orders-per-customer= : Number of orders per customer}
                           {--radius= : Radius in km for restaurant distribution}';

    protected $description = 'Runs migrate:fresh with seed, including migrations from all subdirectories';

    private ?ConsoleOutputHelper $outputHelper = null;

    public function __construct()
    {
        parent::__construct();
    }

    public function handle(): void
    {
        $this->outputHelper = new ConsoleOutputHelper($this->output);

        $params = $this->validateOptions();

        $this->runMigrations();
        $this->seedData($params);
        $this->displaySummary($params);
    }

    /**
     * Validate and extract command options.
     */
    private function validateOptions(): array
    {
        $restaurants = $this->option('restaurants') ? (int) $this->option('restaurants') : config('seeding.restaurants');
        $customers = $this->option('customers') ? (int) $this->option('customers') : config('seeding.customers');
        $employeesMin = $this->option('employees-min') ? (int) $this->option('employees-min') : config('seeding.employees_min');
        $employeesMax = $this->option('employees-max') ? (int) $this->option('employees-max') : config('seeding.employees_max');
        $ordersPerCustomer = $this->option('orders-per-customer') ? (int) $this->option('orders-per-customer') : config('seeding.orders_per_customer');
        $radius = $this->option('radius') ? (float) $this->option('radius') : config('seeding.radius');

        $validator = Validator::make([
            'restaurants' => $restaurants,
            'customers' => $customers,
            'employees_min' => $employeesMin,
            'employees_max' => $employeesMax,
            'orders_per_customer' => $ordersPerCustomer,
            'radius' => $radius,
        ], [
            'restaurants' => 'required|integer|min:1',
            'customers' => 'required|integer|min:1',
            'employees_min' => 'required|integer|min:1',
            'employees_max' => 'required|integer|min:1|gte:employees_min',
            'orders_per_customer' => 'required|integer|min:1',
            'radius' => 'required|numeric|gt:0',
        ]);

        if ($validator->fails()) {
            foreach ($validator->errors()->all() as $error) {
                $this->error($error);
            }
            throw new \Exception('Validation failed');
        }

        return [
            'restaurants' => $restaurants,
            'customers' => $customers,
            'employees_min' => $employeesMin,
            'employees_max' => $employeesMax,
            'orders_per_customer' => $ordersPerCustomer,
            'radius' => $radius,
        ];
    }

    /**
     * Run database migrations.
     */
    private function runMigrations(): void
    {
        $this->info('🔄 Running migrate:fresh...');
        $this->line('   Dropping all tables and recreating database schema');

        Artisan::call('migrate:fresh', [
            '--path' => 'database/migrations/*',
            '--force' => $this->option('force'),
            '--no-interaction' => true,
        ]);

        $this->info('✓ Migrations completed');
        $this->newLine();
    }

    /**
     * Perform the database seeding.
     */
    private function seedData(array $params): void
    {
        $service = new DatabaseSeederService;

        $this->info('🌱 Seeding database...');
        $this->newLine();

        $this->seedStaticData($service);
        $this->seedRestaurants($service, $params);
        $this->createAdminUser($service);
        $this->seedCustomers($service, $params);
        $this->seedEmployees($service, $params);
        $this->seedReviews($service, $params);
        $this->createDefaultEmployee($service);
    }

    private function seedStaticData(DatabaseSeederService $service): void
    {
        $this->outputHelper->runSimpleTask('📋 Seeding static data (Allergens, Order Statuses)',
            fn () => $service->seedStaticData()
        );
    }

    private function seedRestaurants(DatabaseSeederService $service, array $params): void
    {
        $this->outputHelper->runWithProgressBar(
            "🏪 Seeding {$params['restaurants']} restaurants (radius: {$params['radius']}km)",
            $params['restaurants'],
            'Restaurant',
            fn ($callback) => $service->seedRestaurants($params['restaurants'], null, null, $params['radius'], $callback)
        );
    }

    private function createAdminUser(DatabaseSeederService $service): void
    {
        $this->outputHelper->runSimpleTask('👤 Creating admin user',
            fn () => $service->createAdminUser()
        );
    }

    private function seedCustomers(DatabaseSeederService $service, array $params): void
    {
        $this->outputHelper->runWithProgressBar(
            "👥 Seeding {$params['customers']} customers (with orders)",
            $params['customers'],
            'Customer',
            fn ($callback) => $service->seedCustomers($params['customers'], $params['orders_per_customer'], $callback)
        );
    }

    private function seedEmployees(DatabaseSeederService $service, array $params): void
    {
        $restaurantCount = \App\Models\Restaurant::count();
        $this->outputHelper->runWithProgressBar(
            "👔 Seeding employees ({$params['employees_min']}-{$params['employees_max']} per restaurant)",
            $restaurantCount,
            'Restaurant',
            fn ($callback) => $service->seedEmployees($params['employees_min'], $params['employees_max'], $callback)
        );
    }

    private function seedReviews(DatabaseSeederService $service, array $params): void
    {
        $restaurantCount = \App\Models\Restaurant::count();
        $this->outputHelper->runWithProgressBar(
            '⭐ Seeding reviews (2-14 per restaurant)',
            $restaurantCount,
            'Restaurant',
            fn ($callback) => $service->seedReviews($callback)
        );
    }

    private function createDefaultEmployee(DatabaseSeederService $service): void
    {
        $this->outputHelper->runSimpleTask('👤 Creating default employee',
            fn () => $service->createDefaultEmployee()
        );
    }

    /**
     * Display seeding summary table.
     */
    private function displaySummary(array $params): void
    {
        $this->info('✓ Database seeding completed successfully!');
        $this->newLine();

        $this->table(
            ['Entity', 'Count'],
            [
                ['Restaurants', $params['restaurants']],
                ['Customers', $params['customers']],
                ['Employees', "{$params['employees_min']}-{$params['employees_max']} per restaurant"],
                ['Reviews', '2-14 per restaurant'],
                ['Orders per customer', $params['orders_per_customer']],
            ]
        );
    }
}
