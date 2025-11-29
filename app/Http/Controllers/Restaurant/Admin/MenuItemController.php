<?php

namespace App\Http\Controllers\Restaurant\Admin;

use App\Http\Controllers\Controller;
use App\Models\MenuItem;
use Illuminate\Http\Request;

class MenuItemController extends Controller
{
    public function updateStatus(Request $request, MenuItem $item)
    {
        $this->authorize('update', $item);
        // ... implementation
    }
}
