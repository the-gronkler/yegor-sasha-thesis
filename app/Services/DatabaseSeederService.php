<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Employee;
use App\Models\Restaurant;
use App\Models\User;
use Database\Seeders\CustomerSeeder;
use Database\Seeders\EmployeeSeeder;
use Database\Seeders\OrderSeeder;
use Database\Seeders\RestaurantSeeder;
use Database\Seeders\ReviewSeeder;
use Database\Seeders\static_data\AllergenSeeder;
use Database\Seeders\static_data\OrderStatusSeeder;

class DatabaseSeederService
{
    public function seedStaticData(): void
    {
        (new AllergenSeeder)->run();
        (new OrderStatusSeeder)->run();
    }

    public function seedRestaurants(int $count, ?float $lat = null, ?float $lon = null, ?float $radius = null, ?callable $progressCallback = null): void
    {
        $lat ??= config('seeding.center_lat');
        $lon ??= config('seeding.center_lon');
        $radius ??= config('seeding.radius');

        (new RestaurantSeeder)->run($count, $lat, $lon, $radius, $progressCallback);
    }

    public function seedCustomers(int $count, ?callable $progressCallback = null): void
    {
        (new CustomerSeeder)->run($count, $progressCallback);
    }

    public function seedOrders(?int $ordersPerRestaurant = null, ?callable $progressCallback = null): void
    {
        $ordersPerRestaurant ??= config('seeding.orders_per_restaurant');

        (new OrderSeeder)->run($ordersPerRestaurant, $progressCallback);
    }

    public function seedReviews(?callable $progressCallback = null): void
    {
        (new ReviewSeeder)->run($progressCallback);
    }

    public function seedEmployees(?int $minPerRestaurant = null, ?int $maxPerRestaurant = null, ?callable $progressCallback = null): void
    {
        $minPerRestaurant ??= config('seeding.employees_min');
        $maxPerRestaurant ??= config('seeding.employees_max');

        (new EmployeeSeeder)->run($minPerRestaurant, $maxPerRestaurant, $progressCallback);
    }

    public function createAdminUser(): User
    {
        $adminUser = User::factory()->create([
            'name' => 'admin',
            'surname' => 'user',
            'email' => 'test@example.com',
            'password' => bcrypt('admin'),
        ]);

        // Create a customer record for the admin user
        Customer::factory()->create([
            'user_id' => $adminUser->id,
        ]);

        return $adminUser;
    }

    // Adds a default employee for testing purposes
    // is admin for the first restaurant
    public function createDefaultEmployee(): ?User
    {
        $restaurant = Restaurant::first();

        if (! $restaurant) {
            return null;
        }

        $employeeUser = User::factory()->create([
            'name' => 'Default',
            'surname' => 'Employee',
            'email' => 'employee@example.com',
            'password' => bcrypt('admin'),
        ]);

        Employee::factory()
            ->admin()
            ->forRestaurant($restaurant)
            ->create([
                'user_id' => $employeeUser->id,
            ]);

        // Create a non-admin worker for testing
        $workerUser = User::factory()->create([
            'name' => 'John',
            'surname' => 'Worker',
            'email' => 'worker@example.com',
            'password' => bcrypt('admin'),
        ]);

        Employee::factory()
            ->forRestaurant($restaurant)
            ->create([
                'user_id' => $workerUser->id,
                'is_admin' => false,
            ]);

        return $employeeUser;
    }
}
