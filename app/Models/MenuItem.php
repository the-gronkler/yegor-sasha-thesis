<?php

namespace App\Models;

use App\Events\MenuItemUpdated;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MenuItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'restaurant_id',
        'name',
        'price',
        'description',
        'food_type_id',
        'is_available',
    ];

    protected function casts(): array
    {
        return [
            'is_available' => 'boolean',
        ];
    }

    public function restaurant(): BelongsTo
    {
        return $this->belongsTo(Restaurant::class);
    }

    public function foodType(): BelongsTo
    {
        return $this->belongsTo(FoodType::class);
    }

    public function allergens(): BelongsToMany
    {
        return $this->belongsToMany(Allergen::class, 'menu_item_allergen');
    }

    public function images(): HasMany
    {
        return $this->hasMany(Image::class);
    }

    public function orders(): BelongsToMany
    {
        return $this->belongsToMany(Order::class, 'order_items', 'order_items')
            ->withPivot('quantity')
            ->withTimestamps();
    }

    protected static function booted()
    {
        static::created(function ($menuItem) {
            MenuItemUpdated::dispatch($menuItem);
        });

        static::updated(function ($menuItem) {
            MenuItemUpdated::dispatch($menuItem);
        });
    }
}
