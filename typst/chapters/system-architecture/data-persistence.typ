#import "../../config.typ": code_example, source_code_link

== Data Persistence (Database)

The system persists domain state in a relational database. The persistence layer is designed to prioritise data integrity and data access performance through explicit constraints and predictable query patterns.

#figure(
  image("../../resources/er-diagram.png", width: 100%),
  caption: [Entity-Relationship Diagram (ERD)],
) <fig:er-diagram>

=== Schema Overview and Integrity
The Entity-Relationship Diagram in @fig:er-diagram depicts the database schema used in the application. The schema follows the Third Normal Form to reduce redundancy and enforce integrity via primary keys, foreign keys, and uniqueness constraints.

The Entity-Relationship Diagram uses crow's foot notation to represent cardinality and participation constraints. Entities are represented as boxes with their attributes listed, while relationships are depicted as lines connecting the entities, annotated with symbols indicating the nature of the relationship (one-to-one, one-to-many, many-to-many). Vertabelo was used to generate the diagram#footnote[https://www.vertabelo.com/].

The goal of this section is to provide an overview of the schema structure and the rationale behind key design decisions. Exact details of the schema can be found in the ERD, and they will be further covered in the relevant section of the implementation chapter.

The section is structured to describe each logical entity cluster highlighted in the ERD, covering their purpose, relationships, and any notable design considerations.


==== User and Role Data

User accounts are represented by a base user entity in order to reduce mixing of concerns and to keep access patterns explicit. This also enables the application to make use of Laravel's built-in User model class to handle authentication and session management features.

The user entity is treated as abstract, with a disjoint inheritance hierarchy implemented to represent Customer and Employee roles. Role-specific attributes are stored in dedicated tables, linked to the base user entity through one-to-one relationships.

==== Restaurant and Menu

Restaurants are represented by a dedicated entity, linked to their menu and employees.

Employees are associated with a single restaurant through a many-to-one relationship, reflecting the organisational structure.

The menu is represented with a central Menu Items entity, linked to food type (in other words - menu category) in a one-to-many relationship (1 food-type -> many restaurants) and with a simple many to many relationship to Allergens.


==== Images
Notably, the  menu items entity is not directly associated with Restaurants, instead inheriting the relationship through the food type entity. This design choice adheres to the Third Normal Form and simplifies the schema by avoiding redundant relationships.

Additionally, both restaurants and menu items have a one-to-many relationship with Images table, enabling storing multiple images for both entities, while avoiding redundancy. The image can have both relationships.

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

== Data Access (ORM)

=== Persistence Strategy and Pattern Selection
An Object-Relational Mapping (ORM) layer abstracts the interaction between the application domain and the relational database. Each domain entity is represented by a corresponding model class that encapsulates both the data structure and the persistence logic.

This is an example of the Active Record design pattern, which was selected in favor the Repository pattern in order to adhere to the framework conventions. in Laravel, the Eloquent ORM natively implements the Active Record pattern, and combined with the framework's emphasis on convention over configuration, this approach streamlines development by reducing boilerplate code and leveraging built-in functionalities.

The ORM handles tasks such as query construction, relationship management, and lifecycle events, allowing developers to interact with the database using high-level abstractions rather than raw SQL.

=== Domain Modelling and Capabilities
The application's domain entities are defined within the `app/Models` directory#footnote[#source_code_link("app/Models")]. Each model class acts as a representation of a database entitiy and serves as the primary interface for data access. These models are not passive data transfer objects; they are responsible for enforcing data integrity, defining relationships, and encapsulating domain-specific query logic.

Key responsibilities of the Model layer include:

*CRUD Operations*: Providing high-level abstractions for creating, reading, updating, and deleting records without raw SQL.

*Relationship Management*: Defining the structural connections between entities (e.g., a Customer _has many_ Orders).

*Eager Loading*: optimizing data retrieval performance by pre-loading associated entities (e.g., loading `customer` with `User`).

*Query Scopes*: Encapsulating reusable filter logic to keep controllers and services free of raw query construction.

*Computed Attributes*: Providing dynamic accessors for values derived from persistent state.

*Lifecycle Hooks*: Triggering domain events in response to state transitions (Create, Update, Delete).

*Timestamps*: Automatically managing audit metadata (`created_at`, `updated_at`) for all entities.

=== Schema Definition and Version Control
The database structure is defined programmatically through migration files. These migrations serve as version control for the database schema, allowing the architecture to evolve incrementally and reproducibly. By defining the schema in code - including table definitions, index creation, and foreign key constraints - the system ensures that the development, testing, and production environments remain strictly synchronized. Database seeding logic, located in the #source_code_link("database/seeders") directory, complements this by populating the schema with inherent static data (such as dictionary tables for Order Statuses) and test fixtures.


=== Query Abstraction and Semantic Scopes
To maintain separation between domain intent and storage mechanics, the architecture encapsulates complex retrieval logic within reusable query scopes. These are implemented as explicit methods within the model class (prefixed with 'scope'), allowing complex constraints to be invoked as fluent method calls.

This pattern prevents the leakage of raw SQL or database-specific syntax (such as spatial function calls) into the application layer. Instead, models expose a semantic API for filtering and retrieval that aligns with business language (e.g., proximity constraints or availability checks). This abstraction permits the underlying database implementation - such as the specific choice of geometric algorithms - to evolve without necessitating changes to the consuming controllers or services.

=== Virtual State and Accessors
The ORM acts as a transformation layer that presents data in a format optimized for domain logic rather than storage efficiency. "Virtual" attributes, which exist on the model interface but do not correspond to physical database columns, are employed to derive state dynamically. This allows the system to expose computed concepts - such as order totals derived from line item relations - as intrinsic properties of the entity interactions#footnote[#source_code_link("app/Models/Order.php")]. This design centralizes calculation logic, preventing the duplication of critical business formulas across different views or API endpoints.

=== Reactive Persistence and Event integration
The persistence layer serves as the catalyst for the system's event-driven architecture. State changes within the ORM are intimately tied to the application's event bus, transforming database transactions into observable system-wide occurrences. By dispatching domain events during the lifecycle of an entity (such as creation or status updates), the ORM decouples the core persistence logic from side effects like notifications or real-time broadcasting. This ensures that the system reacts consistently to state changes regardless of the trigger source#footnote[#source_code_link("app/Models/Order.php")].

=== Handling Many-to-Many Relationships
The architecture employs a bifurcated strategy for modeling many-to-many associations, distinguishing between "stateless" linkages and "stateful" interactions.

For relationships that serve purely as structural connections without additional attributes, the system relies on Eloquent's ability to manage associations directly via an intermediate table, without requiring a corresponding domain entity. This lightweight pattern is suitable for tagging or categorization features, such as the association between menu items and allergens, where the relationship signifies simple presence.

In contrast, when an association possesses its own data lifecycle or attributes, the architecture elevates the connection to a "Rich Association". The relationship is explicitly modelled as a distinct domain entity rather than a passive database link.

This approach is applied to complex associations such as order line items and user preferences, which require the encapsulation of stateful data like quantities or rankings. By formalizing these intersections as entities, the architecture ensures that relationship attributes are subject to the same validation, typing, and business logic constraints as core domain objects, preserving the integrity of the aggregate boundary

=== Unified Identity Composition
To abstract the physical separation of user roles (User, Customer, Employee) into distinct tables, the ORM utilizes a Global Query Scope. This scope is registered in the `User` model's boot method and configures the retrieval policy to automatically eager-load the optional `customer` and `employee` relations. This allows the application to treat the separate database records as a single, unified "Identity Aggregate" in memory, permitting seamless access to role-specific logic without requiring repetitive or ad-hoc join queries in business services#footnote[#source_code_link("app/Models/User.php")].


