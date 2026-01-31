#import "../../config.typ": code_example, source_code_link

== Data Persistence

The system persists domain state in a relational database. Any and all interactions, including schema modifications, with the underlying data store are mediated exclusively through the Object-Relational Mapping (ORM) layer. This ensures that all data access operations are managed within a unified architectural boundary. The persistence layer is designed to prioritise data integrity and data access performance through explicit constraints and predictable query patterns.

=== Persistence Strategy and Pattern Selection
An Object-Relational Mapping (ORM) layer abstracts the interaction between the application domain and the relational database. Each domain entity is represented by a corresponding model class that encapsulates both the data structure and the persistence logic.

This is an example of the Active Record design pattern, which was selected over the Repository pattern in order to adhere to the framework conventions. In Laravel, the Eloquent ORM natively implements the Active Record pattern, and combined with the framework's emphasis on convention over configuration, this approach streamlines development by reducing boilerplate code and leveraging built-in functionalities.

The ORM handles tasks such as query construction, relationship management, and lifecycle events, allowing developers to interact with the database using high-level abstractions rather than raw SQL.

=== Domain Modelling and Capabilities
The application's domain entities are defined within the `app/Models` directory#footnote[#source_code_link("app/Models")]. Each model class acts as a representation of a database entity and serves as the primary interface for data access. These models are not passive data transfer objects; they are responsible for enforcing data integrity, defining relationships, and encapsulating domain-specific query logic.

Key responsibilities of the Model layer include:

*CRUD Operations*: Providing high-level abstractions for creating, reading, updating, and deleting records without raw SQL.

*Relationship Management*: Defining the structural connections between entities (e.g., a Customer _has many_ Orders).

*Eager Loading*: Optimizing data retrieval performance by pre-loading associated entities (e.g., loading `customer` with `User`).

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

This approach is applied to complex associations such as order line items and user preferences, which require the encapsulation of stateful data like quantities or rankings. By formalizing these intersections as entities, the architecture ensures that relationship attributes are subject to the same validation, typing, and business logic constraints as core domain objects, preserving the integrity of the aggregate boundary.

=== Unified Identity Composition
To abstract the physical separation of user roles (User, Customer, Employee) into distinct tables, the ORM utilizes a Global Query Scope. This scope is registered in the `User` model's boot method and configures the retrieval policy to automatically eager-load the optional `customer` and `employee` relations. This allows the application to treat the separate database records as a single, unified "Identity Aggregate" in memory, permitting seamless access to role-specific logic without requiring repetitive or ad-hoc join queries in business services#footnote[#source_code_link("app/Models/User.php")].


