<?php

namespace App\Models;

use App\Events\MenuItemUpdated;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOneThrough;

/**
 * @property-read int|null $restaurant_id Derived from foodType relationship
 */
class MenuItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'price',
        'description',
        'food_type_id',
        'is_available',
        'image_id',
    ];

    protected function casts(): array
    {
        return [
            'is_available' => 'boolean',
        ];
    }

    protected static function booted()
    {
        // Always eager load foodType to make restaurant_id accessor efficient
        static::addGlobalScope('withFoodType', function (Builder $builder) {
            $builder->with('foodType');
        });

        static::created(function ($menuItem) {
            MenuItemUpdated::dispatch($menuItem);
        });

        static::updated(function ($menuItem) {
            MenuItemUpdated::dispatch($menuItem);
        });
    }

    /**
     * Accessor for restaurant_id - derives from foodType relationship.
     * Maintains backward compatibility with existing code using $menuItem->restaurant_id
     */
    public function getRestaurantIdAttribute(): ?int
    {
        return $this->foodType?->restaurant_id;
    }

    /**
     * Get the restaurant through foodType.
     * Uses HasOneThrough for proper relationship definition.
     */
    public function restaurant(): HasOneThrough
    {
        return $this->hasOneThrough(
            Restaurant::class,
            FoodType::class,
            'id',           // Foreign key on FoodType table (food_types.id)
            'id',           // Foreign key on Restaurant table (restaurants.id)
            'food_type_id', // Local key on MenuItem table
            'restaurant_id' // Local key on FoodType table
        );
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

    public function image(): BelongsTo
    {
        return $this->belongsTo(Image::class, 'image_id');
    }

    public function orders(): BelongsToMany
    {
        return $this->belongsToMany(Order::class, 'order_items', 'order_items')
            ->withPivot('quantity')
            ->withTimestamps();
    }
}
