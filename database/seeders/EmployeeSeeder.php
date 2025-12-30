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
    public function run(?int $minPerRestaurant = null, ?int $maxPerRestaurant = null): void
    {
        $minPerRestaurant ??= config('seeding.employees_min');
        $maxPerRestaurant ??= config('seeding.employees_max');

        Restaurant::all()->each(function ($restaurant) use ($minPerRestaurant, $maxPerRestaurant) {
            // One admin per restaurant
            Employee::factory()
                ->admin()
                ->forRestaurant($restaurant)
                ->create();

            // Regular employees
            Employee::factory()
                ->count(rand($minPerRestaurant, $maxPerRestaurant))
                ->forRestaurant($restaurant)
                ->create();
        });
    }
}
