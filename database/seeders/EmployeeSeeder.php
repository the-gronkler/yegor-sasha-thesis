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
        $restaurants = Restaurant::all();

        foreach ($restaurants as $restaurant) {
            Employee::factory()
                ->count(1)
                ->admin()
                ->forRestaurant($restaurant->id)
                ->create();

            $employeeCount = rand(2, 14);
            Employee::factory()
                ->count($employeeCount)
                ->forRestaurant($restaurant->id)
                ->create();
        }
    }
}
