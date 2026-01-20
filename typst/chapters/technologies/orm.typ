#import "../../config.typ": code_example, source_code_link

== Object-Relational Mapping (ORM)

To abstract the complexity of raw database interactions and accelerate development, the system utilizes *Eloquent*, Laravel's native Object-Relational Mapper. Eloquent implements the Active Record pattern, where each database table is represented by a corresponding "Model" class (e.g., `Restaurant`, `Order`). Alternative ORM solutions were not considered, as Eloquent is intrinsically integrated with Laravel, making it the default and optimal choice for the framework.

=== Integrated Capabilities
Key Eloquent features leveraged in this project include:

*Relationship Management*: Eloquent's relationship methods (e.g., `hasMany`, `belongsTo`) enable seamless navigation between related models, such as linking restaurants to their menu items and orders. These relationships leverage PHP's magic methods for dynamic access and lazy loading.

*Model Events*: The system leverages model observers to trigger side effects - such as clearing caches or dispatching WebSocket events, i.e. whenever a record is created or updated.

*Soft Deletes*: Critical entities like `Restaurant` and `MenuItem` implement soft deletion, ensuring that data is never permanently lost from the database unless explicitly purged, which is vital for historical integrity and audit trails.

*Query Scopes*: Local scopes (e.g., `scopeWithinRadiusKm`, `scopeOrderByDistance`) encapsulate reusable query logic, particularly for geospatial filtering and sorting, promoting code reusability and maintainability.

*Accessors*: Computed attributes (e.g., `getUrlAttribute`, `getTotalAttribute`) provide dynamic properties, such as generating image URLs or calculating order totals on-the-fly.

*Attribute Casting*: Automatic type conversion (e.g., casting dates and JSON fields) ensures data integrity and simplifies data handling across the application.


=== Architectural Context: Active Record vs. Data Mapper

Although Eloquent is the standard ORM for the Laravel ecosystem, it is relevant to contextualize its design philosophythe *Active Record* patternagainst the *Data Mapper* pattern commonly found in enterprise Java (Spring Data JPA) or .NET (Entity Framework) environments.

*Architectural Trade-offs*: The Active Record implementation in Eloquent couples database interaction logic directly with the model class. This approach contrasts with the Data Mapper pattern, which enforces a strict separation between in-memory objects and the database layer. While Data Mapper offers greater architectural purity and testability for large-scale enterprise systems, it incurs significant boilerplate overhead.

*Rapid Development Focus*: The project prioritizes development velocity and code conciseness. The approach taken by Eloquent allows for expressive and readable code (e.g., `Order::find(1)->update(...)`) without the necessity for separate repository classes or the explicit mapping configurations required by Spring or stricter Entity Framework implementations.

*Navigation Properties*: Unlike the strongly-typed, interface-driven approach of Spring Data JPA, Eloquent relies on dynamic property access. This trade-off involves a reduction in compile-time safety in exchange for the flexibility of dynamic relationship loading and the rapid definition of accessors.

*Conclusion*: The selection of Eloquent represents a deliberate preference for the agility of the Active Record pattern over the strict separation of the Data Mapper pattern. This decision aligns with the project objective of delivering a functional, feature-rich implementation while focusing on development speed within the required timeframe.
