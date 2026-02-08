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
        'is_primary_for_restaurant',
    ];

    protected $appends = ['url'];

    protected function casts(): array
    {
        return [
            'is_primary_for_restaurant' => 'boolean',
        ];
    }

    public function getUrlAttribute()
    {
        // TODO: remvoe this logic after we put default images in the bucket too
        if (str_starts_with($this->image, 'http://') || str_starts_with($this->image, 'https://')) {
            return $this->image;
        }

        return Storage::disk('r2')->url($this->image);
    }

    public function restaurant(): BelongsTo
    {
        return $this->belongsTo(Restaurant::class);
    }
}
