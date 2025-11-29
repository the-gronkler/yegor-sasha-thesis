<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Inertia\Inertia;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $customer = $request->user()->customer;

        $orders = Order::with(['menuItems', 'orderStatus', 'restaurant'])
            ->where('customer_user_id', $customer->user_id)
            ->where('order_status_id', '!=', Order::STATUS_IN_CART) // Not sure how to implement this stuff...
            ->latest()
            ->paginate(10);

        return Inertia::render('Customer/Orders/Index', [
            'orders' => $orders,
        ]);
    }

    public function old(Request $request)
    {
        $customer = $request->user()->customer;

        $oldOrders = Order::with(['menuItems', 'orderStatus', 'restaurant'])
            ->where('customer_user_id', $customer->user_id)
            ->where('order_status_id', '!=', Order::STATUS_IN_CART) // Not sure how to implement this stuff...
            ->get();

        return Inertia::render('Customer/Orders/Old', [
            'orders' => $oldOrders,
        ]);
    }

    public function destroyCart(Request $request, Order $order)
    {
        $this->authorize('delete', $order);

        if ($order->order_status_id !== Order::STATUS_IN_CART) { // Not sure how to implement this stuff...
            abort(403, 'Can only delete cart orders');
        }

        $order->delete();

        return redirect()->route('orders.index')->with('success', 'Cart cleared');
    }

    public function unfinished()
    {
        // Not implemented yet)
    }
}
