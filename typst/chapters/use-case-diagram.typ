= Use Case Diagram

This chapter presents the system's use cases from the perspective of its primary actors. The diagram provides a high-level view of the main functionalities described in Chapter "Functional Requirements" and serves as a bridge between requirements and later technical design.

#figure(
  image("../resources/RestaurantFinderUCD_full.png", width: 100%),
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

In @fig:ucd-full, the customer can discover restaurants on the map, view details, and place orders. The ordering process includes cart management, checkout, and payment through an external payment provider.

On the restaurant side (@fig:ucd-restaurant), staff can manage incoming orders and mark menu items as available or unavailable. Administrative functions include maintaining restaurant data, menus, and staff accounts.
