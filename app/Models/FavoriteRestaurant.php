<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\Pivot;

class FavoriteRestaurant extends Pivot
{
    protected $table = 'favorite_restaurants';

    protected $fillable = [
        'customer_user_id',
        'restaurant_id',
        'rank',
    ];
}
