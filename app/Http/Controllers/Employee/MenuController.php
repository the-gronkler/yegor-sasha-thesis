<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use App\Models\Restaurant;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response;

class MenuController extends Controller
{
    /**
     * Display the employee menu management page.
     */
    public function index(): Response
    {
        $restaurant = $this->getEmployeeRestaurant(['images', 'allergens']);
        $employee = Auth::user()->employee;

        return Inertia::render('Employee/Menu', [
            'restaurant' => $restaurant,
            'isRestaurantAdmin' => $employee->is_admin,
        ]);
    }

    /**
     * Display the menu edit page (for admins).
     */
    public function edit(): Response
    {
        $restaurant = $this->getEmployeeRestaurant(['images', 'allergens']);

        return Inertia::render('Employee/MenuEdit', [
            'restaurant' => $restaurant,
        ]);
    }

    /**
     * Get the restaurant for the current employee with specified menu item relations.
     */
    private function getEmployeeRestaurant(array $menuItemRelations = ['images', 'allergens']): Restaurant
    {
        $employee = Auth::user()->employee;

        if (! $employee || $employee->restaurant_id === null) {
            abort(403, 'You must be assigned to a restaurant to access this page');
        }

        return Restaurant::with(['foodTypes.menuItems' => function ($query) use ($menuItemRelations) {
            $query->orderBy('name')->with($menuItemRelations);
        }])->findOrFail($employee->restaurant_id);
    }
}
