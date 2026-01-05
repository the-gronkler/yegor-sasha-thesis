<?php

use App\Models\Order;
use App\Models\Restaurant;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('order.{orderId}', function ($user, $orderId) {
    $order = Order::with('restaurant')->find($orderId);
    if (! $order) {
        return false;
    }

    // Allow customer or employees of the restaurant
    return (int) $user->id === (int) $order->customer_user_id ||
        ($user->employee && (int) $user->employee->restaurant_id === (int) $order->restaurant_id);
});

Broadcast::channel('restaurant.{restaurantId}', function ($user, $restaurantId) {
    // Allow employees of the restaurant
    return $user->employee && (int) $user->employee->restaurant_id === (int) $restaurantId;
});

Broadcast::channel('user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});
