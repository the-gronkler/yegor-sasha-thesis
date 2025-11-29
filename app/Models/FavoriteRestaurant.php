<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory; // <--- Add this import
use Illuminate\Database\Eloquent\Model;

/**
 * @property int $customer_user_id
 * @property int $restaurant_id
 */
class FavoriteRestaurant extends Model
{
    use HasFactory;

    protected $table = 'favorite_restaurants';

    protected $fillable = [
        'customer_user_id',
        'restaurant_id',
        'rank',
    ];
}
