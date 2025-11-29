<?php

namespace App\Http\Controllers\Restaurant\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function updateStatus(Request $request, Order $order)
    {
        $this->authorize('update', $order);
        // ... implementation
    }
}
