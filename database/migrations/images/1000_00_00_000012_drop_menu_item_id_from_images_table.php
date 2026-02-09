<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('images', function (Blueprint $table) {
            $table->dropForeign(['menu_item_id']);
            $table->dropColumn(['menu_item_id', 'is_primary_for_menu_item']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('images', function (Blueprint $table) {
            $table->unsignedBigInteger('menu_item_id')->nullable()->after('restaurant_id');
            $table->boolean('is_primary_for_menu_item')->nullable()->after('is_primary_for_restaurant');
            $table->foreign('menu_item_id')->references('id')->on('menu_items')->onDelete('set null');
        });
    }
};
