= Use Case Diagram

This chapter presents the system's use cases from the perspective of its primary actors. The use case diagram provides a high-level view of the main functionalities described in the #link(<chap:functional-requirements>)[Functional Requirements] chapter and serves as a bridge between requirements and technical design.

@fig:ucd-full illustrates the comprehensive set of interactions for both customers and restaurant staff. For clarity, the diagram is further decomposed into two focused views: @fig:ucd-customer, which highlights customer-facing operations, and @fig:ucd-restaurant, which details restaurant management workflows.

#figure(
  image("../resources/RestaurantFinderUCD_full.png", width: 90%),
  caption: [Overall use case diagram of the system (customer- and restaurant-facing features).],
) <fig:ucd-full>

== Actors and Roles

The system identifies several primary actors, each with distinct privileges and responsibilities:

- *Unregistered Customer*: A guest user restricted to read-only discovery features, specifically viewing the map and selecting restaurants to view details.
- *Customer*: A registered entity interacting with the system. This actor inherits the capabilities of the Unregistered Customer and gains access to transactional features such as ordering, reviewing, and profile management.
- *Restaurant Worker*: A staff member responsible for day-to-day operations, including order processing and menu availability updates.
- *Restaurant Admin*: A managerial role inheriting from the Restaurant Worker. This actor possesses elevated privileges for managing restaurant details, menu composition, and staff accounts.
- *Payment System*: An external service (transaction processing is mocked in the current scope) that interacts with the checkout process.
- *System Actions*: Automated triggers initiated by domain events, such as new order notifications and real-time rating recalculation.

== Customer-Centric Functionality

#figure(
  image("../resources/RestaurantFinderUCD_customer.png", width: 100%),
  caption: [Use case diagram focused on customer interactions.],
) <fig:ucd-customer>

As depicted in @fig:ucd-customer, customer interactions are grouped into distinct functional modules:

=== Account Creation and User Methods
Entry into the full system requires authentication via the "Account creation" module, comprising registration and login. Once logged in, the "User methods" module enables the Customer to manage their profile and view current orders and history.

=== Map Discovery
Discovery features available to the Unregistered Customer include viewing the map, applying filters, and selecting restaurants. The Customer actor extends these capabilities with personalized features, specifically "Add to favourites" and "Leave review". These actions are explicitly protected and accessible only to authenticated users.

=== Order Management
The "Order" module encapsulates the detailed purchasing workflow. Key interactions include:
- *Cart Management*: The "View Cart" use case serves as a central hub, extended by actions to add items, remove items, or modify item quantities.
- *Checkout*: The "Checkout" process includes the "Pay" use case, enforcing payment as a mandatory step for order completion.


== Restaurant Management Functionality

#figure(
  image("../resources/RestaurantFinderUCD_restaurant.png", width: 90%),
  caption: [Use case diagram focused on restaurant staff interactions.],
) <fig:ucd-restaurant>

The restaurant-side operations, shown in @fig:ucd-restaurant, are divided between operational duties and administrative management.

=== Worker Duties
Restaurant Workers interact with the "Worker duties" module to manage the immediate flow of business. This includes updating the status of active orders and flagging specific menu items as available or unavailable based on inventory.

=== Restaurant Admin Management
The "Restaurant admin management" module provides configuration tools for the Restaurant Admin. This includes editing the restaurant's profile, managing the menu structure (adding or editing items), and overseeing the workforce by adding or removing Worker accounts.

=== System Actions
The diagram also captures automated system behaviors:
- *Order Notifications*: The system notifies workers to accept or decline when a new order is placed.
- *Rating Updates*: Restaurant ratings are recalculated in real time whenever a review is created, updated, or deleted. The recalculation computes the average of all associated review ratings and updates the restaurant's stored rating immediately.
