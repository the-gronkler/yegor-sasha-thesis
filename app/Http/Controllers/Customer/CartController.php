<?php

namespace App\Http\Controllers\Customer;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Inertia\Inertia;

class CartController extends Controller
{
    public function index(Request $request)
    {
        $customer = $request->user()->customer;

        // Get all cart orders (one per restaurant)
        $cartOrders = Order::with(['menuItems.images', 'restaurant'])
            ->where('customer_user_id', $customer->user_id)
            ->where('order_status_id', OrderStatus::InCart)
            ->get();

        return Inertia::render('Customer/Cart/Index', [
            'cartOrders' => $cartOrders,
        ]);
    }

    public function addItem(Request $request)
    {
        $data = $request->validate([
            'menu_item_id' => 'required|integer|exists:menu_items,id',
            'quantity' => 'required|integer|min:1',
            'restaurant_id' => 'required|integer|exists:restaurants,id',
        ]);

        $customer = $request->user()->customer;

        // Find or create cart order for THIS specific restaurant
        $order = Order::firstOrCreate(
            [
                'customer_user_id' => $customer->user_id,
                'order_status_id' => OrderStatus::InCart,
                'restaurant_id' => $data['restaurant_id'], // Include restaurant_id in the search
            ]
        );

        // Sync item quantity (will update if exists, create if not)
        $currentQuantity = $order->menuItems()
            ->where('menu_item_id', $data['menu_item_id'])
            ->first()?->pivot?->quantity ?? 0;

        $order->menuItems()->syncWithoutDetaching([
            $data['menu_item_id'] => ['quantity' => $currentQuantity + $data['quantity']],
        ]);

        return back();
    }

    public function removeItem(Request $request)
    {
        $data = $request->validate([
            'menu_item_id' => 'required|integer|exists:menu_items,id',
        ]);

        $customer = $request->user()->customer;

        $order = Order::where('customer_user_id', $customer->user_id)
            ->where('order_status_id', OrderStatus::InCart)
            ->firstOrFail();

        $order->menuItems()->detach($data['menu_item_id']);

        return redirect()->route('cart.index')->with('success', 'Item removed from cart');
    }

    public function addNote(Request $request, Order $order)
    {
        $this->authorize('update', $order); // ensure the customer owns it

        $data = $request->validate([
            'notes' => 'nullable|string|max:1024',
        ]);

        $order->update(['notes' => $data['notes']]);

        return redirect()->route('cart.index')->with('success', 'Note updated');
    }
}
