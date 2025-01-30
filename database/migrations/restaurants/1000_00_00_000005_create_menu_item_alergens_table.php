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
        Schema::create('menu_item_alergen', function (Blueprint $table) {
            $table->unsignedBigInteger('menu_item_id');
            $table->unsignedBigInteger('alergen_id');
            $table->primary(['menu_item_id','alergen_id']);
            $table->foreign('menu_item_id')->references('id')->on('menu_items')->onDelete('cascade');
            $table->foreign('alergen_id')->references('id')->on('alergens')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('menu_item_alergen');
    }
};
