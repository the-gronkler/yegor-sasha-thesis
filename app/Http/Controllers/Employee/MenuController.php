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
        $employee = Auth::user()->employee;

        if (! $employee || $employee->restaurant_id === null) {
            abort(404);
        }
        $restaurant = Restaurant::with(['foodTypes.menuItems' => function ($query) {
            $query->orderBy('name')->with('images');
        }])->findOrFail($employee->restaurant_id);

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
        $employee = Auth::user()->employee;

        // Ensure user is admin (middleware handles this, but good for safety)
        if (! $employee->is_admin) {
            abort(403);
        }

        $restaurant = Restaurant::with(['foodTypes.menuItems' => function ($query) {
            $query->orderBy('name')->with('images');
        }])->findOrFail($employee->restaurant_id);

        return Inertia::render('Employee/MenuEdit', [
            'restaurant' => $restaurant,
        ]);
    }
}
