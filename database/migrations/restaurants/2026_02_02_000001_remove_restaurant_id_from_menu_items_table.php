<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Removes the denormalized restaurant_id column from menu_items.
     * The restaurant association is now derived through the food_type relationship,
     * achieving proper Third Normal Form (3NF).
     */
    public function up(): void
    {
        Schema::table('menu_items', function (Blueprint $table) {
            $table->dropForeign(['restaurant_id']);
            $table->dropColumn('restaurant_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        throw new \RuntimeException('Rollback is not supported for 2026_02_02_000001_remove_restaurant_id_from_menu_items_table: the restaurant_id column was permanently removed. Data normalization is irreversible.');
    }
};
