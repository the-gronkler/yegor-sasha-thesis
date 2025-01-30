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
        Schema::create('favorite_restaurants', function (Blueprint $table) {
            $table->unsignedBigInteger('customer_user_id');
            $table->unsignedBigInteger('restaurant_id');
            $table->integer('rank');
            $table->primary(['customer_user_id','restaurant_id']);
            $table->foreign('customer_user_id')->references('user_id')->on('customers')->onDelete('cascade');
            $table->foreign('restaurant_id')->references('id')->on('restaurants')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('favorite_restaurants');
    }
};
