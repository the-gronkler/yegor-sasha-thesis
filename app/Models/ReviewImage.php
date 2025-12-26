<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class ReviewImage extends Model
{
    protected $fillable = [
        'image',
        'review_id',
    ];

    protected $appends = ['url'];

    public function getUrlAttribute()
    {
        // Check if the image path is already a full URL (e.g. from seeder)
        if (str_starts_with($this->image, 'http://') || str_starts_with($this->image, 'https://')) {
            return $this->image;
        }

        return Storage::disk('r2')->url($this->image);
    }

    public function review(): BelongsTo
    {
        return $this->belongsTo(Review::class);
    }

    public function scopeValid($query)
    {
        return $query->whereNotNull('image')->where('image', '!=', '');
    }
}
