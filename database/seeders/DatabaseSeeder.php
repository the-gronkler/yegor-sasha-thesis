<?php

namespace Database\Seeders;

use App\Models\User;
use Database\Seeders\big_scary_pivots\FavoriteRestaurantSeeder;
use Database\Seeders\big_scary_pivots\OrderSeeder;
use Database\Seeders\big_scary_pivots\ReviewSeeder;
//use Database\Seeders\static_data\AllergenSeeder;
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

        // make site-wide admin for testing.
        User::factory()->create([
            'name' => 'admin',
            'email' => 'test@example.com',
            'password' => bcrypt('admin'),
        ]);

        /*


         */


        $this->call([
            AllergenSeeder::class, // seeds allergens
            OrderStatusSeeder::class, // seeds order statuses

            RestaurantSeeder::class, // seeds tables restaurants, foodTypes, menu items, images
            EmployeeSeeder::class, // seeds employees, automatically creating underlying user.
            // attached random num of new ems to each restaurant

            CustomerSeeder::class, // just creates customers

            // id like to add some checks for the pivot seeders, so that the generated data makes sense,
            // but i also dont really care that much so...
            OrderSeeder::class,
            ReviewSeeder::class,
            FavoriteRestaurantSeeder::class
        ]);
    }
}
