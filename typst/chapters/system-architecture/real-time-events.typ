#import "../../config.typ": code_example, source_code_link

== Event-Driven Real-Time Topology <real-time-events>
The system employs an event-driven architecture to decouple action execution from interface updates, enabling real-time synchronization across distributed components.

- *Event Sources*: Actions such as "Order Updated" or "Menu Item Updated" dispatch strongly typed Events within the Laravel backend, encapsulating data changes and triggering downstream processes.
- *Message Broker*: These events are forwarded to the *Reverb WebSocket Server* via a database-backed queue to ensure non-blocking operation of the main HTTP application, preventing performance degradation during high-load scenarios.
- *Channel Distribution*:
  - *Public Channels*: Used for general updates (e.g., `restaurant.{id}` for menu changes) where data is non-sensitive and broad reach is required, allowing all connected clients to receive updates without authentication.
  - *Private Channels*: Used for sensitive data requiring strict authentication. Order events are broadcast on three private channels (`order.{orderId}`, `restaurant.{restaurantId}`, `user.{userId}`), ensuring that customers, restaurant staff, and user-specific interfaces each receive targeted updates through appropriate authorization checks.
- *Client Subscription*: The React frontend maintains persistent WebSocket connections, subscribing to relevant channels based on the user's current view and permissions, ensuring the interface reflects the state of the server without polling or manual refreshes.

This topology integrates with the overall layered architecture, where the presentation layer (React/Inertia) communicates bidirectionally with the application layer (Laravel) via WebSockets, while the data layer (Eloquent/Database) handles event persistence and queuing through Laravel's built-in database-backed job storage.

Security is enforced through channel authorization in `routes/channels.php`, verifying user roles and relationships before granting access.

While the functional requirements do not necessitate separate horizontal scaling for broadcasting events, the system could support it via Reverb's asynchronous processing capabilities, which include optional Swoole integration and Redis-based clustering that could be enabled independently for handling increased WebSocket connection loads across multiple server instances.
