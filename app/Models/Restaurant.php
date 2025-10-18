<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Restaurant extends Model
{
    protected $fillable = [
        'name',
        'address',
        'latitude',
        'longitude',
        'description',
        'rating',
    ];

    public function employees(): HasMany
    {
        return $this->hasMany(Employee::class);
    }

    public function menuItems(): HasMany
    {
        return $this->hasMany(MenuItem::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function images(): HasMany
    {
        return $this->hasMany(Image::class);
    }

    public function foodTypes(): HasMany
    {
        return $this->hasMany(FoodType::class);
    }

    /**
     * The customers that have favorited this restaurant.
     */
    public function favoritedBy(): BelongsToMany
    {
        return $this->belongsToMany(Customer::class, 'favorite_restaurants', 'restaurant_id', 'customer_user_id')
            ->withPivot('rank')
            ->withTimestamps();
    }
}
