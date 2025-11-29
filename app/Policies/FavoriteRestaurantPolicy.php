<?php

namespace App\Policies;

use App\Models\FavoriteRestaurant;
use App\Models\User;

class FavoriteRestaurantPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->is_admin || $user->isCustomer();
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, FavoriteRestaurant $favoriteRestaurant): bool
    {
        return $user->is_admin || ($user->isCustomer() && $user->id === $favoriteRestaurant->customer_user_id);
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
    public function update(User $user, FavoriteRestaurant $favoriteRestaurant): bool
    {
        return $user->is_admin || ($user->isCustomer() && $user->id === $favoriteRestaurant->customer_user_id);
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, FavoriteRestaurant $favoriteRestaurant): bool
    {
        return $user->is_admin || ($user->isCustomer() && $user->id === $favoriteRestaurant->customer_user_id);
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, FavoriteRestaurant $favoriteRestaurant): bool
    {
        return $user->is_admin || ($user->isCustomer() && $user->id === $favoriteRestaurant->customer_user_id);
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, FavoriteRestaurant $favoriteRestaurant): bool
    {
        return $user->is_admin || ($user->isCustomer() && $user->id === $favoriteRestaurant->customer_user_id);
    }
}
