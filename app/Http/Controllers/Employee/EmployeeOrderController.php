<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class EmployeeOrderController extends Controller
{
    /**
     * Display the employee orders page.
     */
    public function index(): Response
    {
        return Inertia::render('Employee/Orders/Index');
    }

    public function updateStatus(Request $request, Order $order)
    {
        $this->authorize('update', $order);
        // ... implementation
    }
}
