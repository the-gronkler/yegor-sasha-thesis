import SearchInput from '@/Components/UI/SearchInput';

interface MapOverlayProps {
  query: string;
  onQueryChange: (query: string) => void;
  selectedRadius: number;
  onRadiusChange: (newRadius: number) => void;
  filters: {
    lat: number | null;
    lng: number | null;
    radius: number;
  };
}

const RADIUS_OPTIONS = [2, 5, 10, 25, 50] as const;

export default function MapOverlay({
  query,
  onQueryChange,
  selectedRadius,
  onRadiusChange,
  filters,
}: MapOverlayProps) {
  return (
    <div className="map-overlay">
      <SearchInput
        value={query}
        onChange={onQueryChange}
        placeholder="Search restaurants..."
        className="map-search-input"
      />
      {filters.lat !== null && filters.lng !== null && (
        <div className="map-radius-selector">
          <label htmlFor="radius-select">Radius:</label>
          <select
            id="radius-select"
            value={selectedRadius}
            onChange={(e) => onRadiusChange(Number(e.target.value))}
            className="radius-select"
          >
            {RADIUS_OPTIONS.map((radius) => (
              <option key={radius} value={radius}>
                {radius} km
              </option>
            ))}
          </select>
        </div>
      )}
    </div>
  );
}
