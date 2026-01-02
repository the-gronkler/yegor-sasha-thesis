<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use App\Models\MenuItem;
use Illuminate\Http\Request;

class EmployeeMenuItemController extends Controller
{
    public function updateStatus(Request $request, MenuItem $item)
    {
        $this->authorize('update', $item);

        $validated = $request->validate([
            'is_available' => ['required', 'boolean'],
        ]);

        $item->update($validated);

        return back();
    }
}
