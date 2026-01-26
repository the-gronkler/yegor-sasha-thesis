#import "../template.typ": use-case-scenario

= Use Case Scenarios

This chapter briefly describes the main scenarios the system supports.
The scenarios complement the use case diagrams in the previous chapter by explaining typical user flows and key alternatives.

== UC1: Finding a Restaurant

The following scenario describes how a customer finds a restaurant using the map-based index page.
As @fig:ucs-finding-restaurant shows, the system does not require authentication to search for restaurants and view their details.

In the main flow, the customer locates restaurants via the map, selects a restaurant marker to display a brief overview, and opens the restaurant detail page for additional information.

If the customer does not grant geolocation permission, they search for restaurants on the map as the first alternative flow illustrates.
In the alternative geolocation flow, the user centers the map on a location of interest and identifies nearby restaurants using the "Search here" button.

Alternatively, the user can select a location directly on the map by clicking or entering coordinates (omitted for simplicity).
Customers can also identify restaurants via the collapsible list view rather than the map, as the second alternative flow shows.
Additionally, the search bar supports filtering by restaurant name; we omit this option from the table for simplicity.

#figure(
  use-case-scenario(
    title: "Finding a Restaurant UC Scenario",
    actor: "Hungry customer",
    purpose: "A customer wants to find a good restaurant according to their needs.",
    assumptions: "1. Different restaurants with appropriate data exist in the system.",
    preconditions: [1. The restaurant has coordinates set in the system, so users can select it on the map.
      2. The selected restaurant has at least one item available in the menu.],
    initiating-event: "The user opens the website, and the system redirects them to the index (Explore) page.",
    basic-flow: [
      1. The system prompts the customer to grant geolocation permission; the customer clicks "Allow". \
      2. The map moves to the user's device geolocation. \
      3. The customer expands the bottom navigation panel with the restaurant list. \
      4. The customer selects restaurants while checking their address, rating, and description. \
      5. The customer clicks "View details" on the selected restaurant.
    ],
    alternative-flow: [
      *The customer does not allow geolocation access* \
      - 1a1. The customer clicks "Block"/"No", so the system does not access their geolocation. \
      - 1a2. The customer navigates the map using "Search here" to find restaurants. \
      - 1a3. Continue to point 3. \
      *Browsing restaurants without the list (using only the map)* \
      - 3a1. The customer navigates the map using "Search here" to find restaurants. \
      - 3a2. Continue to point 4. \
      #h(1em) *Browsing restaurants using map filters* \
      #h(1em) - 3a2a1. The customer opens the top-right radius slider panel. \
      #h(1em) - 3a2a2. The customer changes the slider value to adjust the search radius. \
      #h(1em) - 3a2a3. Continue to point 4.
    ],
    postconditions: "The system redirects the customer to the menu page of the selected restaurant.",
  ),
  caption: [Use case scenario: finding a restaurant.],
) <fig:ucs-finding-restaurant>


== UC2: Creating an Order

This scenario describes the typical ordering flow, including restaurant selection, item addition to the cart, quantity adjustment, checkout, and a mocked payment via the payment provider.

In the main flow, the customer browses the restaurant menu, adds selected items to the cart, reviews the order on the cart page, and initiates checkout.

During checkout, the customer provides payment details (mocked for this implementation). and confirms the order details.

If the customer has not authenticated, they must log in or register before proceeding to checkout, which we do not show in the table for simplicity (we assume the customer has logged in in the main flow).

- In the first alternative flow, the customer views menu items on the menu-item detail page and adds items to the cart from that page.

- In the second alternative flow, the customer modifies the order in the cart by adjusting item quantities or removing items prior to checkout.

- In the third alternative flow, the customer adds a special note (instructions) to the order during checkout.
- In the final alternative flow, if an item becomes unavailable prior to order confirmation (e.g., due to stock issues), the system prompts the customer for order adjustments before confirmation can proceed.

#figure(
  use-case-scenario(
    title: "Creating an Order UC Scenario",
    actor: "Hungry customer",
    purpose: "A customer wants to order food from a specific restaurant.",
    assumptions: [1. The selected restaurant has items in its menu.
      2. The customer has registered and logged in to the system.],
    preconditions: [1. The selected restaurant has at least one menu item available.
      2. The customer has an empty cart in the selected restaurant.],
    initiating-event: "The customer opens the menu page of the selected restaurant.",
    basic-flow: [
      1. The customer browses menu categories and items to find ones to add to their cart. \
      2. The customer clicks "+" to add the desired quantity of an item. \
      3. The customer clicks "View order" at the bottom of the screen. \
      4. The customer reviews the cart with selected items and subtotal. \
      5. The customer clicks "Checkout [restaurant.name]" to proceed to payment. \
      6. The customer views order details and clicks "Pay [order.amount]".
    ],
    alternative-flow: [
      *The customer opens a menu item page to see details* \
      - 2a1. The customer clicks on a menu item to view its detail page. \
      - 2a2. The customer adds/removes items using "+" or "-" buttons. \
      - 2a3. The customer clicks the back arrow to return to the menu. \
      - 2a4. Continue to point 3. \
      *The customer changes item quantities or removes items* \
      - 4a1. The customer clicks "-" to reduce quantity or "Trash" to remove completely. \
      - 4a2. Continue to point 5. \
      *The customer adds a special note to the order* \
      - 4b1. The customer writes in the "Special Instructions" field. \
      - 4b2. The customer clicks "Save notes". \
      - 4b3. Continue to point 5. \
      *An item becomes unavailable during order creation* \
      - 5a1. The system prompts deletion of unavailable items; checkout becomes disabled. \
      - 5a2. The customer removes the unavailable item. \
      - 5a3. Continue to point 5.
    ],
    postconditions: "The system redirects the customer to the order page after successful payment.",
    font-size: 8.5pt,
    leading: 0.35em,
  ),
  caption: [Use case scenario: creating an order.],
) <fig:ucs-creating-order>

== UC3: Order Management

This scenario describes the order management workflow from the perspective of restaurant staff, including order acceptance, preparation tracking, and fulfillment.
As @fig:ucs-order-management shows, the system requires staff authentication to access the order management features.

In the main flow, the worker receives a notification about a new order, assigns it for preparation, updates the status through the preparation stages, and marks it as fulfilled once the customer receives it.
The system notifies the customer in real-time as the order status changes.

- In the first alternative flow, the worker declines the order before preparation begins (e.g., due to ingredient unavailability or capacity issues).

- In the second alternative flow, the worker cancels an already-accepted order if a problem occurs after preparation starts.

#figure(
  use-case-scenario(
    title: "Order Management UC Scenario",
    actor: "Restaurant worker",
    purpose: "A worker notices a newly created order in the system that they need to finalize.",
    assumptions: [1. The restaurant has received an order from a customer.
      2. The restaurant worker has registered and logged in to the system.],
    preconditions: "1. The restaurant worker account belongs to the restaurant that received an order.",
    initiating-event: "The worker notices a new order under the \"New Orders\" tab.",
    basic-flow: [
      1. The worker changes the order status to "Assigned" in the "Update status" field. \
      2. The restaurant worker prepares or assigns people to prepare the order. \
      3. The worker changes the order status to "Preparing". \
      4. Once prepared, the worker changes the order status to "Ready". \
      5. Once the customer receives the order, the worker changes the status to "Fulfilled".
    ],
    alternative-flow: [
      *The worker declines the order (e.g., ingredient problem)* \
      - 1a1. The worker changes the order status to "Declined". \
      - 1a2. The customer receives a notification showing the order as "Declined". \
      *The worker cancels the order (e.g., problem after acceptance)* \
      - 4a1. The worker changes the order status to "Cancelled". \
      - 4a2. The customer receives a notification showing the order as "Cancelled".
    ],
    postconditions: "The customer receives the order and the status changes to \"Fulfilled\".",
  ),
  caption: [Use case scenario: order management.],
) <fig:ucs-order-management>
