import type { LayerProps } from 'react-map-gl/mapbox';

export interface MapTheme {
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
