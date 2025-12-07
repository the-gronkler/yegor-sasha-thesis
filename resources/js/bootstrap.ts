import axios from "axios";
import { route as routeFn } from "ziggy-js";
import { Ziggy } from "./ziggy";

window.axios = axios;

window.axios.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest";

// @ts-ignore
window.route = (
    name?: string,
    params?: any,
    absolute?: boolean,
    config?: any,
) => {
    if (name === undefined) {
        return routeFn(undefined, undefined, undefined, config || Ziggy);
    }
    return routeFn(name, params, absolute, config || Ziggy);
};
window.Ziggy = Ziggy;
