<?php

use App\Models\Customer;
use App\Models\Image;
use App\Models\Restaurant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('restaurant map card endpoint returns correct data structure', function () {
    $restaurant = Restaurant::factory()->create([
        'name' => 'Test Restaurant',
        'address' => '123 Test St',
        'latitude' => 52.2297,
        'longitude' => 21.0122,
        'rating' => 4.5,
        'opening_hours' => '9:00 AM - 10:00 PM',
    ]);

    $image = Image::factory()->create([
        'restaurant_id' => $restaurant->id,
        'is_primary_for_restaurant' => true,
        'image' => 'https://example.com/image.jpg',
    ]);

    $response = $this->getJson("/api/restaurants/{$restaurant->id}/map-card");

    $response->assertOk()
        ->assertJsonStructure([
            'id',
            'name',
            'address',
            'latitude',
            'longitude',
            'rating',
            'opening_hours',
            'distance',
            'is_favorited',
            'primary_image_url',
        ])
        ->assertJson([
            'id' => $restaurant->id,
            'name' => 'Test Restaurant',
            'address' => '123 Test St',
            'latitude' => 52.2297,
            'longitude' => 21.0122,
            'rating' => 4.5,
            'opening_hours' => '9:00 AM - 10:00 PM',
            'is_favorited' => false,
            'primary_image_url' => 'https://example.com/image.jpg',
        ]);
});

test('restaurant map card includes favorite status for authenticated customer', function () {
    $user = User::factory()->create();
    $customer = Customer::factory()->create(['user_id' => $user->id]);

    $restaurant = Restaurant::factory()->create();

    // Favorite the restaurant
    $restaurant->favoritedBy()->attach($customer->user_id);

    $response = $this->actingAs($user)
        ->getJson("/api/restaurants/{$restaurant->id}/map-card");

    $response->assertOk()
        ->assertJson([
            'is_favorited' => true,
        ]);
});

test('restaurant map card caches results', function () {
    $restaurant = Restaurant::factory()->create();

    // First request
    $response1 = $this->getJson("/api/restaurants/{$restaurant->id}/map-card");
    $response1->assertOk();

    // Update restaurant (cache should still return old data)
    $restaurant->update(['name' => 'Updated Name']);

    // Second request (should hit cache)
    $response2 = $this->getJson("/api/restaurants/{$restaurant->id}/map-card");
    $response2->assertOk()
        ->assertJsonMissing(['name' => 'Updated Name']); // Cache hasn't updated yet
});

test('restaurant map card returns null for missing primary image', function () {
    $restaurant = Restaurant::factory()->create();

    $response = $this->getJson("/api/restaurants/{$restaurant->id}/map-card");

    $response->assertOk()
        ->assertJson([
            'primary_image_url' => null,
        ]);
});
