#import "../config.typ": code_example, source_code_link

= Database Design

The database design constitutes the structural backbone of the platform, determining how domain entities are modeled, stored, and interconnected to fulfill the system's functional requirements. This chapter presents the logical and physical organization of the data persistence layer, which is built upon a relational model to ensure strong consistency and referential integrity.

The design philosophy prioritizes normalization to eliminate data redundancy, coupled with a strategic indexing approach to support the application's dominant query patterns, particularly those involving geospatial filtering and complex relationship traversals. The following sections detail the schematic representation of the system through the Entity-Relationship Diagram (ERD) and provide an in-depth analysis of the key entity clusters and their architectural rationale.

=== Schema Overview and Integrity

#figure(
  image("../resources/er-diagram.png", width: 100%),
  caption: [Entity-Relationship Diagram (ERD)],
) <fig:er-diagram>

The Entity-Relationship Diagram in @fig:er-diagram depicts the database schema used in the application. The schema follows the Third Normal Form to reduce redundancy and enforce integrity via primary keys, foreign keys, and uniqueness constraints.

The Entity-Relationship Diagram uses crow's foot notation to represent cardinality and participation constraints. Entities are represented as boxes with their attributes listed, while relationships are depicted as lines connecting the entities, annotated with symbols indicating the nature of the relationship (one-to-one, one-to-many, many-to-many). Vertabelo was used to generate the diagram#footnote[https://www.vertabelo.com/].

The goal of this section is to provide an overview of the schema structure and the rationale behind key design decisions. Exact details of the schema can be found in the ERD, and they will be further covered in the relevant section of the implementation chapter.

The section is structured to describe each logical entity cluster highlighted in the ERD, covering their purpose, relationships, and any notable design considerations.


==== User and Role Data

User accounts are implemented using a profile-based strategy to separate authentication credentials from role-specific data. The `users` table serves as the primary authentication principal (handling email, password, and session state), while role details are normalized into distinct `customers` and `employees` tables.

The user entity is treated as abstract, with a disjoint inheritance hierarchy implemented to represent Customer and Employee roles. Role-specific attributes are stored in dedicated tables, linked to the base user entity through one-to-one relationships.

==== Restaurant and Menu

The restaurant entity serves as the root aggregate for the catalog. Employees are associated with a single restaurant through a many-to-one relationship (`restaurant_id`), enforcing the organizational hierarchy.

The menu structure employs a hierarchical categorization strategy. A Restaurant possesses multiple `FoodTypes` (categories), which in turn contain multiple `MenuItems`.

*Cardinality*: 1 Restaurant $->$ Many Food Types $->$ Many Menu Items.

*Normalization*: Menu items are not directly linked to the restaurant; they inherit this association transitively through their Food Type. This design strictly adheres to the Third Normal Form, eliminating update anomalies where a category's restaurant association might contradict its items'.

==== Images
To support rich media while maintaining schema simplicity, the system utilizes a unified `images` table linked via explicit nullable foreign keys (`restaurant_id` and `menu_item_id`). Unlike polymorphic associations (which rely on string-based `model_type` columns and cannot enforce database-level referential integrity), explicit foreign keys allow the database to strictly enforce valid relationships and support `ON DELETE CASCADE` actions.

Boolean flags (`is_primary_for_*`) are used to designate the main display image for lists and thumbnails. The table stores only the resource path (e.g., `restaurants/1/cover.jpg`), delegating the actual binary storage to an external object storage service to keep the database lightweight and performant.

==== Reviews
Restaurants are associated with customers through a 'Review' joining table, which in addition to the foreign keys also stores review-specific attributes such as rating, comments, as well as a one-to-many relationship to the review_images table. This design allows customers to provide feedback on multiple restaurants while ensuring that each review is uniquely tied to a specific customer-restaurant pair.

==== Orders
Orders are represented by the *Orders* table, linked to customers with a `1-*` relationship and having a many-to-many (`*-*`) relationship to menu items. The joining table *Order Items* captures the many-to-many relationship between orders and menu items, also storing the quantity of each menu item in the order.
Orders are represented by the *Orders* table, linked to customers with a `1-*` relationship and to `*-*` to menu items. The joining table *Order Items* captures the many-to-many relationship between orders and menu items, also storing the quantity of each menu item in the order.

Order status is tracked using a dedicated *Order Statuses* dictionary table, ensuring consistent status values and supporting future extensibility. The statuses include lifecycle stages such as "In Cart", "Placed", "Accepted", "Preparing", "Ready", "Cancelled", and "Fulfilled".

Notably, the user's cart is not modeled as a separate table but as an order record with the "In Cart" status. This design choice simplifies the schema by avoiding duplication and reduces write operations when transitioning from cart to placed order, as it merely updates the status and sets the time_placed timestamp.

=== Spatial Data Representation
The database schema handles geospatial data using standard double-precision floating-point columns for `latitude` and `longitude` within the `restaurants` table, rather than specialized geometric data types. This design prioritizes portability and eliminates dependencies on specific GIS database extensions. Usage of standard primitive types allows for the efficient execution of bounding-box queries directly through standard B-tree indices on the coordinate columns, ensuring that spatial lookups remain performant without introducing the complexity of spatial extension overhead.

=== Indexing and Constraint Strategy
Indexing and constraints are applied to match the dominant access patterns while preserving integrity.
*Primary keys*: Surrogate primary keys provide stable identifiers and predictable join behavior.

*Foreign keys*: Relationship columns are indexed to support joins and to keep integrity checks efficient.

*Uniqueness constraints*: Composite uniqueness is used where the domain requires a single relationship instance (for example,
preventing duplicate reviews for the same author-target pair).

*Geolocation support*: Dedicated indices support location-based filtering on coordinate fields; the architectural intent is to keep proximity queries bounded and consistent.
