<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

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

    protected $appends = ['url'];

    protected function casts(): array
    {
        return [
            'is_primary_for_restaurant' => 'boolean',
            'is_primary_for_menu_item' => 'boolean',
        ];
    }

    public function getUrlAttribute()
    {
        if (str_starts_with($this->image, 'http://') || str_starts_with($this->image, 'https://')) {
            return $this->image;
        }

        return Storage::disk('r2')->url($this->image);
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
