<?php

namespace Database\Seeders;

use App\Models\Customer;
use Illuminate\Database\Seeder;

class CustomerSeeder extends Seeder
{
    public function run(?int $count = null, ?callable $progressCallback = null): void
    {
        $count ??= config('seeding.customers');

        $created = 0;
        $batchSize = 10;

        while ($created < $count) {
            $remaining = $count - $created;
            $batchCount = min($batchSize, $remaining);

            Customer::factory()
                ->count($batchCount)
                ->create();

            $created += $batchCount;

            if ($progressCallback) {
                $progressCallback($created, $count);
            }
        }
    }
}
