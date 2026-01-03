import { AxiosInstance } from 'axios';
import { route as routeFn } from 'ziggy-js';
import { Config } from 'ziggy-js';
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

declare global {
  interface Window {
    axios: AxiosInstance;
    Echo: Echo;
    Pusher: typeof Pusher;
    route: typeof routeFn;
    Ziggy: Config;
  }
  var route: typeof routeFn;
}
