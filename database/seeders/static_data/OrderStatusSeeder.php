<?php

namespace Database\Seeders\static_data;

use App\Models\OrderStatus;
use Illuminate\Database\Seeder;

class OrderStatusSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $statuses = [
            'in Cart',
            'Placed',
            'Accepted',
            'Declined',
            'Preparing',
            'Ready',
            'Cancelled',
            'Fulfilled',
        ];

        foreach ($statuses as $status) {
            OrderStatus::create([
                'name' => $status,
            ]);
        }
    }
}
