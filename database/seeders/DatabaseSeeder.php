<?php

namespace Database\Seeders;

use App\Models\User;
// use Database\Seeders\static_data\AllergenSeeder;
use Database\Seeders\static_data\AllergenSeeder;
use Database\Seeders\static_data\OrderStatusSeeder;
use Illuminate\Database\Seeder;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // make site-wide admin for testing.
        User::factory()->create([
            'name' => 'admin',
            'email' => 'test@example.com',
            'password' => bcrypt('admin'),
        ]);

        $this->call([
            AllergenSeeder::class,
            OrderStatusSeeder::class,
            RestaurantSeeder::class,
            EmployeeSeeder::class,
            CustomerSeeder::class,
        ]);
    }
}
