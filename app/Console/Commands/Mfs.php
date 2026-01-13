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

        $this->newLine();
        $this->runMigrations();

        $service = new DatabaseSeederService;

        $this->info('🌱 Seeding database...');
        $this->newLine();

        $this->runSimpleTask('📋 Seeding static data (Allergens, Order Statuses)',
            fn () => $service->seedStaticData()
        );

        $this->runWithProgressBar(
            "🏪 Seeding {$restaurants} restaurants (radius: {$radius}km)",
            $restaurants,
            'Restaurant',
            fn ($callback) => $service->seedRestaurants($restaurants, null, null, $radius, $callback)
        );

        $this->runSimpleTask('👤 Creating admin user',
            fn () => $service->createAdminUser()
        );

        $this->runWithProgressBar(
            "👥 Seeding {$customers} customers (with reviews & orders)",
            $customers,
            'Customer',
            fn ($callback) => $service->seedCustomers($customers, $reviewsPerCustomer, $ordersPerCustomer, $callback)
        );

        $restaurantCount = \App\Models\Restaurant::count();
        $this->runWithProgressBar(
            "👔 Seeding employees ({$employeesMin}-{$employeesMax} per restaurant)",
            $restaurantCount,
            'Restaurant',
            fn ($callback) => $service->seedEmployees($employeesMin, $employeesMax, $callback)
        );

        $this->runSimpleTask('👤 Creating default employee',
            fn () => $service->createDefaultEmployee()
        );

        $this->displaySummary($restaurants, $customers, $employeesMin, $employeesMax, $reviewsPerCustomer, $ordersPerCustomer);
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
     * Run a simple task with start/complete messages.
     */
    private function runSimpleTask(string $message, callable $task): void
    {
        $this->line($message);
        $task();
        $this->info('   ✓ Completed');
        $this->newLine();
    }

    /**
     * Run a task with a progress bar.
     */
    private function runWithProgressBar(string $label, int $total, string $itemType, callable $task): void
    {
        $this->line($label);

        $bar = $this->output->createProgressBar($total);
        $bar->setFormat(' %current%/%max% [%bar%] %percent:3s%% %message%');
        $bar->setMessage('Starting...');
        $bar->start();

        $task(function ($current, $total) use ($bar, $itemType) {
            $bar->setMessage("{$itemType} {$current}/{$total}");
            $bar->advance();
        });

        $bar->setMessage('Complete');
        $bar->finish();
        $this->newLine();
    }

    /**
     * Display seeding summary table.
     */
    private function displaySummary(int $restaurants, int $customers, int $employeesMin, int $employeesMax, int $reviewsPerCustomer, int $ordersPerCustomer): void
    {
        $this->info('✓ Database seeding completed successfully!');
        $this->newLine();

        $this->table(
            ['Entity', 'Count'],
            [
                ['Restaurants', $restaurants],
                ['Customers', $customers],
                ['Employees', "{$employeesMin}-{$employeesMax} per restaurant"],
                ['Reviews per customer', $reviewsPerCustomer],
                ['Orders per customer', $ordersPerCustomer],
            ]
        );
    }
}
