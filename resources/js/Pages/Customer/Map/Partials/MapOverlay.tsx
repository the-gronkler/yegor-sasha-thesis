import { useState, useEffect, useCallback } from 'react';
import SearchInput from '@/Components/UI/SearchInput';
import {
  Cog6ToothIcon,
  XMarkIcon,
  MapPinIcon,
  PencilSquareIcon,
  CursorArrowRaysIcon,
  FunnelIcon,
  MagnifyingGlassIcon,
  FireIcon,
} from '@heroicons/react/24/outline';

/**
 * MapOverlay (UI Component)
 *
 * Responsibilities:
 * - Renders the floating controls on top of the map.
 * - Manages UI state for collapsible panels (Settings, Radius).
 * - Handles user input for: Search, Radius Slider, Manual Coordinates.
 * - Triggers callbacks to the parent for actual data updates.
 */
const MIN_RADIUS = 1;
const MAX_RADIUS = 50;
const NO_RANGE_SLIDER_VALUE = 51; // rightmost = "No range"

// Convert backend radius -> slider value
const radiusToSlider = (radius: number) => {
  if (!radius || radius <= 0) return NO_RANGE_SLIDER_VALUE;
  return Math.min(MAX_RADIUS, Math.max(MIN_RADIUS, radius));
};

// Convert slider value -> backend radius
const sliderToRadius = (sliderValue: number) => {
  return sliderValue === NO_RANGE_SLIDER_VALUE ? 0 : sliderValue;
};

interface MapOverlayProps {
  query: string;
  onQueryChange: (query: string) => void;
  hasLocation: boolean;
  currentRadius: number;
  onRadiusChange: (radius: number) => void;
  isGeolocating: boolean;
  onTriggerGeolocate: () => void;
  isPickingLocation: boolean;
  setIsPickingLocation: (isPicking: boolean) => void;
  onManualLocation: (lat: number, lng: number) => void;
  onError: (error: string | null) => void;
  showHeatmap: boolean;
  onToggleHeatmap: (show: boolean) => void;
  showSearchInArea: boolean;
  onSearchInArea: () => void;
  mapCenter: {
    latitude: number;
    longitude: number;
    zoom: number;
  };
}

export default function MapOverlay({
  query,
  onQueryChange,
  hasLocation,
  currentRadius,
  onRadiusChange,
  isGeolocating,
  onTriggerGeolocate,
  isPickingLocation,
  setIsPickingLocation,
  onManualLocation,
  onError,
  showHeatmap,
  onToggleHeatmap,
  showSearchInArea,
  onSearchInArea,
  mapCenter,
}: MapOverlayProps) {
  // Collapsible overlay states
  const [controlsOpen, setControlsOpen] = useState(false);
  const [radiusOpen, setRadiusOpen] = useState(false);

  // Manual location picking state
  const [manualOpen, setManualOpen] = useState(false);
  const [manualLat, setManualLat] = useState<string>('');
  const [manualLng, setManualLng] = useState<string>('');

  // Radius slider state
  const [radiusSliderValue, setRadiusSliderValue] = useState<number>(() =>
    radiusToSlider(currentRadius),
  );

  // Sync slider if prop changes (e.g. after navigation)
  useEffect(() => {
    setRadiusSliderValue(radiusToSlider(currentRadius));
  }, [currentRadius]);

  // If the controls panel is closed, also close manual input + pick mode
  useEffect(() => {
    if (!controlsOpen) {
      setManualOpen(false);
      setIsPickingLocation(false);
    }
  }, [controlsOpen, setIsPickingLocation]);

  const collapseAll = () => {
    setControlsOpen(false);
    setRadiusOpen(false);
    setManualOpen(false);
    setIsPickingLocation(false);
    onError(null);
  };

  // Commit radius change
  const commitRadius = useCallback(
    (e: React.SyntheticEvent<HTMLInputElement>) => {
      if (!hasLocation) return;
      const sliderValue = Number((e.currentTarget as HTMLInputElement).value);
      onRadiusChange(sliderToRadius(sliderValue));
    },
    [hasLocation, onRadiusChange],
  );

  // Apply manual coordinates
  const applyManualCoords = () => {
    const lat = Number(manualLat);
    const lng = Number(manualLng);

    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      onError('Please enter valid numeric latitude/longitude.');
      return;
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      onError('Latitude must be -90..90 and longitude must be -180..180.');
      return;
    }

    setManualOpen(false);
    setIsPickingLocation(false);
    onError(null);
    onManualLocation(lat, lng);
  };

  const radiusLabel =
    radiusSliderValue === NO_RANGE_SLIDER_VALUE
      ? 'No range'
      : `${radiusSliderValue} km`;

  return (
    <div className="map-overlay">
      <div className="map-controls-card">
        <div className="map-controls-header">
          <SearchInput
            value={query}
            onChange={onQueryChange}
            placeholder="Search restaurants..."
            className="map-search-input map-search-input--transparent"
          />

          <div className="map-controls-header-actions">
            {hasLocation && (
              <button
                type="button"
                className={`map-overlay-toggle ${radiusOpen ? 'is-active' : ''}`}
                onClick={() => setRadiusOpen((v) => !v)}
                aria-label={
                  radiusOpen ? 'Hide radius options' : 'Show radius options'
                }
                aria-expanded={radiusOpen}
                aria-controls="map-radius-panel"
              >
                <FunnelIcon className="btn-icon" aria-hidden="true" />
              </button>
            )}

            <button
              type="button"
              className={`map-overlay-toggle ${controlsOpen ? 'is-active' : ''}`}
              onClick={() => setControlsOpen((v) => !v)}
              aria-label={
                controlsOpen ? 'Hide map controls' : 'Show map controls'
              }
              aria-expanded={controlsOpen}
              aria-controls="map-controls-panel"
            >
              <Cog6ToothIcon className="btn-icon" aria-hidden="true" />
            </button>

            {(controlsOpen || radiusOpen) && (
              <button
                type="button"
                className="map-overlay-toggle map-overlay-toggle--close"
                onClick={collapseAll}
                aria-label="Collapse overlay"
              >
                <XMarkIcon className="btn-icon" aria-hidden="true" />
              </button>
            )}
          </div>
        </div>

        {/* Collapsible map controls panel */}
        <div
          id="map-controls-panel"
          className={`map-collapsible ${controlsOpen ? 'is-open' : ''}`}
        >
          <div className="map-collapsible__inner">
            <div className="map-location-controls">
              <button
                className="location-control-btn"
                disabled={isGeolocating}
                onClick={onTriggerGeolocate}
                aria-label="Find my location"
              >
                {isGeolocating ? (
                  'Locating...'
                ) : (
                  <>
                    <MapPinIcon className="btn-icon" aria-hidden="true" />
                    My Location
                  </>
                )}
              </button>

              <button
                className="location-control-btn"
                onClick={() => {
                  setManualOpen((v) => !v);
                  setIsPickingLocation(false);
                }}
                aria-label="Enter coordinates"
              >
                <PencilSquareIcon className="btn-icon" aria-hidden="true" />
                Enter Coords
              </button>

              <button
                className="location-control-btn"
                onClick={() => {
                  setIsPickingLocation(!isPickingLocation);
                  setManualOpen(false);
                }}
                aria-label="Pick location on map"
              >
                <CursorArrowRaysIcon className="btn-icon" aria-hidden="true" />
                Pick on Map
              </button>
            </div>

            <div className="map-layer-controls">
              <button
                type="button"
                className={`map-heatmap-toggle ${showHeatmap ? 'is-active' : ''}`}
                onClick={() => onToggleHeatmap(!showHeatmap)}
                aria-label={showHeatmap ? 'Hide heatmap' : 'Show heatmap'}
                aria-pressed={showHeatmap}
              >
                <FireIcon className="btn-icon" aria-hidden="true" />
                Heatmap
              </button>
            </div>

            {manualOpen && (
              <div className="map-manual-input">
                <input
                  type="number"
                  step="0.000001"
                  placeholder="Latitude (e.g. 52.2297)"
                  value={manualLat}
                  onChange={(e) => setManualLat(e.target.value)}
                />
                <input
                  type="number"
                  step="0.000001"
                  placeholder="Longitude (e.g. 21.0122)"
                  value={manualLng}
                  onChange={(e) => setManualLng(e.target.value)}
                />
                <button onClick={applyManualCoords}>Apply</button>
                <button onClick={() => setManualOpen(false)}>
                  <XMarkIcon className="btn-icon" aria-hidden="true" />
                </button>
              </div>
            )}

            {isPickingLocation && (
              <div className="map-pick-instruction">
                <small>Click on the map to set your location</small>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Collapsible radius panel */}
      {hasLocation && (
        <div
          id="map-radius-panel"
          className={`map-collapsible ${radiusOpen ? 'is-open' : ''}`}
        >
          <div className="map-collapsible__inner">
            <div className="map-radius">
              <div className="map-radius__top">
                <span className="map-radius__label">Radius</span>
                <span className="map-radius__value">{radiusLabel}</span>
              </div>

              <div className="map-radius__slider">
                <input
                  className="radius-slider"
                  type="range"
                  min={MIN_RADIUS}
                  max={NO_RANGE_SLIDER_VALUE}
                  step={1}
                  value={radiusSliderValue}
                  onChange={(e) => setRadiusSliderValue(Number(e.target.value))}
                  onMouseUp={commitRadius}
                  onTouchEnd={commitRadius}
                  onKeyUp={(e) => {
                    if (
                      [
                        'ArrowLeft',
                        'ArrowRight',
                        'ArrowUp',
                        'ArrowDown',
                        'Home',
                        'End',
                      ].includes(e.key)
                    ) {
                      commitRadius(e);
                    }
                  }}
                  style={
                    {
                      '--pct': `${
                        ((radiusSliderValue - MIN_RADIUS) /
                          (NO_RANGE_SLIDER_VALUE - MIN_RADIUS)) *
                        100
                      }%`,
                    } as React.CSSProperties & { '--pct': string }
                  }
                  aria-label="Radius"
                  aria-valuetext={
                    radiusSliderValue === NO_RANGE_SLIDER_VALUE
                      ? 'No range'
                      : `${radiusSliderValue} kilometers`
                  }
                />

                <div className="radius-ruler" aria-hidden="true" />

                <div className="radius-ends" aria-hidden="true">
                  <span>{MIN_RADIUS}</span>
                  <span>25</span>
                  <span>No range</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Search in this area button */}
      {showSearchInArea && (
        <div className="map-search-area-container">
          <button
            type="button"
            className="map-search-area-btn map-search-area-btn--detailed"
            onClick={onSearchInArea}
            aria-label={`Search restaurants around ${mapCenter.latitude.toFixed(
              4,
            )}, ${mapCenter.longitude.toFixed(4)}`}
          >
            <div className="map-search-area-btn__content">
              <div className="map-search-area-btn__icon">
                <MagnifyingGlassIcon aria-hidden="true" />
              </div>
              <div className="map-search-area-btn__text">
                <div className="map-search-area-btn__title">Search here</div>
                <div className="map-search-area-btn__coords">
                  {mapCenter.latitude.toFixed(4)},{' '}
                  {mapCenter.longitude.toFixed(4)}
                </div>
              </div>
            </div>
          </button>
        </div>
      )}
    </div>
  );
}
