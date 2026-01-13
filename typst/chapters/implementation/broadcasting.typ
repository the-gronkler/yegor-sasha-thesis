#import "../../config.typ": code_example, source_code_link

== Real-Time Broadcasting

To allow for instant feedback without manual page reloads, the system implements a real-time broadcasting layer. This is particularly crucial for order status tracking and menu item availability where latency directly impacts user experience.

The broadcasting system utilizes Laravel Reverb, a WebSocket server built for Laravel applications, to enable bidirectional communication between the server and clients. Events triggered on the backend, such as order updates, are broadcast to subscribed clients in real-time, eliminating the need for polling mechanisms that could introduce unnecessary load and delay.

=== Backend Event Broadcasting
On the backend, broadcasting is implemented using Laravel's event system with dedicated event classes that implement `ShouldBroadcast`. This approach ensures automatic event dispatching when model data changes, maintaining real-time synchronization across clients. Events are dispatched from model `booted` methods on create/update, supplemented by `touch()` calls in controllers for relationship updates.

This architectural pattern centralizes broadcasting logic in model event handlers, adhering to the separation of concerns principle by isolating real-time notification responsibilities from business logic in controllers and services.
It follows the open-closed principle, allowing new broadcasting behaviors to be added via event classes without modifying existing code.

This approach reduces errors by automating event dispatching on data changes, ensures the system remains reactive to all relevant updates, and promotes maintainability through declarative event definitions.

#code_example[
  For example, the `OrderUpdated` event is defined as follows:

  ```php
  <?php
  class OrderUpdated implements ShouldBroadcast
  {
      use Dispatchable, InteractsWithSockets, SerializesModels;

      public function __construct(public Order $order) {}

      public function broadcastOn(): array
      {
          return [
              new PrivateChannel('order.'.$this->order->id),
              new PrivateChannel('restaurant.'.$this->order->restaurant_id),
              new PrivateChannel('user.'.$this->order->customer_user_id),
          ];
      }
  }
  ```

  This event broadcasts to the order's private channel, the restaurant's channel, and the customer's channel, ensuring all relevant parties receive updates.
]

#code_example[
  In the `Order` model, the `booted` method dispatches the event on creation and status changes:

  ```php
  <?php
  protected static function booted()
  {
      static::created(function ($order) {
          OrderUpdated::dispatch($order);
      });

      static::updated(function ($order) {
          if ($order->wasChanged('order_status_id')) {
              OrderUpdated::dispatch($order);
          }
      });
  }
  ```
]

#code_example[
  For relationship updates, such as modifying allergens on a menu item, the controller calls `touch()` after the update to trigger the model's `updated` event:

  ```php
  <?php
  // In MenuItemController, after updating allergens
  $menuItem->allergens()->sync($allergenIds);
  $menuItem->touch(); // Triggers MenuItemUpdated event
  ```
]

If needed, events can also be dispatched directly from controllers for custom logic, providing flexibility while maintaining the automatic broadcasting foundation.

=== Frontend Abstraction: `useChannelUpdates` Hook
Instead of scattering specific `Echo` listeners across various components, a generic custom hook `useChannelUpdates` was implemented in #source_code_link("resources/js/Hooks/Updates/useChannelUpdates.ts"). This abstraction handles:
- Connection lifecycle (subscribing/unsubscribing/leaving channels).
- Discrimination between `public` and `private` channels, using `window.Echo.channel()` for public and `window.Echo.private()` for authenticated private channels.
- Debouncing of reload requests to prevent "event storms" from causing multiple unnecessary page refreshes, implemented with a 200ms timeout chosen as a compromise between responsiveness and coalescing bursts of rapid-fire events into a single reload.

The hook accepts parameters including an array of IDs, a channel prefix (e.g., 'restaurant'), event names, an optional reload condition callback, and a boolean for private channels. This simplifies the consumption of real-time data in components by centralizing subscription logic and ensuring proper cleanup on unmount.

The parameters for `useChannelUpdates` are documented as follows:

- `ids` (array of numbers): The identifiers used to construct channel names (e.g., `[orderId]` for `order.{orderId}`).
- `prefix` (string): The channel prefix, such as 'order' or 'restaurant'.
- `events` (array of strings): The event names to listen for, like `['OrderUpdated']`.
- `private` (boolean): Whether to use private channels (authenticated) or public channels.
- `reloadCondition` (optional function): A callback that determines if a page reload should occur based on the event data; returns a boolean. Default is to always reload on event.

This parameterization allows flexible configuration while maintaining type safety and consistency.

To reduce code duplication and ensure parameter correctness, the generic `useChannelUpdates` hook is not used directly in page components. Instead, specific child hooks are created under #source_code_link("resources/js/Hooks/Updates") directory that wrap the generic hook with predefined configurations. Examples include:
- `useMenuItemUpdates(restaurantId)`: Subscribes to public menu item events for a restaurant's availability updates.
- `useOrderUpdates(orderIds)`: Subscribes to private order events for status changes.
- `useRestaurantOrdersUpdates(restaurantId)`: Subscribes to private restaurant order events.

These specific hooks encapsulate the correct parameters and event handling logic, promoting reusability and reducing errors.

#code_example[
  For instance, `useOrderUpdates` is implemented as follows:

  ```typescript
  export function useOrderUpdates(
    orderIds: number | number[] | undefined,
    shouldReload?: (event: OrderUpdatedEvent) => boolean,
  ) {
    useChannelUpdates(
      orderIds,
      'order',
      ['OrderUpdated'],
      shouldReload,
      true, // Private channel
    );
  }
  ```

  This allows different pages to specify different reload conditions. For example, a customer order page might reload on all status changes, while an employee dashboard might only reload for certain status transitions.
]

#code_example[

  These specific hooks are then used directly in page components for clarity and simplicity. They accept an optional `shouldReload` callback to control when page reloads occur based on event data.

  In the Customer Order Status page:

  ```typescript
  const { isConnected } = useOrderUpdates(orderId);
  ```
]

#code_example[
  In the Employee Orders page:

  ```typescript
  const { isConnected } = useRestaurantOrdersUpdates(restaurantId);
  ```
]

This layered architecture—generic hook, specific wrappers, and page-level usage—ensures clean separation of concerns and ease of testing.




#code_example[
  === Channel Security and Authorization
  Private channels are used for sensitive order data (`private-restaurant.{id}`).

  Access control is enforced in #source_code_link("routes/channels.php") route definition file, with the `order.{orderId}` channel defined as:
  ```php
  <?php
  Broadcast::channel('order.{orderId}', function ($user, $orderId) {
      $order = Order::find($orderId);
      if (! $order) {
          return false;
      }

      // Allow customer or employees of the restaurant
      $employeeRestaurantId = $user->employee?->restaurant_id;

      return (int) $user->id === (int) $order->customer_user_id ||
          ($employeeRestaurantId !== null &&
          (int) $employeeRestaurantId === (int) $order->restaurant_id);
  });
  ```

  This logic ensures that:
  - Customers can only listen to their own orders by matching user ID with `order.customer_user_id`.
  - Employees can only listen to orders for the restaurant they work at by matching `user.employee.restaurant_id` with `order.restaurant_id`.
]

Authorization leverages Laravel's channel-based authentication, preventing unauthorized access to WebSocket channels. This approach provides fine-grained access control at the channel level, ensuring data privacy and security.

=== Environment Configuration and Protocol Handling
A significant implementation challenge involved the "Split Protocol" architecture required for the containerized deployment:
- *Internal Traffic*: Communication between the Laravel backend and the Reverb server occurs over plain HTTP (port 8080) within the private Docker network to avoid complexity with self-signed certificates.
- *External Traffic*: Client browsers connect via Secure WebSockets (WSS) over HTTPS (port 443), terminated by the Caddy reverse proxy.

This required specific configuration in `.env`:
- `REVERB_BACKEND_SCHEME=http` for internal Laravel-to-Reverb communication.
- `VITE_REVERB_SCHEME=https` for frontend client connections.
- `REVERB_BACKEND_HOST=127.0.0.1` targeting the local Reverb instance.

These settings ensure secure external connections while maintaining reliable internal service-to-service communication, with the reverse proxy handling SSL termination.

=== Performance Considerations and Error Handling
To handle potential connection failures, the implementation includes automatic reconnection logic in the `useChannelUpdates` hook, with exponential backoff to avoid overwhelming the server. Additionally, events are queued on the backend using Laravel's broadcasting system, ensuring no data loss during temporary disconnections.

The debouncing mechanism prevents excessive reloads by delaying the execution of the reload callback, allowing multiple rapid events to be consolidated into a single action. This is implemented using a timeout that resets on each new event, ensuring responsiveness without performance degradation.
