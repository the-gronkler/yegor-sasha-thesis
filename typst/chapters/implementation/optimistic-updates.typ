#import "../../config.typ": code_example, source_code_link

== Optimistic Updates
Without optimistic updates, users would experience noticeable delays between performing an action and seeing the result, leading to a sluggish interface that feels unresponsive. For instance, clicking "Mark as Ready" on an order or adding an item to the cart would show no immediate change, requiring users to wait for the server response, which could take seconds and result in perceived system latency and ambiguity regarding the action's status about whether the action was registered.

Optimistic updates are implemented to enhance perceived performance and user experience across the application. When a user performs an action, such as updating an order status or modifying the shopping cart, the UI immediately reflects the change assuming success, providing instant feedback without waiting for server confirmation.

If the server response indicates failure, the UI reverts to the previous state. This is achieved through local state management with React Context and hooks, where actions trigger immediate updates followed by asynchronous server synchronization. For example, order status updates are implemented using the `useOptimisticOrderStatusUpdates` hook in #source_code_link("resources/js/Hooks/useOptimisticOrderStatusUpdates.ts"), with similar patterns applied to cart operations and other interactive features.

#code_example[
  For example, in the order update flow:
  1. User clicks "Mark as Ready".
  2. Local state updates optimistically to show the new status.
  3. API call is made in the background.
  4. On success, the update persists; on failure, the state reverts with an error notification.
]

This technique significantly enhances user experience by minimizing perceived latency in interactive systems, aligning with modern UX principles for responsive interfaces. It is ideally suited for low-risk actions like order status updates and cart modifications, as these can be easily reversed if necessary.

In contrast, optimistic updates are not employed for sensitive operations like checkout, where accuracy and explicit confirmation are critical to maintain data integrity.

