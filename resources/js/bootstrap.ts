import axios from 'axios';
import { route as routeFn } from 'ziggy-js';
// import { Ziggy } from './ziggy'; // Don't use the static file, it has the build-time URL

window.axios = axios;

window.axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

// @ts-ignore
window.route = (
  name?: string,
  params?: any,
  absolute?: boolean,
  config?: any,
) => {
  // Use the global Ziggy object injected by Blade (which has the correct runtime URL)
  // @ts-ignore
  const ziggyConfig = config || window.Ziggy;

  if (name === undefined) {
    return routeFn(undefined, undefined, undefined, ziggyConfig);
  }
  return routeFn(name, params, absolute, ziggyConfig);
};
// @ts-ignore - Ziggy types may not match perfectly with generated routes
window.Ziggy = Ziggy;
