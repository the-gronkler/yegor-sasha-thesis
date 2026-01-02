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

        $restaurant = Restaurant::with(['foodTypes.menuItems' => function ($query) {
            $query->orderBy('name');
        }])->findOrFail($employee->restaurant_id);

        return Inertia::render('Employee/Menu', [
            'restaurant' => $restaurant,
        ]);
    }
}
