<?php

namespace Tests\Unit\Policies;

use App\Models\Employee;
use App\Models\FoodType;
use App\Models\MenuItem;
use App\Models\Restaurant;
use App\Models\User;
use App\Policies\MenuItemPolicy;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MenuItemPolicyTest extends TestCase
{
    use RefreshDatabase;

    public function test_update_status_allowed_for_restaurant_employee()
    {
        // 1. Create a restaurant
        $restaurant = Restaurant::factory()->create();

        // 2. Create a FoodType for this restaurant
        $foodType = FoodType::create([
            'name' => 'Burgers',
            'restaurant_id' => $restaurant->id,
        ]);

        // 3. Create a MenuItem linked to this food type
        $menuItem = MenuItem::create([
            'name' => 'Cheeseburger',
            'price' => 10,
            'food_type_id' => $foodType->id,
            'is_available' => true,
        ]);

        // 4. Create a User who is an Employee of the SAME restaurant
        $user = User::factory()->create();
        $employee = Employee::create([
            'user_id' => $user->id,
            'restaurant_id' => $restaurant->id,
            'is_admin' => false,
        ]);
        // Manually load the relation on the user instance as if it was eager loaded or accessed
        $user->setRelation('employee', $employee);

        // 5. Test the policy
        $policy = new MenuItemPolicy;

        $this->assertEquals($restaurant->id, $menuItem->restaurant_id, 'Accessor should return correct restaurant ID');

        $this->assertTrue($policy->updateStatus($user, $menuItem), 'Employee should be authorized to update status');
    }

    public function test_relation_loading()
    {
        // 1. Create a restaurant
        $restaurant = Restaurant::factory()->create();

        // 2. Create a FoodType for this restaurant
        $foodType = FoodType::create([
            'name' => 'Pizza',
            'restaurant_id' => $restaurant->id,
        ]);

        // 3. Create a MenuItem linked to this food type
        $menuItem = MenuItem::create([
            'name' => 'Pep',
            'price' => 10,
            'food_type_id' => $foodType->id,
            'is_available' => true,
        ]);

        // Clear the instance to fetch fresh
        $fetchedItem = MenuItem::find($menuItem->id);

        $this->assertTrue($fetchedItem->relationLoaded('foodType'), 'Global scope should eager load foodType');
        $this->assertNotNull($fetchedItem->foodType, 'FoodType should not be null');
        $this->assertEquals($restaurant->id, $fetchedItem->restaurant_id, 'Accessor should work on fetched item');
    }
}
