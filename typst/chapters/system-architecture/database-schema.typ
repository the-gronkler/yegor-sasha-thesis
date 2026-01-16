#import "../../config.typ": code_example, source_code_link

== Database Schema and Data Persistence Layer

The data persistence layer is the foundation of the system's reliability and integrity. It is architected around a normalized relational schema hosted in MariaDB, designed to support both high-throughput transactional processing (OLTP) for ordering and complex analytical queries for restaurant discovery.

#figure(
  image("../../resources/er-diagram.png"),
  caption: [Entity-Relationship Diagram of the Restaurant Ordering System],
) <fig:er-diagram>

=== Core Schema Design
The database schema follows the Third Normal Form (3NF) to minimize data redundancy and ensure referential integrity. As illustrated in @fig:er-diagram, the architecture defines several key entity clusters:
- *User Management*: The `users` table handles authentication credentials, while the `customers` and `employees` tables serve as polymorphic-like extensions to store role-specific profiles. This separation ensures that an employee's access rights are structurally distinct from a customer's personal data.
- *Restaurant Catalog*: The `restaurants` table acts as the central node for the content graph, linking to `menu_items`, `reviews`, and `orders`. Crucially, it stores the geospatial coordinates (`latitude`, `longitude`) as double-precision floating-point numbers, optimized for spatial indexing.
- *Order Processing*: The `orders` and `order_items` tables encapsulate the transactional lifecycle. The schema enforces strict foreign key constraints (cascading updates but restricting deletes) to prevent the accidental loss of historical financial data.
- *Social Graph*: The `favorite_restaurants` table implements a many-to-many relationship betweens customers and restaurants, utilizing a pivot structure that allows for efficient existing checks (e.g., "Is this restaurant favorited by the current user?").

=== Indexing Strategy
To ensure sub-millisecond query response times, a rigorous indexing strategy has been applied, targeting specific access patterns identified during the functional analysis phases.

- *Primary Keys*: All tables utilize auto-incrementing `BIGINT` primary keys, ensuring predictable B-Tree index performance and efficient JOIN operations.
- *Foreign Keys*: All foreign key columns (e.g., `restaurant_id` on the `orders` table) are indexed to optimize relational lookups and enforce referential integrity checks without table scans.
- *Geospatial Indexing*: A critical architectural decision was the implementation of specific indices for location-based queries. The `restaurants` table includes individual B-Tree indices on the `latitude` and `longitude` columns.
  - *Rationale*: While R-Tree indices are often used for spatial data, MariaDB's query optimizer can efficiently utilize the intersection of two standard B-Tree indices (via the *Index Merge* optimization) for the "bounding box" queries used in the map view. This approach often outperforms R-Trees for simple point-in-rectangle lookups and simplifies maintenance.
- *Composite Indices*: Composite indices are employed on association tables. For instance, the `reviews` table enforces a composite unique index on `(customer_user_id, restaurant_id)` to ensure a user can review a restaurant only once, while simultaneously optimizing queries that check for existing reviews.

=== Spatial Data Architecture
The system handles spatial data (user locations and restaurant addresses) using a hybrid approach that balances precision with performance:
1. *Geometric Storage*: Location data is stored as raw coordinate pairs rather than proprietary geometry blobs. This ensures compatibility with standard JSON APIs and frontend mapping libraries (Leaflet, Mapbox) without complex serialization steps.
2. *Bounding Box Topology*: To identify restaurants within a given radius, the system creates a virtual "bounding box" (min/max latitude and longitude) around the user. This architectural pattern allows the database to filter 99% of irrelevant records using standard numeric comparisons (`WHERE latitude BETWEEN X AND Y`) before performing the computationally expensive exact-distance calculation.

=== Security and Isolation
Data security is enforced at the schema and application levels through:
- *Attribute Protection*: The usage of the `$fillable` property in Eloquent models protects against Mass Assignment Vulnerabilities, ensuring that sensitive fields (like internal flags or timestamps) cannot be modified via user input forms.
