<?php

use App\Models\Order;
use App\Models\Restaurant;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('order.{orderId}', function ($user, $orderId) {
    $order = Order::find($orderId);
    if (! $order) {
        return false;
    }

    // Allow customer or employees of the restaurant
    $employeeRestaurantId = $user->employee?->restaurant_id;

    return (int) $user->id === (int) $order->customer_user_id ||
        ($employeeRestaurantId !== null && (int) $employeeRestaurantId === (int) $order->restaurant_id);
});

Broadcast::channel('restaurant.{restaurantId}', function ($user, $restaurantId) {
    // Allow employees of the restaurant
    $employeeRestaurantId = $user->employee?->restaurant_id;

    return $employeeRestaurantId !== null && (int) $employeeRestaurantId === (int) $restaurantId;
});

Broadcast::channel('user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});
