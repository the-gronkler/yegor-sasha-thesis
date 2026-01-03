<?php

namespace App\Http\Controllers\Employee;

use App\Enums\OrderStatus as OrderStatusEnum;
use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class EmployeeOrderController extends Controller
{
    /**
     * Display the employee orders page.
     */
    public function index(Request $request): Response
    {
        $user = $request->user();
        $restaurant = $user->employee->restaurant;

        // Define default active statuses (excludes: InCart, Cancelled, Declined, Fulfilled)
        $defaultActiveStatuses = [
            OrderStatusEnum::Placed->value,
            OrderStatusEnum::Accepted->value,
            OrderStatusEnum::Preparing->value,
            OrderStatusEnum::Ready->value,
        ];

        // Get filter from request or use default
        $filterStatuses = $request->input('statuses');

        if ($filterStatuses === null) {
            // Default filter: active orders only
            $statusFilter = $defaultActiveStatuses;
        } elseif ($filterStatuses === 'all') {
            // Show all except InCart
            $statusFilter = collect(OrderStatusEnum::cases())
                ->filter(fn ($status) => $status !== OrderStatusEnum::InCart)
                ->map(fn ($status) => $status->value)
                ->toArray();
        } else {
            // Custom filter from request
            $statusFilter = is_array($filterStatuses)
                ? array_map('intval', $filterStatuses)
                : explode(',', $filterStatuses);
        }

        // Get orders for this restaurant with filter applied
        $orders = Order::with([
            'customer.user',
            'menuItems',
            'status',
        ])
            ->where('restaurant_id', $restaurant->id)
            ->whereIn('order_status_id', $statusFilter)
            ->orderBy('time_placed', 'desc')
            ->get()
            ->map(function ($order) {
                return [
                    'id' => $order->id,
                    'customer_name' => trim($order->customer->user->name.' '.($order->customer->user->surname ?? '')),
                    'customer_email' => $order->customer->user->email,
                    'status_id' => $order->order_status_id->value,
                    'status_name' => $order->order_status_id->label(),
                    'time_placed' => $order->time_placed,
                    'notes' => $order->notes,
                    'items' => $order->menuItems->map(fn ($item) => [
                        'id' => $item->id,
                        'name' => $item->name,
                        'quantity' => $item->pivot->quantity,
                        'price' => $item->price,
                    ]),
                    'total' => $order->total,
                ];
            });

        // Group orders by status for better organization
        $ordersByStatus = [
            'new' => $orders->filter(fn ($o) => $o['status_id'] == OrderStatusEnum::Placed->value),
            'accepted' => $orders->filter(fn ($o) => $o['status_id'] == OrderStatusEnum::Accepted->value),
            'declined' => $orders->filter(fn ($o) => $o['status_id'] == OrderStatusEnum::Declined->value),
            'preparing' => $orders->filter(fn ($o) => $o['status_id'] == OrderStatusEnum::Preparing->value),
            'ready' => $orders->filter(fn ($o) => $o['status_id'] == OrderStatusEnum::Ready->value),
            'cancelled' => $orders->filter(fn ($o) => $o['status_id'] == OrderStatusEnum::Cancelled->value),
            'fulfilled' => $orders->filter(fn ($o) => $o['status_id'] == OrderStatusEnum::Fulfilled->value),
        ];

        // All available statuses for filter UI
        $allStatuses = collect(OrderStatusEnum::cases())
            ->filter(fn ($status) => $status !== OrderStatusEnum::InCart)
            ->map(fn ($status) => [
                'id' => $status->value,
                'name' => $status->label(),
                'isActive' => in_array($status->value, $defaultActiveStatuses),
            ])
            ->values();

        return Inertia::render('Employee/Orders', [
            'orders' => $orders->values(),
            'ordersByStatus' => [
                'new' => $ordersByStatus['new']->values(),
                'accepted' => $ordersByStatus['accepted']->values(),
                'declined' => $ordersByStatus['declined']->values(),
                'preparing' => $ordersByStatus['preparing']->values(),
                'ready' => $ordersByStatus['ready']->values(),
                'cancelled' => $ordersByStatus['cancelled']->values(),
                'fulfilled' => $ordersByStatus['fulfilled']->values(),
            ],
            'availableStatuses' => $allStatuses,
            'currentFilter' => array_values($statusFilter), // Ensure it's a proper array
            'defaultActiveStatuses' => $defaultActiveStatuses,
        ]);
    }

    /**
     * Update order status.
     */
    public function updateStatus(Request $request, Order $order): RedirectResponse
    {
        // Authorization check verifies the employee belongs to the order's restaurant
        $this->authorize('update', $order);

        $validated = $request->validate([
            'order_status_id' => ['required', 'integer', 'exists:order_statuses,id'],
        ]);

        $order->update([
            'order_status_id' => $validated['order_status_id'],
        ]);

        return back()->with('success', 'Order status updated successfully.');
    }
}
