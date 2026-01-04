<?php

namespace App\Models;

use App\Enums\OrderStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Order extends Model
{
    use HasFactory;

    protected $casts = [
        'order_status_id' => OrderStatus::class,
    ];

    protected $fillable = [
        'restaurant_id',
        'notes',
        'order_status_id',
        'customer_user_id',
        'time_placed',
    ];

    protected $appends = [
        'total',
    ];

    /**
     * Get the total price of the order.
     */
    public function getTotalAttribute(): float
    {
        return $this->menuItems->sum(fn ($item) => $item->price * $item->pivot->quantity);
    }

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
        return $this->belongsTo(\App\Models\OrderStatus::class, 'order_status_id');
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class, 'customer_user_id', 'user_id');
    }
}
