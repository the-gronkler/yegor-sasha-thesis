<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Customer extends Model
{
    use HasFactory;

    protected $primaryKey = 'user_id';

    public $incrementing = false;

    protected $fillable = [
        'user_id',
        'payment_method_token',
    ];

    /**
     * Get the user associated with this customer.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class, 'customer_user_id', 'user_id');
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class, 'customer_user_id', 'user_id');
    }

    /**
     * The restaurants that this customer has favorited.
     */
    public function favoriteRestaurants(): BelongsToMany
    {
        return $this->belongsToMany(Restaurant::class, 'favorite_restaurants', 'customer_user_id', 'restaurant_id')
            ->withPivot('rank')
            ->withTimestamps();
    }
}
