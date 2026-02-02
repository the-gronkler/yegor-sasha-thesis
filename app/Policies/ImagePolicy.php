<?php

namespace App\Policies;

use App\Models\Image;
use App\Models\Restaurant;
use App\Models\User;

class ImagePolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return true;
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Image $image): bool
    {
        return true;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user, ?Restaurant $restaurant = null): bool
    {
        if ($user->is_admin) {
            return true;
        }

        if (! $user->isEmployee() || $user->employee?->restaurant_id === null) {
            return false;
        }

        if ($restaurant !== null) {
            return $user->employee->restaurant_id == $restaurant->id;
        }

        return true;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Image $image): bool
    {
        return $user->is_admin || ($user->isEmployee() && $user->employee?->restaurant_id == $image->restaurant_id);
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Image $image): bool
    {
        return $user->is_admin || ($user->isEmployee() && $user->employee?->restaurant_id == $image->restaurant_id);
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, Image $image): bool
    {
        return $user->is_admin || ($user->isEmployee() && $user->employee?->restaurant_id == $image->restaurant_id);
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, Image $image): bool
    {
        return $user->is_admin || ($user->isEmployee() && $user->employee?->restaurant_id == $image->restaurant_id);
    }
}
