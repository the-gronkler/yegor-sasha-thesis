<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Restaurant;
use App\Services\GeoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class RestaurantMapController extends Controller
{
    protected GeoService $geoService;

    public function __construct(GeoService $geoService)
    {
        $this->geoService = $geoService;
    }

    /**
     * Get minimal restaurant data for map card/popup.
     *
     * This endpoint is called when a user clicks a restaurant point on the map.
     * Returns only essential fields needed for the popup, not the full restaurant resource.
     *
     * Performance optimizations:
     * - Caches result per restaurant ID for 30 minutes (map card data changes infrequently)
     * - Only loads primary image (not all images)
     * - Calculates distance if user geo is in session
     * - Checks favorite status efficiently with single query
     */
    public function show(Request $request, Restaurant $restaurant): JsonResponse
    {
        $this->authorize('view', $restaurant);

        $user = $request->user();
        $customerId = $user?->customer?->user_id;

        // Build cache key based on restaurant + user context
        $cacheKey = "map_card:{$restaurant->id}:user:".($customerId ?? 'guest');

        // Cache for 30 minutes (map card data is relatively static)
        $data = Cache::remember($cacheKey, now()->addMinutes(30), function () use ($restaurant, $request, $customerId) {
            // Get user's location from session (if available)
            $geo = $this->geoService->getValidGeoFromSession($request);
            $distance = null;

            if ($geo) {
                // Calculate distance using database scope (same logic as map query)
                $restaurantWithDistance = Restaurant::query()
                    ->where('id', $restaurant->id)
                    ->withDistanceTo($geo['lat'], $geo['lng'])
                    ->first();

                if ($restaurantWithDistance && $restaurantWithDistance->distance !== null) {
                    $distance = $this->geoService->formatDistance($restaurantWithDistance->distance);
                }
            }

            // Get primary image (most common use case for map cards)
            $primaryImage = $restaurant->images()
                ->where('is_primary_for_restaurant', true)
                ->first();

            // Check if favorited (only if user is authenticated customer)
            $isFavorited = false;
            if ($customerId) {
                $isFavorited = $restaurant->favoritedBy()
                    ->where('customer_user_id', $customerId)
                    ->exists();
            }

            return [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'address' => $restaurant->address,
                'latitude' => (float) $restaurant->latitude,
                'longitude' => (float) $restaurant->longitude,
                'rating' => $restaurant->rating,
                'opening_hours' => $restaurant->opening_hours,
                'distance' => $distance,
                'is_favorited' => $isFavorited,
                'primary_image_url' => $primaryImage?->image,
            ];
        });

        return response()->json($data);
    }

    /**
     * Invalidate cache for a specific restaurant's map card.
     *
     * Call this when restaurant data changes (e.g., via events/observers).
     */
    public static function invalidateCache(int $restaurantId): void
    {
        // Clear both guest and all potential user caches
        // In production, you might want to use cache tags for better invalidation
        Cache::forget("map_card:{$restaurantId}:user:guest");

        // Note: Individual user caches will expire naturally (30 min TTL)
        // For immediate invalidation, use cache tags or database-backed sessions
    }
}
