<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Employee;
use App\Models\Restaurant;
use App\Models\User;
use Database\Seeders\static_data\AllergenSeeder;
use Database\Seeders\static_data\OrderStatusSeeder;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // make site-wide admin for testing.
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

        $this->call([
            AllergenSeeder::class,
            OrderStatusSeeder::class,
            RestaurantSeeder::class,
            EmployeeSeeder::class,
            CustomerSeeder::class,
        ]);

        // Create a default employee for testing
        $restaurant = Restaurant::first();

        if ($restaurant) {
            $employeeUser = User::factory()->create([
                'name' => 'Default',
                'surname' => 'Employee',
                'email' => 'employee@example.com',
                'password' => bcrypt('employee'),
            ]);

            Employee::factory()
                ->admin()
                ->forRestaurant($restaurant)
                ->create([
                    'user_id' => $employeeUser->id,
                ]);
        }
    }
}
