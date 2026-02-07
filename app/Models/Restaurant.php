<?php

namespace App\Models;

use App\Services\GeoService;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property int $id
 * @property string $name
 * @property string $address
 * @property float|null $latitude
 * @property float|null $longitude
 * @property string|null $description
 * @property float|null $rating
 */
class Restaurant extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'address',
        'latitude',
        'longitude',
        'description',
        'rating',
        'opening_hours',
    ];

    public function employees(): HasMany
    {
        return $this->hasMany(Employee::class);
    }

    public function menuItems(): HasMany
    {
        return $this->hasMany(MenuItem::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function images(): HasMany
    {
        return $this->hasMany(Image::class);
    }

    public function foodTypes(): HasMany
    {
        return $this->hasMany(FoodType::class);
    }

    /**
     * The customers that have favorited this restaurant.
     */
    public function favoritedBy(): BelongsToMany
    {
        return $this->belongsToMany(Customer::class, 'favorite_restaurants', 'restaurant_id', 'customer_user_id')
            ->withPivot('rank')
            ->withTimestamps();
    }

    /**
     * Recalculate the restaurant's average rating from its reviews.
     */
    public function recalculateRating(): void
    {
        $avgRating = $this->reviews()->avg('rating');

        $this->update([
            'rating' => $avgRating !== null ? round($avgRating, 2) : null,
        ]);
    }

    /**
     * Local Scope: Calculate distance to a given point.
     *
     * Adds a 'distance' column (in kilometers) to query results.
     * Uses MariaDB's ST_Distance_Sphere (returns meters, converted to km).
     * Falls back to Haversine formula if ST_Distance_Sphere is unavailable.
     *
     * IMPORTANT: Preserves base columns (restaurants.*) to prevent losing model attributes.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @param  float  $lat  User latitude (-90 to 90)
     * @param  float  $lng  User longitude (-180 to 180)
     * @return \Illuminate\Database\Eloquent\Builder
     *
     * MariaDB Note: ST_Distance_Sphere returns spherical distance in meters.
     * Coordinate order: POINT(longitude, latitude) - (x, y) = (lng, lat)
     *
     * Reference: https://mariadb.com/kb/en/st_distance_sphere/
     */
    public function scopeWithDistanceTo($query, float $lat, float $lng)
    {
        // If no explicit select was defined yet, keep all base columns.
        // This prevents losing restaurant attributes when we add the computed "distance".
        if (is_null($query->getQuery()->columns)) {
            $query->select($query->getModel()->getTable().'.*'); // restaurants.*
        }

        $useStDistance = config('geo.distance_formula', 'st_distance_sphere') === 'st_distance_sphere';

        if ($useStDistance) {
            // Option A: MariaDB ST_Distance_Sphere (preferred)
            // Returns meters, divide by 1000 for kilometers
            // POINT(x, y) = POINT(longitude, latitude) per spatial standards
            return $query->selectRaw(
                '(ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) / 1000) AS distance',
                [$lng, $lat]
            );
        } else {
            // Option B: Fallback Haversine formula (improved numerical stability)
            // Clamps acos() input to [-1, 1] to prevent NaN from float rounding
            $earthRadiusKm = GeoService::EARTH_RADIUS_KM;

            return $query->selectRaw(
                '(? * acos(
                    LEAST(1.0, GREATEST(-1.0,
                        cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?))
                        + sin(radians(?)) * sin(radians(latitude))
                    ))
                )) AS distance',
                [$earthRadiusKm, $lat, $lng, $lat]
            );
        }
    }

    /**
     * Local Scope: Filter restaurants within a radius using bounding box + exact distance.
     *
     * Performance strategy:
     * 1. Bounding box prefilter (uses separate lat/lng indexes - may trigger index_merge)
     * 2. Exact distance constraint via HAVING clause
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @param  float  $lat  User latitude (-90 to 90)
     * @param  float  $lng  User longitude (-180 to 180)
     * @param  float  $radiusKm  Maximum distance in kilometers
     * @return \Illuminate\Database\Eloquent\Builder
     *
     * MariaDB Note: Optimizer may use index_merge to combine separate lat/lng index scans.
     * EXPLAIN will show type=index_merge if this optimization is applied.
     */
    public function scopeWithinRadiusKm($query, float $lat, float $lng, float $radiusKm)
    {
        // Bounding box approximation (cheap prefilter)
        // Use GeoService to calculate bounds
        $bounds = app(GeoService::class)->getBoundingBox($lat, $lng, $radiusKm);

        // Apply bounding box using separate indexes
        // MariaDB may use index_merge to scan both indexes and intersect results
        $query->whereBetween('latitude', [$bounds['latMin'], $bounds['latMax']])
            ->whereBetween('longitude', [$bounds['lngMin'], $bounds['lngMax']]);

        // Apply exact distance constraint
        // HAVING works after grouping/aggregation; here it filters the computed distance
        return $query->having('distance', '<=', $radiusKm);
    }

    /**
     * Local Scope: Order results by distance (closest first).
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeOrderByDistance($query)
    {
        return $query->orderBy('distance', 'asc');
    }
}
