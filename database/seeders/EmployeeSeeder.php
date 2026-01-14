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
    public function run(?int $minPerRestaurant = null, ?int $maxPerRestaurant = null, ?callable $progressCallback = null): void
    {
        $minPerRestaurant ??= config('seeding.employees_min');
        $maxPerRestaurant ??= config('seeding.employees_max');

        // Ensure min <= max to prevent rand() failure
        $min = min($minPerRestaurant, $maxPerRestaurant);
        $max = max($minPerRestaurant, $maxPerRestaurant);

        // Use lazy() to avoid loading all restaurants into memory at once
        // This is critical for large datasets (e.g., 10k+ restaurants)
        $total = Restaurant::count();
        $current = 0;

        Restaurant::lazy()->each(function ($restaurant) use ($min, $max, &$current, $total, $progressCallback) {
            // One admin per restaurant
            Employee::factory()
                ->admin()
                ->forRestaurant($restaurant)
                ->create();

            // Regular employees
            Employee::factory()
                ->count(rand($min, $max))
                ->forRestaurant($restaurant)
                ->create();

            $current++;

            if ($progressCallback) {
                $progressCallback($current, $total);
            }
        });
    }
}
