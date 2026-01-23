#import "../../config.typ": code_example, source_code_link

== Data Persistence (Database)

The system persists domain state in a relational database. The persistence layer is designed to prioritise data integrity and data access performance through explicit constraints and predictable query patterns.

#figure(
  image("../../resources/er-diagram.png", width: 100%),
  caption: [Entity-Relationship Diagram (ERD)],
) <fig:er-diagram>

=== Schema Overview and Integrity
The Entity-Relationship Diagram in @fig:er-diagram depicts the the database schema used in the application. The schema follows the Third Normal Form to reduce redundancy and enforce integrity via primary keys, foreign keys, and uniqueness constraints.

The Entity-Relationship Diagram uses crow's foot notation to represent cardinality and participation constraints. Entities are represented as boxes with their attributes listed, while relationships are depicted as lines connecting the entities, annotated with symbols indicating the nature of the relationship (one-to-one, one-to-many, many-to-many). Vertabelo was used to generate the diagram#footnote[https://www.vertabelo.com/].

This goal of this section is to provide an overview of the schema structure and the rationale behind key design decisions. Exact details of the schema can be found in the ERD, and they will be further covered in the relevant section of the implementation chapter.

The section is structured to describe each logical entity cluster highlihted in the ERD, covering their purpose, relationships, and any notable design considerations.


==== User and Role Data

User accounts are represented by a base user entity in order to reduce mixing of concerns and to keep access patterns explicit. This also enables the application to make use of Laravel's built-in User model class to handle authentication and session management features.

The user enity is treated as abstract, with a disjoint inheritance hieracrchy implemented to represent Customer and Employee roles. Role-specific attributes are stored in dedicated tables, linked to the base user entity through one-to-one relationships.

==== Restaurant and Menu

Restauraunts are represented by a dedicated entity, linked to their menu and employees.

Employees are associated with a single restaurant through a many-to-one relationship, reflecting the organisational structure.

The menu is represented with a central Menu Items entity, linked to food type (in other words - menu category) in a one-to-many relationship (1 food-type -> many restauraunts). and with a simple many to many relationship to Alergens.


==== Images
Notably, the  menu items entity is not directly associated with Restaurants, instead inheriting the relationship through the food type entity. This design choice adheres to the Third Normal Form and simplifies the schema by avoiding redundant relationships.

Additionally, both restaurants and menu items have a one-to-many relationship with Images table, enabling storing multiple images for both entities, while avoiding reduncancy. The image can have both relationships.

Whether an image is 'primary'#footnote[A primary image is the main image representing the entity in listings and overviews] for menu item or restaurant is determined by a boolean attributes on the image entity, `is_image_primary_for_menu_item` and `is_image_primary_for_restaurant` respectively.

The image entity does not store the image directly, instead storing a link to the image resource in the applications blob storage. Although MariaDB supports BLOB data types, storing images directly in the database can lead to performance issues and increased complexity in backup and replication processes. By storing only the link to the image resource, the application can leverage dedicated blob storage solutions that are optimized for handling large binary files, improving overall system performance and scalability.

==== Reviews
Restaurants are associated with customers through a 'Review' joining table, which in addition to the foreign keys also stores review-specific attributes such as rating, comments, as well as a one-to-many relationship to the review_images table. This design allows customers to provide feedback on multiple restaurants while ensuring that each review is uniquely tied to a specific customer-restaurant pair.


==== Ordering and Status Tracking
Orders are represented by the *Orders* table, linked to customers with a `1-*` relationship and to `*-*` to menu items. The joining table *Order Items* captures the many-to-many relationship between orders and menu items, also storing the quantity of each menu item in the order.

Order status is tracked using a dedicated *Order Statuses* dictionary table, ensuring consistent status values and supporting future extensibility. The statuses include lifecycle stages such as "In Cart", "Placed", "Accepted", "Preparing", "Ready", "Cancelled", and "Fulfilled".

Notably, the user's cart is not modeled as a separate table but as an order record with the "In Cart" status. This design choice simplifies the schema by avoiding duplication and reduces write operations when transitioning from cart to placed order, as it merely updates the status and sets the time_placed timestamp.


=== Indexing and Constraint Strategy
Indexing and constraints are applied to match the dominant access patterns while preserving integrity.

*Primary keys*: Surrogate primary keys provide stable identifiers and predictable join behaviour.

*Foreign keys*: Relationship columns are indexed to support joins and to keep integrity checks efficient.

*Uniqueness constraints*: Composite uniqueness is used where the domain requires a single relationship instance (for example,
preventing duplicate reviews for the same author-target pair).

*Geolocation support*: Dedicated indices support location-based filtering on coordinate fields; the architectural intent is to keep proximity queries bounded and consistent.



// === Spatial Data Representation and Filtering
// Spatial information is stored as latitude/longitude coordinate fields on restaurant entities. Proximity filtering is performed using a bounding-box prefilter (min/max latitude and longitude) to reduce the candidate set before any more precise distance calculation is applied. This approach maintains interoperability with JSON-based APIs while keeping the database query structure straightforward.

// == Data Access (ORM)

// === ORM as the Primary Access Layer
// Laravel's default ORM (Eloquent) provides the primary data access abstraction for standard read and write operations#footnote[#source_code_link("composer.json")]. Models represent persisted entities and relationships, enabling consistent composition of queries and updates across the application. This layer supports development velocity and helps keep business logic independent from raw SQL.

// === Relationship Loading Strategy
// Relationship loading is treated as an architectural concern to avoid inefficient query patterns.

// *Lazy loading* is used when related data is optional and not always required by a request.

// *Eager loading* is used when pages require consistent traversal of relationships, reducing the risk of N+1 query patterns.

// === Hybrid Data Access for Performance-Critical Reads
// The architecture permits bypassing full ORM hydration for selected read operations where query complexity or result volume makes ORM materialisation undesirable. In these scenarios, Laravel's Query Builder or raw SQL can be used to keep computation close to the database, while preserving explicit boundaries and testability.

// #figure(
//   table(
//     columns: 4,
//     align: (left, left, left, left),
//     [Strategy], [Best fit], [Primary risks], [Mitigations / guardrails],

//     [Eloquent models],
//     [Transactional CRUD and relationship-centric domain workflows],
//     [N+1 queries and hydration overhead for large result sets],
//     [Use eager loading intentionally; select only required attributes; keep controllers thin],

//     [Query Builder],
//     [Complex reads that require joins, grouping, or aggregates without full model behaviour],
//     [Loss of model-level invariants and accidental duplication of query logic],
//     [Centralise queries in a dedicated service/action; document expected result shape; cover with tests],

//     [Raw SQL],
//     [Hot paths requiring precise control over SQL and execution characteristics],
//     [Maintainability and security risks (including incorrect parameter handling)],
//     [Restrict usage to justified cases; use parameter binding; isolate SQL in a single module; add regression tests],
//   ),
//   caption: [Decision Table for Selecting a Data Access Strategy],
// ) <tab:data-access-decision>

// This decision table provides a consistent basis for selecting a data access strategy while keeping responsibilities separated: standard operations remain ORM-driven, while exceptional query paths are isolated and verified.


