<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('review_images', function (Blueprint $table) {
            $table->id();
            $table->binary('image')->nullable();
            $table->unsignedBigInteger('review_id');
            $table->foreign('review_id')->references('id')->on('reviews')->onDelete('cascade');
            $table->timestamps();
        });

        DB::statement("ALTER TABLE review_images MODIFY COLUMN image MEDIUMBLOB");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('review_images');
    }
};
