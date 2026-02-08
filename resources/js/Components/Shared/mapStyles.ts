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

export const getHeatmapLayer = (visible: boolean): LayerProps => {
  const paint: Record<string, unknown> = {
    // Weight: amplify dense clusters so tightly packed areas glow hotter
    'heatmap-weight': [
      'interpolate',
      ['linear'],
      ['coalesce', ['get', 'point_count'], 1],
      0,
      0,
      1,
      0.4,
      5,
      0.75,
      15,
      0.9,
      50,
      1,
    ],
    // Intensity multiplier: stronger at low zoom so zoomed-out view is vivid
    'heatmap-intensity': [
      'interpolate',
      ['linear'],
      ['zoom'],
      0,
      2,
      5,
      2.5,
      9,
      3.5,
      13,
      4.5,
      15,
      5,
    ],
    'heatmap-intensity-transition': { duration: 300, delay: 0 },
    // Vibrant color ramp optimized for dark map backgrounds:
    // transparent → deep blue → purple → orange → yellow → white
    'heatmap-color': [
      'interpolate',
      ['linear'],
      ['heatmap-density'],
      0,
      'rgba(0,0,0,0)',
      0.05,
      'rgba(31,72,165,0.3)',
      0.15,
      'rgba(77,105,204,0.6)',
      0.3,
      'rgba(139,89,191,0.85)',
      0.45,
      'rgb(217,100,89)',
      0.6,
      'rgb(237,141,52)',
      0.75,
      'rgb(251,185,56)',
      0.9,
      'rgb(255,232,116)',
      1,
      'rgb(255,255,255)',
    ],
    // Radius: larger at low zoom so blobs overlap and density builds up
    'heatmap-radius': [
      'interpolate',
      ['linear'],
      ['zoom'],
      0,
      20,
      3,
      30,
      5,
      40,
      8,
      55,
      10,
      70,
      12,
      85,
      14,
      110,
      16,
      140,
    ],
    'heatmap-radius-transition': { duration: 300, delay: 0 },
    // Smooth fade in/out when toggling; fade out at high zoom for circle layer
    'heatmap-opacity': visible
      ? ['interpolate', ['linear'], ['zoom'], 0, 1, 7, 0.95, 15, 0.6, 17, 0]
      : 0,
    'heatmap-opacity-transition': { duration: 250, delay: 0 },
  };

  return {
    id: 'heatmap',
    type: 'heatmap',
    source: 'restaurants',
    maxzoom: 17,
    paint,
  } as LayerProps;
};
