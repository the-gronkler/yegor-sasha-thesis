<?php

namespace App\Http\Controllers\Customer;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Inertia\Inertia;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Order::class);

        $customer = $request->user()->customer;

        $orders = Order::with(['menuItems', 'status', 'restaurant'])
            ->where('customer_user_id', $customer->user_id)
            ->where('order_status_id', '!=', OrderStatus::InCart)
            ->latest()
            ->paginate(10);

        return Inertia::render('Customer/Orders/Index', [
            'orders' => $orders,
        ]);
    }

    public function old(Request $request)
    {
        $this->authorize('viewAny', Order::class);

        $customer = $request->user()->customer;

        $oldOrders = Order::with(['menuItems', 'status', 'restaurant'])
            ->where('customer_user_id', $customer->user_id)
            ->where('order_status_id', '!=', OrderStatus::InCart)
            ->get();

        return Inertia::render('Customer/Orders/Old', [
            'orders' => $oldOrders,
        ]);
    }

    public function show(Request $request, Order $order)
    {
        $this->authorize('view', $order);

        $order->load(['restaurant', 'menuItems.images', 'status']);

        return Inertia::render('Customer/Orders/Show', [
            'order' => $order,
        ]);
    }

    public function destroyCart(Request $request, Order $order)
    {
        $this->authorize('delete', $order);

        if ($order->order_status_id !== OrderStatus::InCart) {
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
