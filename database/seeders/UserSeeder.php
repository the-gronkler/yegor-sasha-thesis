<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Models\Customer;
use App\Models\Employee;
use App\Models\Restaurant;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create Users (some will be customers, some will be employees)
        $users = [
            [
                'name' => 'John Doe',
                'email' => 'customer@example.com',
                'password' => Hash::make('password'),
                'is_admin' => false
            ],
            [
                'name' => 'Alice Smith',
                'email' => 'employee@example.com',
                'password' => Hash::make('password'),
                'is_admin' => false
            ],
            [
                'name' => 'Admin User',
                'email' => 'admin@example.com',
                'password' => Hash::make('password'),
                'is_admin' => true
            ]
        ];

        foreach ($users as $userData) {
            $user = User::create($userData);

            // Assign Some Users as Customers
            if ($user->email === 'customer@example.com') {
                Customer::create([
                    'user_id' => $user->id,
                    'payment_method_token' => 'tok_visa_12345'
                ]);
            }

            // Assign Some Users as Employees (linking to a random restaurant)
            if ($user->email === 'employee@example.com') {
                $restaurant = Restaurant::inRandomOrder()->first(); // Get a random restaurant

                Employee::create([
                    'user_id' => $user->id,
                    'restaurant_id' => $restaurant->id ?? 1, // Default to 1 if no restaurants exist
                    'is_admin' => false
                ]);
            }

            // Ensure Admin Users are not assigned to Customer/Employee hz nado li eto? =P
        }
    }
}
