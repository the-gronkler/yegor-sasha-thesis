= Use Case Diagram

This chapter presents the system's use cases from the perspective of its primary actors.
 The diagram provides a high-level view of the main functionalities described in Chapter "Functional Requirements" and serves as a bridge between requirements and later technical design.

Below, in @fig:ucd-full, you can see the overall use case diagram illustrating interactions for both customers and restaurant staff.
 We have decided that we would split the diagram into two subsequent diagrams (@fig:ucd-customer and @fig:ucd-restaurant) in order to break down the use cases further,
  focusing on customer and restaurant staff interactions, respectively.

In @fig:ucd-customer, the customer can discover restaurants on the map, view details, and place orders.
 The ordering process includes cart management, checkout, and payment through an external payment provider (currently mocking the payment provider).
  Also it illustrates user account management features like registration, login, and profile updates.

On the restaurant side (@fig:ucd-restaurant), staff can manage incoming orders and mark menu items as available or unavailable.
 Administrative functions include maintaining restaurant data, menus, and staff accounts.

#figure(
  image("../resources/RestaurantFinderUCD_full.png", width: 90%),
  caption: [Overall use case diagram of the system (customer- and restaurant-facing features).],
) <fig:ucd-full>

#figure(
  image("../resources/RestaurantFinderUCD_customer.png", width: 100%),
  caption: [Use case diagram focused on customer interactions.],
) <fig:ucd-customer>

#figure(
  image("../resources/RestaurantFinderUCD_restaurant.png", width: 100%),
  caption: [Use case diagram focused on restaurant staff interactions.],
) <fig:ucd-restaurant>


The images above demonstrate the main functionalities and user interactions within the restaurant ordering system,
 providing a clear overview of how different actors engage with the application.
