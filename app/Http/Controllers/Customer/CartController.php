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

        $newQuantity = $currentQuantity + $data['quantity'];

        if ($newQuantity <= 0) {
            $order->menuItems()->detach($data['menu_item_id']);
            $this->cleanupEmptyOrder($order);
        } else {
            $order->menuItems()->syncWithoutDetaching([
                $data['menu_item_id'] => ['quantity' => $newQuantity],
            ]);
        }

        return back()->with('success', 'Item added to cart');
    }

    public function removeItem(Request $request)
    {
        $data = $request->validate([
            'menu_item_id' => 'required|integer|exists:menu_items,id',
        ]);

        $customer = $request->user()->customer;

        $order = Order::where('customer_user_id', $customer->user_id)
            ->where('order_status_id', OrderStatus::InCart)
            ->whereHas('menuItems', function ($q) use ($data) {
                $q->where('menu_items.id', $data['menu_item_id']);
            })
            ->firstOrFail();

        $order->menuItems()->detach($data['menu_item_id']);
        $this->cleanupEmptyOrder($order);

        return back()->with('success', 'Item removed from cart');
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

    public function updateItemQuantity(Request $request)
    {
        $data = $request->validate([
            'menu_item_id' => 'required|integer|exists:menu_items,id',
            'quantity' => 'required|integer|min:0',
            'restaurant_id' => 'required|integer|exists:restaurants,id',
        ]);

        $customer = $request->user()->customer;

        $order = Order::firstOrCreate(
            [
                'customer_user_id' => $customer->user_id,
                'order_status_id' => OrderStatus::InCart,
                'restaurant_id' => $data['restaurant_id'],
            ]
        );
        if ($data['quantity'] <= 0) {
            $order->menuItems()->detach($data['menu_item_id']);
            $this->cleanupEmptyOrder($order);
        } else {
            $order->menuItems()->syncWithoutDetaching([
                $data['menu_item_id'] => ['quantity' => $data['quantity']],
            ]);
        }

        return back()->with('success', 'Cart updated');
    }

    private function cleanupEmptyOrder(Order $order): void
    {
        if ($order->menuItems()->count() === 0) {
            $order->delete();
        }
    }
}
