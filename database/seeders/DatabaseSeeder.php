<?php

namespace Database\Seeders;

use App\Models\User;
use Database\Seeders\big_scary_pivots\FavoriteRestaurantSeeder;
use Database\Seeders\big_scary_pivots\OrderSeeder;
use Database\Seeders\big_scary_pivots\ReviewSeeder;
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
        // User::factory(10)->create();

        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);

        // order important !!!!!!!!!
        $this->call([
            AllergenSeeder::class,
            OrderStatusSeeder::class,
            UserSeeder::class,

            CustomerSeeder::class,
            RestaurantSeeder::class,

            OrderSeeder::class,
            ReviewSeeder::class,
            FavoriteRestaurantSeeder::class
        ]);
    }
}
