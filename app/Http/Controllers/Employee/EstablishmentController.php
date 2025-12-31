<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use Inertia\Inertia;
use Inertia\Response;

class EstablishmentController extends Controller
{
    /**
     * Display the establishment management page (admins only).
     */
    public function index(): Response
    {
        return Inertia::render('Employee/Establishment/Index');
    }
}
