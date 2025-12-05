<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Order extends Model
{
    use HasFactory;

    // These constants map to the IDs in your 'order_statuses' table
    const STATUS_IN_CART = 1;
    const STATUS_PENDING = 2;
    const STATUS_PREPARING = 3;
    const STATUS_READY = 4;
    const STATUS_COMPLETED = 5;
    const STATUS_CANCELLED = 6;

    protected $fillable = [
        'restaurant_id',
        'notes',
        'order_status_id',
        'customer_user_id',
        'time_placed',
    ];

    public function menuItems(): BelongsToMany
    {
        return $this->belongsToMany(MenuItem::class, 'order_items')
            ->withPivot('quantity')
            ->withTimestamps();
    }

    public function restaurant(): BelongsTo
    {
        return $this->belongsTo(Restaurant::class);
    }

    public function status(): BelongsTo
    {
        return $this->belongsTo(OrderStatus::class, 'order_status_id');
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class, 'customer_user_id', 'user_id');
    }
}
