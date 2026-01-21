= Use Case Scenarios

This chapter briefly describes the main scenarios supported by the system.
 The scenarios complement the use case diagrams in the previous chapter by explaining typical user flows and key alternatives.

== UC1: Finding a Restaurant

The following scenario describes how a customer can find a restaurant using the map-based index page.
As it can be seen from the digram assumptions (@fig:ucs-finding-restaurant), the customer does not need to be logged in to search for restaurants and view their details in order to find a restaurant of interest.
In the main flow, the customer can use the map to locate restaurants in their area, click on a restaurant marker to view a brief overview, and then navigate to the restaurant's detail page for more information.
However, if the customer does not want to give the system access to their location, they can search for the restaurants on the map as displayed in the first alternative flow.
 The alternative geolocation flow allows the customer to manually enter a location (e.g., city or address) to center the map and find nearby restaurants, or click to select a location on the map (was excluded from the scenario for simplicity).
Also it should be possible to find restaurants using the collapsible list view instead of the map, as indicated in the second alternative flow in the diagram.
 In addition to that, the customer can use the search bar to filter restaurants by name, but this is not explicitly shown in the diagram for simplicity.

#figure(
  image("../resources/FindingRestaurantUCScenario.png", width: 95%),
  caption: [Use case scenario: finding a restaurant.],
) <fig:ucs-finding-restaurant>


== UC2: Creating an Order

This scenario covers the typical ordering flow: selecting a restaurant, adding items to the cart, adjusting quantities, proceeding to checkout, and paying via the payment provider.
In the main flow, the customer browses the restaurant's menu, adds desired items to the cart, reviews the order in the cart page, and then proceeds to checkout where they provide payment details (which is mocked right now) and confirms all the details of the order.
If the customer is not logged in, they are prompted to log in or register before proceeding to checkout, which is not shown in the diagram for simplicity (we assume the customer is logged in in the main flow).
- The first alternative flow describes how the customer is able to view the menu items separately in the menu-item detail page, where they can also add items to the cart.
- Then, the second alternative flow illustrates how the customer can modify the order in the cart by adjusting item quantities or removing items before proceeding to checkout.
- The third alternative flow shows that the customer can add a special note (instructions) to the order during checkout.
- Finally, the last alternative flow indicates how the system hadles a case where an item in the cart becomes unavailable before the order is confirmed (e.g., due to stock issues); in this case, the customer is prompted to adjust their order accordingly.

#figure(
  image("../resources/CreatingAnOrderUCScenario.png", width: 95%),
  caption: [Use case scenario: creating an order.],
) <fig:ucs-creating-order>

== UC3: Order Management

*TODO: Finalize this scenario description and align it with the implemented order lifecycle (e.g., accept/decline, preparing, ready, completed/cancelled).*

#figure(
  image("../resources/OrderManagementUCScenario.png", width: 95%),
  caption: [Use case scenario: order management (draft).],
) <fig:ucs-order-management>
