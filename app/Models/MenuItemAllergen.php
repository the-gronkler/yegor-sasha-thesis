<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\Pivot;

class MenuItemAllergen extends Pivot
{
    protected $table = 'menu_item_allergen';

    /**
     * Get the menu item that owns the allergen.
     */
    public function menuItem(): BelongsTo
    {
        return $this->belongsTo(MenuItem::class);
    }
}
