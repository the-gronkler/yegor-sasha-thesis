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
            $employeeCount = rand(3, 15);
            Employee::factory()
                ->count($employeeCount)
                ->forRestaurant($restaurant->id)
                ->create();
        }
    }
}
