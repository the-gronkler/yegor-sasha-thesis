<?php

namespace Database\Seeders\static_data;

use App\Enums\OrderStatus as OrderStatusEnum;
use App\Models\OrderStatus;
use Illuminate\Database\Seeder;

class OrderStatusSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        foreach (OrderStatusEnum::cases() as $status) {
            OrderStatus::updateOrCreate(
                ['id' => $status->value],
                ['name' => $status->label()]
            );
        }
    }
}
