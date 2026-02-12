#import "../../config.typ": code_example, source_code_link

== Real-Time Communication Technologies
To meet the requirement for instant order updates (Kitchen Display System), the system employs a comprehensive real-time communication stack consisting of backend and frontend components.

*Laravel Reverb* serves as the WebSocket server on the backend, selected over third-party SaaS solutions (like Pusher or Ably) and adjacent technologies (like Node.js Socket.IO) for several reasons:
- *Integration*: It provides native integration with Laravel's broadcasting system and Event classes.
- *Cost & Privacy*: Being self-hosted within the application's infrastructure, it eliminates external subscription costs and keeps data entirely within the system boundary.
- *Performance*: Built on top of the ReactPHP asynchronous runtime and the Ratchet WebSocket library, it offers high-performance throughput suitable for the expected load @LaravelReverbDocs.
- *Protocol Support*: It adheres to the Pusher Protocol @LaravelReverbDocs @PusherProtocol, enabling the use of robust client libraries on the frontend.

For the frontend, *Laravel Echo* acts as the JavaScript client library @LaravelBroadcastingDocs, paired with *Pusher.js* for WebSocket connectivity. This combination ensures seamless compatibility with Reverb:
- *Echo*: Provides a high-level abstraction for subscribing to channels and listening for events, integrating directly with React components via hooks.
- *Pusher.js*: Handles the underlying WebSocket connections and protocol negotiation, ensuring reliable real-time data flow.
- *Advantages*: Eliminates the need for custom WebSocket management, supports authentication for private channels, and offers automatic reconnection and error handling.
- *Alternatives Considered*: Direct WebSocket APIs were rejected due to complexity and lack of built-in security features; Socket.IO was deemed unnecessary given Reverb's Pusher Protocol adherence.
