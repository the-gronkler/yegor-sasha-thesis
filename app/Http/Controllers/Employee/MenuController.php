<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use Inertia\Inertia;
use Inertia\Response;

class MenuController extends Controller
{
    /**
     * Display the employee menu management page.
     */
    public function index(): Response
    {
        return Inertia::render('Employee/Menu/Index');
    }
}
