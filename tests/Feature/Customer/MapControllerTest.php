<?php

/**
 * MapController Feature Tests
 *
 * NOTE: These tests require proper test database configuration to run.
 * Current project setup issue: RefreshDatabase and DatabaseMigrations traits are not
 * running migrations in the test environment. This is a known Laravel/Pest configuration
 * issue that needs to be resolved separately.
 *
 * Once test database is properly configured (via TestCase or .env.testing), these tests
 * will verify:
 * - Authentication requirements
 * - Authorization (viewAny policy)
 * - Data filtering (whereNotNull for coordinates)
 * - Data transformation (proper JSON structure)
 * - Coordinate type casting
 * - Correct Inertia component rendering
 */

use App\Models\Customer;
use App\Models\FoodType;
use App\Models\Image;
use App\Models\MenuItem;
use App\Models\Restaurant;
use App\Models\User;
use Inertia\Testing\AssertableInertia as Assert;

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->customer = Customer::factory()->create(['user_id' => $this->user->id]);
});

test('map index requires authentication', function () {
    $response = $this->get(route('map.index'));

    $response->assertRedirect(route('login'));
});

test('map index displays only restaurants with coordinates', function () {
    $restaurantWithCoords = Restaurant::factory()->create([
        'latitude' => 51.5074,
        'longitude' => -0.1278,
        'rating' => 4.5,
    ]);

    $restaurantWithoutCoords = Restaurant::factory()->create([
        'latitude' => null,
        'longitude' => null,
        'rating' => 4.0,
    ]);

    $response = $this->actingAs($this->user)->get(route('map.index'));

    $response->assertInertia(fn (Assert $page) => $page
        ->component('Customer/Map/Index')
        ->has('restaurants', 1)
        ->where('restaurants.0.id', $restaurantWithCoords->id)
    );
});

test('map index transforms restaurant data correctly', function () {
    $restaurant = Restaurant::factory()->create([
        'latitude' => 51.5074,
        'longitude' => -0.1278,
        'rating' => 4.5,
        'description' => 'Test restaurant description',
        'opening_hours' => '09:00 - 22:00',
    ]);

    $image = Image::factory()->create([
        'restaurant_id' => $restaurant->id,
        'is_primary_for_restaurant' => true,
    ]);

    $foodType = FoodType::factory()->create();
    $restaurant->foodTypes()->attach($foodType->id);

    $menuItem = MenuItem::factory()->create([
        'food_type_id' => $foodType->id,
    ]);

    $response = $this->actingAs($this->user)->get(route('map.index'));

    $response->assertInertia(fn (Assert $page) => $page
        ->component('Customer/Map/Index')
        ->has('restaurants.0', fn (Assert $rest) => $rest
            ->where('id', $restaurant->id)
            ->where('name', $restaurant->name)
            ->where('address', $restaurant->address)
            ->whereType('latitude', 'double')
            ->whereType('longitude', 'double')
            ->where('rating', $restaurant->rating)
            ->where('description', $restaurant->description)
            ->where('opening_hours', $restaurant->opening_hours)
            ->has('images', 1)
            ->has('images.0', fn (Assert $img) => $img
                ->where('id', $image->id)
                ->where('url', $image->image)
                ->where('is_primary_for_restaurant', true)
            )
            ->has('food_types', 1)
            ->has('food_types.0', fn (Assert $ft) => $ft
                ->where('id', $foodType->id)
                ->where('name', $foodType->name)
                ->has('menu_items', 1)
                ->has('menu_items.0', fn (Assert $mi) => $mi
                    ->where('id', $menuItem->id)
                    ->where('name', $menuItem->name)
                )
            )
        )
    );
});

test('map index orders restaurants by rating descending', function () {
    $restaurant1 = Restaurant::factory()->create([
        'latitude' => 51.5074,
        'longitude' => -0.1278,
        'rating' => 3.5,
    ]);

    $restaurant2 = Restaurant::factory()->create([
        'latitude' => 51.5074,
        'longitude' => -0.1278,
        'rating' => 4.8,
    ]);

    $restaurant3 = Restaurant::factory()->create([
        'latitude' => 51.5074,
        'longitude' => -0.1278,
        'rating' => 4.2,
    ]);

    $response = $this->actingAs($this->user)->get(route('map.index'));

    $response->assertInertia(fn (Assert $page) => $page
        ->component('Customer/Map/Index')
        ->has('restaurants', 3)
        ->where('restaurants.0.id', $restaurant2->id)
        ->where('restaurants.1.id', $restaurant3->id)
        ->where('restaurants.2.id', $restaurant1->id)
    );
});

test('map index returns correct inertia component', function () {
    $response = $this->actingAs($this->user)->get(route('map.index'));

    $response->assertInertia(fn (Assert $page) => $page
        ->component('Customer/Map/Index')
        ->has('restaurants')
    );
});

test('map index includes all necessary restaurant fields', function () {
    $restaurant = Restaurant::factory()->create([
        'latitude' => 51.5074,
        'longitude' => -0.1278,
    ]);

    $response = $this->actingAs($this->user)->get(route('map.index'));

    $response->assertInertia(fn (Assert $page) => $page
        ->component('Customer/Map/Index')
        ->has('restaurants.0', fn (Assert $rest) => $rest
            ->has('id')
            ->has('name')
            ->has('address')
            ->has('latitude')
            ->has('longitude')
            ->has('rating')
            ->has('description')
            ->has('opening_hours')
            ->has('images')
            ->has('food_types')
        )
    );
});

test('map index casts coordinates to floats', function () {
    $restaurant = Restaurant::factory()->create([
        'latitude' => '51.5074',
        'longitude' => '-0.1278',
    ]);

    $response = $this->actingAs($this->user)->get(route('map.index'));

    $response->assertInertia(fn (Assert $page) => $page
        ->component('Customer/Map/Index')
        ->has('restaurants', 1)
        ->where('restaurants.0.latitude', 51.5074)
        ->where('restaurants.0.longitude', -0.1278)
        ->whereType('restaurants.0.latitude', 'double')
        ->whereType('restaurants.0.longitude', 'double')
    );
});
