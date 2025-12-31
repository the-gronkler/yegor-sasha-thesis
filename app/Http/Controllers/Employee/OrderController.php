<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use Inertia\Inertia;
use Inertia\Response;

class OrderController extends Controller
{
    /**
     * Display the employee orders page.
     */
    public function index(): Response
    {
        return Inertia::render('Employee/Orders/Index');
    }
}
