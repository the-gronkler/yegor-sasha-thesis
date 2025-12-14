<?php

namespace App\Http\Controllers\Customer;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Inertia\Inertia;

class CheckoutController extends Controller
{
    public function show(Request $request, Order $order)
    {
        $this->authorize('view', $order);

        if ($order->order_status_id !== OrderStatus::InCart) {
            return redirect()->route('customer.orders.show', $order)
                ->with('info', 'This order has already been checked out.');
        }

        $order->load(['restaurant', 'menuItems.images']);

        // Calculate totals
        $subtotal = $order->menuItems->sum(function ($item) {
            return $item->price * $item->pivot->quantity;
        });

        // No delivery fee for pickup/in-restaurant
        $total = $subtotal;

        return Inertia::render('Customer/Checkout/Index', [
            'order' => $order,
            'subtotal' => $subtotal,
            'total' => $total,
        ]);
    }

    public function process(Request $request, Order $order)
    {
        $this->authorize('update', $order);

        if ($order->order_status_id !== OrderStatus::InCart) {
            return back()->with('error', 'Order is not in cart.');
        }

        // TODO: Implement actual payment processing here.
        // For now, we'll just simulate a successful payment.

        $order->update([
            'order_status_id' => OrderStatus::Placed,
            'time_placed' => now(),
        ]);

        return redirect()->route('customer.dashboard')->with('success', 'Order placed successfully!');
    }
}
