import type { LayerProps } from 'react-map-gl/mapbox';

export interface MapTheme {
  [key: string]: string;
  brandPrimary: string;
  brandPrimaryHover: string;
  accentWarm: string;
  textInverse: string;
}

export const getClusterLayer = (theme: MapTheme): LayerProps => ({
  id: 'clusters',
  type: 'circle',
  source: 'restaurants',
  filter: ['has', 'point_count'],
  paint: {
    'circle-color': [
      'step',
      ['get', 'point_count'],
      theme.accentWarm,
      2,
      theme.brandPrimary,
      10,
      theme.brandPrimaryHover,
    ],
    'circle-radius': ['step', ['get', 'point_count'], 20, 10, 30, 20, 40],
  },
});

export const getClusterCountLayer = (): LayerProps => ({
  id: 'cluster-count',
  type: 'symbol',
  source: 'restaurants',
  filter: ['has', 'point_count'],
  layout: {
    'text-field': '{point_count_abbreviated}',
    'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
    'text-size': 12,
  },
  paint: {
    'text-color': '#ffffff',
  },
});

export const getSelectedPointLayer = (
  theme: MapTheme,
  selectedId: number | null | undefined,
): LayerProps => ({
  id: 'selected-point',
  type: 'circle',
  source: 'restaurants',
  filter: ['==', ['get', 'id'], selectedId || -999],
  paint: {
    'circle-color': theme.brandPrimary,
    'circle-radius': 18,
    'circle-stroke-color': theme.brandPrimaryHover,
    'circle-stroke-width': 3,
  },
});

export const getUnclusteredPointLayer = (theme: MapTheme): LayerProps => ({
  id: 'unclustered-point',
  type: 'circle',
  source: 'restaurants',
  filter: ['!', ['has', 'point_count']],
  paint: {
    'circle-color': theme.brandPrimary,
    'circle-radius': 14,
  },
});

export const getHeatmapLayer = (): LayerProps => ({
  id: 'heatmap',
  type: 'heatmap',
  source: 'restaurants',
  maxzoom: 17,
  paint: {
    // Increase the heatmap weight based on frequency and property magnitude
    'heatmap-weight': [
      'interpolate',
      ['linear'],
      ['coalesce', ['get', 'point_count'], 1],
      0,
      0,
      1,
      0.8,
      10,
      1,
    ],
    // Increase the heatmap color weight by zoom level
    // heatmap-intensity is a multiplier on top of heatmap-weight
    'heatmap-intensity': ['interpolate', ['linear'], ['zoom'], 0, 1, 15, 5],
    // Color ramp for heatmap.  Domain is 0 (low) to 1 (high).
    // Begin color ramp at 0-stop with a 0-transparency color
    // to create a blur-like effect.
    'heatmap-color': [
      'interpolate',
      ['linear'],
      ['heatmap-density'],
      0,
      'rgba(33,102,172,0)',
      0.1,
      'rgb(103,169,207)',
      0.3,
      'rgb(209,229,240)',
      0.5,
      'rgb(253,219,199)',
      0.7,
      'rgb(239,138,98)',
      1,
      'rgb(178,24,43)',
    ],
    // Adjust the heatmap radius by zoom level
    'heatmap-radius': [
      'interpolate',
      ['linear'],
      ['zoom'],
      0,
      20,
      9,
      80,
      15,
      120,
    ],
    // Transition from heatmap to circle layer by zoom level
    'heatmap-opacity': ['interpolate', ['linear'], ['zoom'], 10, 1, 16, 0],
  },
});
