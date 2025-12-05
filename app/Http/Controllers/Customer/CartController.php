<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\MenuItem;
use App\Models\Order;
use Illuminate\Http\Request;
use Inertia\Inertia;

class CartController extends Controller
{
    public function index(Request $request)
    {
        $customer = $request->user()->customer; // assuming relation user→customer
        $cartOrder = Order::with('menuItems')
            ->where('customer_user_id', $customer->user_id)
            ->where('order_status_id', Order::STATUS_IN_CART) // constant
            ->first();

        return Inertia::render('Customer/Cart/Index', [
            'cart' => $cartOrder,
        ]);
    }

    public function addItem(Request $request)
    {
        $data = $request->validate([
            'menu_item_id' => 'required|integer|exists:menu_items,id',
            'quantity' => 'required|integer|min:1',
        ]);

        $customer = $request->user()->customer;

        // determine or create cart order
        $order = Order::firstOrCreate([
            'customer_user_id' => $customer->user_id,
            'restaurant_id' => MenuItem::find($data['menu_item_id'])->restaurant_id,
            'order_status_id' => Order::STATUS_IN_CART,
        ]);

        // attach item or update quantity
        $order->menuItems()->syncWithoutDetaching([
            $data['menu_item_id'] => ['quantity' => $data['quantity']],
        ]);

        return redirect()->route('cart.index')->with('success', 'Item added to cart');
    }

    public function removeItem(Request $request)
    {
        $data = $request->validate([
            'menu_item_id' => 'required|integer|exists:menu_items,id',
        ]);

        $customer = $request->user()->customer;

        $order = Order::where('customer_user_id', $customer->user_id)
            ->where('order_status_id', Order::STATUS_IN_CART)
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
