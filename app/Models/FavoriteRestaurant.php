<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\Pivot;

/**
 * @property int $customer_user_id
 * @property int $restaurant_id
 */
class FavoriteRestaurant extends Pivot
{
    use HasFactory;

    protected $table = 'favorite_restaurants';

    protected $fillable = [
        'customer_user_id',
        'restaurant_id',
        'rank',
    ];
}
