<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\User;
use Database\Seeders\CustomerSeeder;
use Database\Seeders\EmployeeSeeder;
use Database\Seeders\RestaurantSeeder;
use Database\Seeders\static_data\AllergenSeeder;
use Database\Seeders\static_data\OrderStatusSeeder;

class DatabaseSeederService
{
    public function seedStaticData(): void
    {
        (new AllergenSeeder)->run();
        (new OrderStatusSeeder)->run();
    }

    public function seedRestaurants(int $count, ?float $lat = null, ?float $lon = null, ?float $radius = null): void
    {
        $lat ??= config('seeding.center_lat');
        $lon ??= config('seeding.center_lon');
        $radius ??= config('seeding.radius');

        (new RestaurantSeeder)->run($count, $lat, $lon, $radius);
    }

    public function seedCustomers(int $count, ?int $reviewsPerCustomer = null, ?int $ordersPerCustomer = null): void
    {
        $reviewsPerCustomer ??= config('seeding.reviews_per_customer');
        $ordersPerCustomer ??= config('seeding.orders_per_customer');

        (new CustomerSeeder)->run($count, $reviewsPerCustomer, $ordersPerCustomer);
    }

    public function seedEmployees(?int $minPerRestaurant = null, ?int $maxPerRestaurant = null): void
    {
        $minPerRestaurant ??= config('seeding.employees_min');
        $maxPerRestaurant ??= config('seeding.employees_max');

        (new EmployeeSeeder)->run($minPerRestaurant, $maxPerRestaurant);
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
}
