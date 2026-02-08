= Use Case Diagram

This chapter presents the system's use cases from the perspective of its primary actors. The use case diagram provides a high-level view of the main functionalities described in the #link(<chap:functional-requirements>)[Functional Requirements] chapter and serves as a bridge between requirements and technical design.

@fig:ucd-full illustrates the comprehensive set of interactions for both customers and restaurant staff. For clarity, the diagram is further decomposed into two focused views: @fig:ucd-customer, which highlights customer-facing operations, and @fig:ucd-restaurant, which details restaurant management workflows.

#figure(
  image("../resources/RestaurantFinderUCD_full.png", width: 90%),
  caption: [Overall use case diagram of the system (customer- and restaurant-facing features).],
) <fig:ucd-full>

== Actors and Roles

The system identifies several primary actors:

- *Unregistered Customer*: Guest with read-only discovery access (map and restaurant details).
- *Customer*: Registered user with full transactional access (ordering, reviewing, profile management).
- *Restaurant Worker*: Staff managing daily operations (order processing, inventory updates).
- *Restaurant Admin*: Manager with elevated privileges (restaurant configuration, menu management, staff accounts).
- *Payment System*: External service for transaction processing (mocked in current implementation).
- *System Actions*: Automated triggers for notifications and updates.

== Customer-Centric Functionality

#figure(
  image("../resources/RestaurantFinderUCD_customer.png", width: 100%),
  caption: [Use case diagram focused on customer interactions.],
) <fig:ucd-customer>

As depicted in @fig:ucd-customer, customer interactions encompass account management (registration/login), map-based restaurant discovery with filters, personalized features (favorites and reviews), and order management with cart operations and checkout.


== Restaurant Management Functionality

#figure(
  image("../resources/RestaurantFinderUCD_restaurant.png", width: 90%),
  caption: [Use case diagram focused on restaurant staff interactions.],
) <fig:ucd-restaurant>

The restaurant-side operations, shown in @fig:ucd-restaurant, enable Workers to manage order status and inventory, provide Admins with tools for restaurant and menu configuration, and automate system notifications and rating updates.
