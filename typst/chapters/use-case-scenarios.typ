= Use Case Scenarios

This chapter briefly describes the main scenarios supported by the system.
The scenarios complement the use case diagrams in the previous chapter by explaining typical user flows and key alternatives.

== UC1: Finding a Restaurant

The following scenario describes the process through which a restaurant is identified using the map-based index page.
As indicated by the diagram assumptions (@fig:ucs-finding-restaurant), authentication is not required to search for restaurants and view their details when identifying a restaurant of interest.
In the main flow, restaurants are located via the map, a restaurant marker is selected to display a brief overview, and the restaurant detail page is then opened to obtain additional information.
If geolocation permission is not granted, restaurants are searched on the map as illustrated in the first alternative flow.
In the alternative geolocation flow, the user centers the map in a location of his interest and identify nearby restaurants with the use of "Search here" button.
Alternatively, a location may be selected directly on the map by clicking or by writing the cordinates (omitted for simplicity).
Restaurants may also be identified via the collapsible list view rather than the map, as shown in the second alternative flow in the diagram.
Additionally, filtering by restaurant name is supported via the search bar; this option is omitted from the diagram for simplicity.

#figure(
  image("../resources/FindingRestaurantUCScenario.png", width: 95%),
  caption: [Use case scenario: finding a restaurant.],
) <fig:ucs-finding-restaurant>


== UC2: Creating an Order

This scenario describes the typical ordering flow, including restaurant selection, item addition to the cart, quantity adjustment, checkout, and a mocked payment via the payment provider.
In the main flow, the restaurant menu is browsed, selected items are added to the cart, the order is reviewed on the cart page, and checkout is initiated.
During checkout, payment details are provided (currently mocked) and the order details are confirmed.
If the customer is not authenticated, log in or register is required before proceeding to checkout,
which is not shown in the diagram for simplicity (it is assumed the customer is logged in in the main flow).
- In the first alternative flow, menu items are viewed on the menu-item detail page, and items are added to the cart from that page.
- In the second alternative flow, the order is modified in the cart by adjusting item quantities or removing items prior to checkout.
- In the third alternative flow, a special note (instructions) is added to the order during checkout.
- In the final alternative flow, unavailability of an item prior to order confirmation (e.g., due to stock issues) is handled by prompting for order adjustments before confirmation can proceed.

#figure(
  image("../resources/CreatingAnOrderUCScenario.png", width: 95%),
  caption: [Use case scenario: creating an order.],
) <fig:ucs-creating-order>

== UC3: Order Management

This scenario outlines the process of managing incoming orders from the perspective of restaurant staff.

#figure(
  image("../resources/OrderManagementUCScenario.png", width: 95%),
  caption: [Use case scenario: order management (draft).],
) <fig:ucs-order-management>
