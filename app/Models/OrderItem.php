<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\Pivot;

class OrderItem extends Pivot
{
    protected $table = 'order_items';

    protected $fillable = [
        'order_id',
        'menu_item_id',
        'quantity',
    ];

    /**
     * Get the order that owns the order item.
     */
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * Get the menu item that owns the order item.
     */
    public function menuItem(): BelongsTo
    {
        return $this->belongsTo(MenuItem::class);
    }
}
