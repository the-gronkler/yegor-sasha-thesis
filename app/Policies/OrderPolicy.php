<?php

namespace App\Policies;

use App\Models\Order;
use App\Models\User;

class OrderPolicy
{
    /**
     * Determine whether the user can view any models.
     * NOTE: This authorizes access to the "List Orders" page.
     * The Controller is responsible for filtering the actual rows returned.
     */
    public function viewAny(User $user): bool
    {
        return $user->is_admin || $user->isCustomer() || $user->isEmployee();
    }

    /**
     * Determine whether the user can view the model.
     * STRICT CHECK: Only Admin, the specific Restaurant's Employee, or the Customer who owns it.
     */
    public function view(User $user, Order $order): bool
    {
        return $user->is_admin ||
            ($user->isEmployee() && $user->employee?->restaurant_id === $order->restaurant_id) ||
            ($user->id === $order->customer_user_id);
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->isCustomer();
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Order $order): bool
    {
        return $user->is_admin ||
               ($user->isEmployee() && $user->employee?->restaurant_id === $order->restaurant_id) ||
               ($user->id === $order->customer_user_id); // Needed if customer updates cart
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Order $order): bool
    {
        // Allow customer to delete their own order (used for clearing cart)
        return $user->is_admin ||
               ($user->id === $order->customer_user_id);
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, Order $order): bool
    {
        return $user->is_admin;
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, Order $order): bool
    {
        return $user->is_admin;
    }
}
