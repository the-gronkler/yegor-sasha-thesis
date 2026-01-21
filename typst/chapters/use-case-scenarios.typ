= Use Case Scenarios

This chapter briefly describes the main user-facing scenarios supported by the system. The scenarios complement the use case diagrams in the previous chapter by explaining typical user flows and key alternatives.

== UC1: Finding a Restaurant

*Actor:* Hungry customer.

*Goal:* Find a suitable restaurant on the map and open its details.

*Preconditions:*
- Restaurants have coordinates configured, so they can be displayed on the map.
- The selected restaurant has at least one available menu item.

*Main flow (summary):*
1. The customer opens the application and is redirected to the Explore page.
2. The customer grants geolocation permission.
3. The map centers on the user's location.
4. The customer browses the restaurant list and/or selects restaurants on the map to inspect address, rating, and description.
5. The customer opens the selected restaurant's details view.

*Alternative flows (summary):*
- If geolocation permission is denied, the customer navigates the map manually and uses a "Search here" action to load restaurants for the current viewport.
- If the customer prefers map-only browsing, they can keep the list collapsed and interact with map pins, optionally adjusting the search radius or filters.

#figure(
  image("../resources/FindingRestaurantUCScenario.png", width: 100%),
  caption: [Use case scenario: finding a restaurant.],
) <fig:uc-finding-restaurant>

*Postconditions:*
- The customer is redirected to the menu/details page of the selected restaurant.

== UC2: Creating an Order

*Actor:* Customer.

*Goal:* Build a cart, checkout, and place an order.

This scenario covers the typical ordering flow: selecting a restaurant, adding items to the cart, adjusting quantities, proceeding to checkout, and paying via the payment provider.

#figure(
  image("../resources/CreatingAnOrderUCScenario.png", width: 100%),
  caption: [Use case scenario: creating an order.],
) <fig:uc-creating-order>

== UC3: Order Management

*Actor:* Restaurant worker.

*Goal:* Process incoming orders and update their status.

TODO: Finalize this scenario description and align it with the implemented order lifecycle (e.g., accept/decline, preparing, ready, completed/cancelled).

#figure(
  image("../resources/OrderManagementUCScenario.png", width: 100%),
  caption: [Use case scenario: order management (draft).],
) <fig:uc-order-management>
