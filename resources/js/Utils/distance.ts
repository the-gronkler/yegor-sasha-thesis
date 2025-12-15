/**
 * Calculates the distance between two geographic coordinates using the Haversine formula.
 *
 * @param lat1 - Latitude of the first point in degrees
 * @param lon1 - Longitude of the first point in degrees
 * @param lat2 - Latitude of the second point in degrees
 * @param lon2 - Longitude of the second point in degrees
 * @returns Distance in kilometers, rounded to 2 decimal places
 *
 * @example
 * ```typescript
 * const distance = calculateDistance(52.2297, 21.0122, 52.5200, 13.4050);
 * console.log(distance); // ~515.43 km (Warsaw to Berlin)
 * ```
 */
export function calculateDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number,
): number {
  const R = 6371; // Earth's radius in kilometers

  // Convert degrees to radians
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  const distance = R * c;

  // Round to 2 decimal places
  return Math.round(distance * 100) / 100;
}

/**
 * Converts degrees to radians.
 *
 * @param degrees - Angle in degrees
 * @returns Angle in radians
 */
function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}
