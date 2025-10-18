<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\Pivot;

class OrderItem extends Pivot
{
    protected $table = 'order_items';

    protected $fillable = [
        'order_id',
        'menu_item_id',
        'quantity',
    ];
}
