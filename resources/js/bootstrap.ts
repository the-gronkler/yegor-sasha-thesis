import axios from "axios";
import { route as routeFn } from "ziggy-js";
import { Ziggy } from "./ziggy";

window.axios = axios;

window.axios.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest";

window.route = (name: string, params?: any, absolute?: boolean) =>
    routeFn(name, params, absolute, Ziggy);
window.Ziggy = Ziggy;
