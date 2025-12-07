import { AxiosInstance } from 'axios';
import { route as routeFn } from 'ziggy-js';
import { Config } from 'ziggy-js';

declare global {
    interface Window {
        axios: AxiosInstance;
        route: typeof routeFn;
        Ziggy: Config;
    }
    var route: typeof routeFn;
}
