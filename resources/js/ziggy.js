const Ziggy = {
  url: 'http:\/\/yegor-sasha-thesis.test',
  port: null,
  defaults: {},
  routes: {
    'debugbar.openhandler': {
      uri: '_debugbar\/open',
      methods: ['GET', 'HEAD'],
    },
    'debugbar.clockwork': {
      uri: '_debugbar\/clockwork\/{id}',
      methods: ['GET', 'HEAD'],
      parameters: ['id'],
    },
    'debugbar.assets.css': {
      uri: '_debugbar\/assets\/stylesheets',
      methods: ['GET', 'HEAD'],
    },
    'debugbar.assets.js': {
      uri: '_debugbar\/assets\/javascript',
      methods: ['GET', 'HEAD'],
    },
    'debugbar.cache.delete': {
      uri: '_debugbar\/cache\/{key}\/{tags?}',
      methods: ['DELETE'],
      parameters: ['key', 'tags'],
    },
    'debugbar.queries.explain': {
      uri: '_debugbar\/queries\/explain',
      methods: ['POST'],
    },
    'sanctum.csrf-cookie': {
      uri: 'sanctum\/csrf-cookie',
      methods: ['GET', 'HEAD'],
    },
    'restaurants.index': { uri: '\/', methods: ['GET', 'HEAD'] },
    'map.index': { uri: 'map', methods: ['GET', 'HEAD'] },
    'restaurants.show': {
      uri: 'restaurants\/{restaurant}',
      methods: ['GET', 'HEAD'],
      parameters: ['restaurant'],
      bindings: { restaurant: 'id' },
    },
    'cart.index': { uri: 'cart', methods: ['GET', 'HEAD'] },
    'cart.addItem': { uri: 'cart\/add-item', methods: ['POST'] },
    'cart.removeItem': { uri: 'cart\/remove-item', methods: ['DELETE'] },
    'cart.addNote': {
      uri: 'cart\/add-note\/{order}',
      methods: ['PUT'],
      parameters: ['order'],
      bindings: { order: 'id' },
    },
    'orders.index': { uri: 'orders', methods: ['GET', 'HEAD'] },
    'orders.unfinished': {
      uri: 'orders\/unfinished',
      methods: ['GET', 'HEAD'],
    },
    'orders.old': { uri: 'orders\/old', methods: ['GET', 'HEAD'] },
    'orders.destroyCart': {
      uri: 'orders\/cart\/{order}',
      methods: ['DELETE'],
      parameters: ['order'],
      bindings: { order: 'id' },
    },
    'reviews.index': { uri: 'reviews', methods: ['GET', 'HEAD'] },
    'reviews.store': { uri: 'reviews', methods: ['POST'] },
    'profile.show': { uri: 'profile', methods: ['GET', 'HEAD'] },
    'profile.update': { uri: 'profile', methods: ['PUT'] },
    'profile.destroy': { uri: 'profile', methods: ['DELETE'] },
    'profile.favorites': {
      uri: 'profile\/favorites',
      methods: ['GET', 'HEAD'],
    },
    'restaurant.menu-categories.index': {
      uri: 'restaurant\/menu-categories',
      methods: ['GET', 'HEAD'],
    },
    'restaurant.menu-categories.create': {
      uri: 'restaurant\/menu-categories\/create',
      methods: ['GET', 'HEAD'],
    },
    'restaurant.menu-categories.store': {
      uri: 'restaurant\/menu-categories',
      methods: ['POST'],
    },
    'restaurant.menu-categories.show': {
      uri: 'restaurant\/menu-categories\/{menu_category}',
      methods: ['GET', 'HEAD'],
      parameters: ['menu_category'],
    },
    'restaurant.menu-categories.edit': {
      uri: 'restaurant\/menu-categories\/{menu_category}\/edit',
      methods: ['GET', 'HEAD'],
      parameters: ['menu_category'],
    },
    'restaurant.menu-categories.update': {
      uri: 'restaurant\/menu-categories\/{menu_category}',
      methods: ['PUT', 'PATCH'],
      parameters: ['menu_category'],
    },
    'restaurant.menu-categories.destroy': {
      uri: 'restaurant\/menu-categories\/{menu_category}',
      methods: ['DELETE'],
      parameters: ['menu_category'],
    },
    'restaurant.menu-items.index': {
      uri: 'restaurant\/menu-items',
      methods: ['GET', 'HEAD'],
    },
    'restaurant.menu-items.create': {
      uri: 'restaurant\/menu-items\/create',
      methods: ['GET', 'HEAD'],
    },
    'restaurant.menu-items.store': {
      uri: 'restaurant\/menu-items',
      methods: ['POST'],
    },
    'restaurant.menu-items.show': {
      uri: 'restaurant\/menu-items\/{menu_item}',
      methods: ['GET', 'HEAD'],
      parameters: ['menu_item'],
    },
    'restaurant.menu-items.edit': {
      uri: 'restaurant\/menu-items\/{menu_item}\/edit',
      methods: ['GET', 'HEAD'],
      parameters: ['menu_item'],
    },
    'restaurant.menu-items.update': {
      uri: 'restaurant\/menu-items\/{menu_item}',
      methods: ['PUT', 'PATCH'],
      parameters: ['menu_item'],
    },
    'restaurant.menu-items.destroy': {
      uri: 'restaurant\/menu-items\/{menu_item}',
      methods: ['DELETE'],
      parameters: ['menu_item'],
    },
    'restaurant.workers.index': {
      uri: 'restaurant\/workers',
      methods: ['GET', 'HEAD'],
    },
    'restaurant.workers.create': {
      uri: 'restaurant\/workers\/create',
      methods: ['GET', 'HEAD'],
    },
    'restaurant.workers.store': {
      uri: 'restaurant\/workers',
      methods: ['POST'],
    },
    'restaurant.workers.show': {
      uri: 'restaurant\/workers\/{worker}',
      methods: ['GET', 'HEAD'],
      parameters: ['worker'],
    },
    'restaurant.workers.edit': {
      uri: 'restaurant\/workers\/{worker}\/edit',
      methods: ['GET', 'HEAD'],
      parameters: ['worker'],
    },
    'restaurant.workers.update': {
      uri: 'restaurant\/workers\/{worker}',
      methods: ['PUT', 'PATCH'],
      parameters: ['worker'],
    },
    'restaurant.workers.destroy': {
      uri: 'restaurant\/workers\/{worker}',
      methods: ['DELETE'],
      parameters: ['worker'],
    },
    'restaurant.menu-items.updateStatus': {
      uri: 'restaurant\/menu-items\/{item}\/status',
      methods: ['PUT'],
      parameters: ['item'],
      bindings: { item: 'id' },
    },
    'restaurant.orders.updateStatus': {
      uri: 'restaurant\/orders\/{order}\/status',
      methods: ['PUT'],
      parameters: ['order'],
      bindings: { order: 'id' },
    },
    login: { uri: 'login', methods: ['GET', 'HEAD'] },
    'login.store': { uri: 'login', methods: ['POST'] },
    register: { uri: 'register', methods: ['GET', 'HEAD'] },
    'register.store': { uri: 'register', methods: ['POST'] },
    logout: { uri: 'logout', methods: ['POST'] },
    'storage.local': {
      uri: 'storage\/{path}',
      methods: ['GET', 'HEAD'],
      wheres: { path: '.*' },
      parameters: ['path'],
    },
  },
};
if (typeof window !== 'undefined' && typeof window.Ziggy !== 'undefined') {
  Object.assign(Ziggy.routes, window.Ziggy.routes);
}
export { Ziggy };
