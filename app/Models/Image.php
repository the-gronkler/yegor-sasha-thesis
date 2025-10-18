<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Image extends Model
{
    use HasFactory;

    protected $fillable = [
        'image',
        'description',
        'restaurant_id',
        'menu_item_id',
        'is_primary_for_restaurant',
        'is_primary_for_menu_item',
    ];

    protected function casts(): array
    {
        return [
            'is_primary_for_restaurant' => 'boolean',
            'is_primary_for_menu_item' => 'boolean',
        ];
    }

    public function restaurant(): BelongsTo
    {
        return $this->belongsTo(Restaurant::class);
    }

    public function menuItem(): BelongsTo
    {
        return $this->belongsTo(MenuItem::class);
    }
}
