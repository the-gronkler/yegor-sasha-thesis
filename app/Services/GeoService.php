<?php

namespace App\Services;

use Illuminate\Http\Request;

class GeoService
{
    public const DEFAULT_RADIUS_KM = 50.0;

    public const MAX_RADIUS_KM = 100;

    public const KM_PER_DEGREE = 111.0;

    public const EARTH_RADIUS_KM = 6371;

    public const MAX_LATITUDE = 85.0;

    public const MIN_LATITUDE = -85.0;

    public const SESSION_EXPIRY_SECONDS = 86400; // 24 hours

    /**
     * Retrieve valid geolocation coordinates from the session.
     *
     * Checks if 'geo.last' exists in the session and if the stored coordinates
     * are fresh (less than 24 hours old).
     *
     * @return array|null Returns ['lat' => float, 'lng' => float] or null if invalid/expired.
     */
    public function getValidGeoFromSession(Request $request): ?array
    {
        $geo = $request->session()->get('geo.last');

        if (! $geo || ! isset($geo['lat'], $geo['lng'])) {
            return null;
        }

        // Check if coordinates are fresh (less than 24 hours old)
        if (isset($geo['stored_at']) && (time() - (int) $geo['stored_at']) > self::SESSION_EXPIRY_SECONDS) {
            return null;
        }

        return [
            'lat' => (float) $geo['lat'],
            'lng' => (float) $geo['lng'],
        ];
    }

    /**
     * Store geolocation coordinates in the session.
     */
    public function storeGeoInSession(Request $request, float $lat, float $lng): void
    {
        $request->session()->put('geo.last', [
            'lat' => $lat,
            'lng' => $lng,
            'stored_at' => time(),
        ]);
    }

    /**
     * Format a distance value for display (rounded to 2 decimal places).
     */
    public function formatDistance(float|string|null $distance): ?float
    {
        if ($distance === null) {
            return null;
        }

        return round((float) $distance, 2);
    }

    /**
     * Calculate the bounding box for a given point and radius.
     *
     * @param  float  $lat  Latitude in degrees
     * @param  float  $lng  Longitude in degrees
     * @param  float  $radiusKm  Radius in kilometers
     * @return array{latMin: float, latMax: float, lngMin: float, lngMax: float}
     */
    public function getBoundingBox(float $lat, float $lng, float $radiusKm): array
    {
        // ~111km per degree at equator; adjust for latitude
        $kmPerDegree = self::KM_PER_DEGREE;
        $clampedLat = max(min($lat, self::MAX_LATITUDE), self::MIN_LATITUDE); // Avoid poles

        $latDelta = $radiusKm / $kmPerDegree;
        $lngDelta = $radiusKm / ($kmPerDegree * cos(deg2rad($clampedLat)));

        return [
            'latMin' => $lat - $latDelta,
            'latMax' => $lat + $latDelta,
            'lngMin' => $lng - $lngDelta,
            'lngMax' => $lng + $lngDelta,
        ];
    }
}
