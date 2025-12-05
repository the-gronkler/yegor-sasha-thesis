<?php

namespace App\Policies;

use App\Models\Employee;
use App\Models\Restaurant;
use App\Models\User;

class EmployeePolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->is_admin || ($user->isEmployee() && $user->employee?->is_admin);
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Employee $employee): bool
    {
        return $user->is_admin ||
               $user->id === $employee->user_id ||
               ($user->isEmployee() && $user->employee?->is_admin && $user->employee->restaurant_id === $employee->restaurant_id);
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user, ?Restaurant $restaurant = null): bool
    {
        if ($user->is_admin) {
            return true;
        }

        // Must be a restaurant manager (employee with is_admin = true)
        if (! $user->isEmployee() || ! $user->employee?->is_admin || $user->employee->restaurant_id === null) {
            return false;
        }

        if ($restaurant !== null) {
            return $user->employee->restaurant_id === $restaurant->id;
        }

        return true;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Employee $employee): bool
    {
        return $user->is_admin ||
               ($user->isEmployee() && $user->employee?->is_admin && $user->employee->restaurant_id === $employee->restaurant_id);
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Employee $employee): bool
    {
        return $user->is_admin ||
               ($user->isEmployee() && $user->employee?->is_admin && $user->employee->restaurant_id === $employee->restaurant_id);
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, Employee $employee): bool
    {
        return $user->is_admin ||
               ($user->isEmployee() && $user->employee?->is_admin && $user->employee->restaurant_id === $employee->restaurant_id);
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, Employee $employee): bool
    {
        return $user->is_admin;
    }
}
