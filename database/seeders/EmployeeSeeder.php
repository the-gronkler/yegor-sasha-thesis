<?php

namespace Database\Seeders;

use App\Models\Employee;
use App\Models\Restaurant;
use Illuminate\Database\Seeder;

class EmployeeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Restaurant::all()->each(function ($restaurant) {
            // One admin per restaurant
            Employee::factory()
                ->admin()
                ->for($restaurant, 'restaurant')
                ->create();

            // Regular employees
            Employee::factory()
                ->count(rand(2, 14))
                ->for($restaurant, 'restaurant')
                ->create();
        });
    }
}
