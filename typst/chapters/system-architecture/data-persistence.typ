#import "../../config.typ": code_example, source_code_link

== Data Persistence <data-persistence>

The system persists domain state in a relational database. Any and all interactions, including schema modifications, with the underlying data store are mediated exclusively through the Object-Relational Mapping (ORM) layer. This ensures that all data access operations are managed within a unified architectural boundary. The persistence layer is designed to prioritise data integrity and data access performance through explicit constraints and predictable query patterns.

=== Persistence Strategy and Pattern Selection
An Object-Relational Mapping (ORM) layer abstracts the interaction between the application domain and the relational database. Each domain entity is represented by a corresponding model class that encapsulates both the data structure and the persistence logic.

This is an example of the Active Record design pattern @FowlerPEAA2002, which was selected over the Repository pattern in order to adhere to the framework conventions. In Laravel, the Eloquent ORM natively implements the Active Record pattern, and combined with the framework's emphasis on convention over configuration, this approach streamlines development by reducing boilerplate code and leveraging built-in functionalities.

The ORM handles tasks such as query construction, relationship management, and lifecycle events, allowing developers to interact with the database using high-level abstractions rather than raw SQL.

=== Domain Modelling and Capabilities
The application's domain entities are defined within the `app/Models` directory#footnote[#source_code_link("app/Models")]. Each model class represents a database entity and serves as the primary interface for data access, responsible for enforcing data integrity, defining relationships, and encapsulating domain-specific query logic. Key capabilities include: CRUD operations via high-level abstractions; relationship management defining structural connections between entities; eager loading optimizing retrieval performance; query scopes encapsulating reusable filter logic; computed attributes providing dynamic accessors; lifecycle hooks triggering domain events; and automatic timestamp management.

=== Schema Definition and Version Control
The database structure is defined programmatically through migration files. These migrations serve as version control for the database schema, allowing the architecture to evolve incrementally and reproducibly. By defining the schema in code - including table definitions, index creation, and foreign key constraints - the system ensures that the development, testing, and production environments remain strictly synchronized. Database seeding logic, located in the #source_code_link("database/seeders") directory, complements this by populating the schema with inherent static data (such as dictionary tables for Order Statuses) and test fixtures.


=== Query Abstraction and Semantic Scopes
To maintain separation between domain intent and storage mechanics, the architecture encapsulates complex retrieval logic within reusable query scopes. This prevents the leakage of raw SQL or database-specific syntax (such as spatial function calls) into the application layer. Instead, models expose a semantic API for filtering and retrieval that aligns with business language (e.g., proximity constraints or availability checks). This abstraction permits the underlying database implementation - such as the specific choice of geometric algorithms - to evolve without necessitating changes to the consuming controllers or services.

=== Virtual State and Accessors
The ORM transforms data from storage-efficient format to domain-optimized representation. Eloquent accessors expose computed domain concepts (e.g., order totals derived from line item relations) as intrinsic properties#footnote[#source_code_link("app/Models/Order.php")], centralizing calculation logic and preventing duplication of critical business formulas.

=== Reactive Persistence and Event Integration
The persistence layer serves as the catalyst for the system's event-driven architecture. State changes within the ORM are tied to the application's event bus, transforming database transactions into observable system-wide occurrences. This ensures that the system reacts consistently to state changes regardless of the trigger source, decoupling persistence logic from downstream side effects such as notifications or real-time broadcasting#footnote[#source_code_link("app/Models/Order.php")].

=== Handling Many-to-Many Relationships
The architecture distinguishes between "stateless" linkages and "stateful" interactions in many-to-many associations. For structural connections without additional attributes (e.g., menu items and allergens), Eloquent manages associations directly via intermediate tables without domain entities. When associations possess their own data lifecycle (e.g., order line items with quantities), the architecture elevates connections to "Rich Associations" @FowlerPEAA2002, modeling them as distinct domain entities subject to validation, typing, and business logic constraints.

=== Unified Identity Composition
To abstract the physical separation of user roles (User, Customer, Employee) into distinct tables, the ORM utilizes a Global Query Scope. This scope is registered in the `User` model's boot method and configures the retrieval policy to automatically eager-load the optional `customer` and `employee` relations. This allows the application to treat the separate database records as a single, unified "Identity Aggregate" in memory, permitting seamless access to role-specific logic without requiring repetitive or ad-hoc join queries in business services#footnote[#source_code_link("app/Models/User.php")].


