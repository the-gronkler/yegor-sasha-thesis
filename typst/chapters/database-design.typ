#import "../config.typ": code_example, source_code_link

= Database Design <database-design>

The database design constitutes the structural backbone of the platform, determining how domain entities are modeled, stored, and interconnected to fulfill the system's functional requirements. This chapter presents the logical and physical organization of the data persistence layer, which is built upon a relational model to ensure strong consistency and referential integrity.

The design philosophy prioritizes normalization to eliminate data redundancy, coupled with a strategic indexing approach to support the application's dominant query patterns, particularly those involving geospatial filtering and complex relationship traversals. The following sections detail the schematic representation of the system through the Entity-Relationship Diagram (ERD) and provide an in-depth analysis of the key entity clusters and their architectural rationale.

=== Schema Overview and Integrity

#figure(
  image("../resources/er-diagram.png", width: 100%),
  caption: [Entity-Relationship Diagram (ERD)],
) <fig:er-diagram>

The Entity-Relationship Diagram in @fig:er-diagram depicts the database schema used in the application. The schema follows the Third Normal Form @Codd3NF1971 to reduce redundancy and enforce integrity via primary keys, foreign keys, and uniqueness constraints.

The Entity-Relationship Diagram uses crow's foot notation @EverestCrowsFoot1976 to represent cardinality and participation constraints. Entities are represented as boxes with their attributes listed, while relationships are depicted as lines connecting the entities, annotated with symbols indicating the nature of the relationship (one-to-one, one-to-many, many-to-many). Redgate Data Modeler was used to generate the diagram#footnote[https://datamodeler.redgate-platform.com/] (formerly known as Vertabelo).

*Diagram Scope*: For clarity and focus on the business domain, the ERD intentionally omits framework-level infrastructure tables (sessions, cache, job queues, password resets) and standard audit timestamp columns (`created_at`, `updated_at`) present on all entities. These system-level concerns are handled by the application framework and do not impact the logical domain model. The complete physical schema, including all system columns and infrastructure tables, is defined through database migrations detailed in the implementation chapter.

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
To support rich media while maintaining schema simplicity, the system utilizes a unified `images` table linked via explicit nullable foreign keys (`restaurant_id` and `menu_item_id`). Unlike polymorphic associations (which rely on string-based `model_type` columns and cannot enforce database-level referential integrity), explicit foreign keys allow the database to strictly enforce valid relationships. The foreign keys use `ON DELETE SET NULL` behavior, preserving image records even when their associated entity is deleted, which allows for potential orphan cleanup or administrative review.

Boolean flags (`is_primary_for_*`) are used to designate the main display image for lists and thumbnails. Additionally, menu items maintain a reverse foreign key (`image_id`) pointing back to the images table, establishing a bidirectional relationship where a menu item can designate a specific image as its primary representation. This dual-reference strategy supports both gallery-style image collections (multiple images per menu item via `images.menu_item_id`) and explicit primary image designation (single featured image via `menu_items.image_id`).

The table stores only the resource path (e.g., `restaurants/1/cover.jpg`), delegating the actual binary storage to an external object storage service to keep the database lightweight and performant.

==== Reviews
Restaurants are associated with customers through a 'Review' joining table, which in addition to the foreign keys also stores review-specific attributes such as rating, comments, as well as a one-to-many relationship to the review_images table. This design allows customers to provide feedback on multiple restaurants while ensuring that each review is uniquely tied to a specific customer-restaurant pair through a composite uniqueness constraint on `(customer_user_id, restaurant_id)`.

*Primary Key Strategy*: The review entity employs a surrogate primary key (`id`) rather than using the natural composite key `(customer_user_id, restaurant_id)` as the primary identifier. While the composite key uniquely identifies each review, using a dedicated surrogate key simplifies foreign key relationships, particularly for the `review_images` table. With a single-column primary key, `review_images` requires only one foreign key column (`review_id`) rather than propagating the composite key through multiple columns. This approach reduces join complexity and improves query readability. The natural uniqueness constraint is still enforced at the database level to prevent duplicate reviews.

The `rating` column on the `restaurants` table stores the aggregate average of all associated review ratings. This value is recalculated whenever a review is created, updated, or deleted, ensuring that the displayed rating always reflects the current state of customer feedback. The review count is derived at query time using the reviews relationship rather than being stored as a denormalized column.

==== Orders
Orders are represented by the *Orders* table, linked to customers with a one-to-many relationship and having a many-to-many relationship to menu items. The joining table *Order Items* captures this many-to-many relationship, also storing the quantity of each menu item in the order.


Order status is tracked using a dedicated *Order Statuses* dictionary table, ensuring consistent status values and supporting future extensibility. The statuses include lifecycle stages: "In Cart", "Placed", "Accepted", "Declined", "Preparing", "Ready", "Cancelled", and "Fulfilled".

Notably, the user's cart is not modeled as a separate table but as an order record with the "In Cart" status. This design choice simplifies the schema by avoiding duplication and reduces write operations when transitioning from cart to placed order, as it merely updates the status and sets the time_placed timestamp.

=== Spatial Data Representation
The database schema handles geospatial data using standard double-precision floating-point columns for `latitude` and `longitude` within the `restaurants` table, rather than specialized geometric data types. This design prioritizes portability and eliminates dependencies on specific GIS database extensions. Usage of standard primitive types allows for the efficient execution of bounding-box queries directly through standard B-tree indices @BayerMcCreightBTree1972 on the coordinate columns, ensuring that spatial lookups remain performant without introducing the complexity of spatial extension overhead.

=== System Columns and Infrastructure Tables

==== Audit Timestamps
All domain entities include standard audit timestamp columns (`created_at` and `updated_at`) that automatically track record creation and modification times. These system-level columns are managed transparently by the framework's ORM layer and require no explicit application logic. While omitted from the logical ERD for visual clarity, these timestamps are physically present in all tables and serve multiple purposes: supporting temporal queries, providing audit trails for regulatory compliance, and enabling cache invalidation strategies. The timestamp columns are nullable to accommodate edge cases in data migration scenarios.

==== Framework Infrastructure Tables
The physical database schema includes several framework-managed tables that support application infrastructure but do not represent business domain entities. These tables are intentionally excluded from the ERD as they constitute implementation details rather than logical design decisions:

- *Sessions*: Server-side session storage for stateful authentication
- *Cache and Cache Locks*: Application-level caching layer with distributed locking support
- *Jobs, Job Batches, and Failed Jobs*: Asynchronous task queue management for background processing (email notifications, order status updates, image processing)
- *Password Reset Tokens*: Temporary token storage for secure password recovery flows

These infrastructure tables are provisioned through framework migrations and operate independently of the business domain model. Their schema and behavior are dictated by framework conventions, ensuring compatibility with the broader ecosystem of libraries and tools that integrate with the framework's job queue, cache, and authentication systems.

=== Indexing and Constraint Strategy
Indexing and constraints are applied to match the dominant access patterns while preserving integrity.
*Primary keys*: Surrogate primary keys provide stable identifiers and predictable join behavior.

*Foreign keys*: Relationship columns are indexed to support joins and to keep integrity checks efficient.

*Uniqueness constraints*: Composite uniqueness is used where the domain requires a single relationship instance (for example,
preventing duplicate reviews for the same author-target pair).

*Geolocation support*: Dedicated indices support location-based filtering on coordinate fields; the architectural intent is to keep proximity queries bounded and consistent.
