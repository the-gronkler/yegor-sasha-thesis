<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use Inertia\Inertia;
use Inertia\Response;

class EmployeeController extends Controller
{
    /**
     * Display the employee dashboard.
     */
    public function index(): Response
    {
        if (! auth()->user()->isEmployee()) {
            abort(403, 'Unauthorized');
        }

        return Inertia::render('Employee/Index');
    }
}
