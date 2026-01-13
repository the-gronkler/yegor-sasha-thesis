import type { LayerProps } from 'react-map-gl/mapbox';

export interface MapTheme {
  [key: string]: string;
  brandPrimary: string;
  brandPrimaryHover: string;
  accentWarm: string;
  textInverse: string;
}

/**
 * Cluster layer for MTS (Mapbox Tiling Service) clustered points.
 * MTS clustering produces a 'count' property (not 'point_count').
 * Uses 'restaurants-clustered' source-layer for low zoom levels.
 */
export const getClusterLayer = (theme: MapTheme): LayerProps => ({
  id: 'clusters',
  type: 'circle',
  source: 'restaurants',
  'source-layer': 'restaurants-clustered', // MTS clustered layer
  filter: ['has', 'count'], // MTS uses 'count' not 'point_count'
  paint: {
    'circle-color': [
      'step',
      ['get', 'count'],
      theme.accentWarm, // < 2 restaurants
      2,
      theme.brandPrimary, // 2-9 restaurants
      10,
      theme.brandPrimaryHover, // 10+ restaurants
    ],
    'circle-radius': ['step', ['get', 'count'], 20, 10, 30, 20, 40],
  },
});

/**
 * Cluster count label for MTS clustered points.
 */
export const getClusterCountLayer = (): LayerProps => ({
  id: 'cluster-count',
  type: 'symbol',
  source: 'restaurants',
  'source-layer': 'restaurants-clustered', // MTS clustered layer
  filter: ['has', 'count'],
  layout: {
    'text-field': ['to-string', ['get', 'count']], // Display cluster count
    'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
    'text-size': 12,
  },
  paint: {
    'text-color': '#ffffff',
  },
});

/**
 * Selected restaurant point highlight.
 * Uses 'restaurants' source-layer (raw points at high zoom).
 * Converts restaurant_id from string to number for comparison.
 */
export const getSelectedPointLayer = (
  theme: MapTheme,
  selectedId: number | null | undefined,
): LayerProps => ({
  id: 'selected-point',
  type: 'circle',
  source: 'restaurants',
  'source-layer': 'restaurants', // Raw points layer
  filter: [
    '==',
    ['to-number', ['get', 'restaurant_id']], // Vector tile properties are strings
    selectedId ?? -999,
  ],
  paint: {
    'circle-color': theme.brandPrimary,
    'circle-radius': 18,
    'circle-stroke-color': theme.brandPrimaryHover,
    'circle-stroke-width': 3,
  },
});

/**
 * Unclustered restaurant points at high zoom.
 * Uses 'restaurants' source-layer (raw points).
 */
export const getUnclusteredPointLayer = (theme: MapTheme): LayerProps => ({
  id: 'unclustered-point',
  type: 'circle',
  source: 'restaurants',
  'source-layer': 'restaurants', // Raw points layer
  filter: ['!', ['has', 'count']], // Not a cluster (MTS uses 'count')
  paint: {
    'circle-color': theme.brandPrimary,
    'circle-radius': 14,
  },
});
