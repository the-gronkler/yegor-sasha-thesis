import axios from 'axios';
window.axios = axios;

window.axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

import { route } from 'ziggy-js';
import { Ziggy } from './ziggy';
window.route = (name, params, absolute) => route(name, params, absolute, Ziggy);
window.Ziggy = Ziggy;
