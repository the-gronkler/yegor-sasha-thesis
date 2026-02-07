<?php

namespace App\Policies;

use App\Models\MenuItem;
use App\Models\Restaurant; // Import Restaurant model
use App\Models\User;

class MenuItemPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(?User $user): bool
    {
        return true;
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(?User $user, MenuItem $menuItem): bool
    {
        return true;
    }

    /**
     * Determine whether the user can create models.
     *
     * We accept an optional Restaurant instance here.
     * Controller usage: $this->authorize('create', [MenuItem::class, $restaurant]);
     */
    public function create(User $user, ?Restaurant $restaurant = null): bool
    {
        if ($user->is_admin) {
            return true;
        }

        // Must be an employee with a restaurant assignment
        if (! $user->isEmployee() || $user->employee?->restaurant_id === null) {
            return false;
        }

        // If a specific restaurant context is provided, enforce ownership
        if ($restaurant !== null) {
            return $user->employee->restaurant_id === $restaurant->id;
        }

        // If no restaurant is passed, we allow it based on the fact they are a valid employee.
        // (Ideally, your controller should always pass the restaurant to be strict).
        return true;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, MenuItem $menuItem): bool
    {
        return $user->is_admin || ($user->isEmployee() && $user->employee?->restaurant_id === $menuItem->restaurant_id && $user->employee->is_admin);
    }

    /**
     * Determine whether the user can update the status (availability) of the model.
     */
    public function updateStatus(User $user, MenuItem $menuItem): bool
    {
        return $user->is_admin || ($user->isEmployee() && $user->employee?->restaurant_id === $menuItem->restaurant_id);
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, MenuItem $menuItem): bool
    {
        return $user->is_admin || ($user->isEmployee() && $user->employee?->restaurant_id === $menuItem->restaurant_id);
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, MenuItem $menuItem): bool
    {
        return $user->is_admin || ($user->isEmployee() && $user->employee?->restaurant_id === $menuItem->restaurant_id);
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, MenuItem $menuItem): bool
    {
        return $user->is_admin || ($user->isEmployee() && $user->employee?->restaurant_id === $menuItem->restaurant_id);
    }
}
