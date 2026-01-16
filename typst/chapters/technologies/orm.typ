#import "../../config.typ": code_example, source_code_link

== Object-Relational Mapping (ORM)

To abstract the complexity of raw database interactions and accelerate development, the system utilizes *Eloquent*, Laravel's native Object-Relational Mapper. Eloquent implements the Active Record pattern, where each database table is represented by a corresponding "Model" class (e.g., `Restaurant`, `Order`).

=== Strategic Usage of Eloquent
Eloquent was employed to handle the vast majority of standard CRUD (Create, Read, Update, Delete) operations. Its fluent interface allows for expressive query construction, increasing code readability and maintainability. Key features utilized include:
- *Relationship Management*: Eloquent automatically manages primary and foreign key constraints, simplifying the retrieval of related data (e.g., `$restaurant->menuItems`).
- *Model Events*: The system leverages model observers to trigger side effects - such as clearing caches or dispatching WebSocket events, i.e. whenever a record is created or updated.
- *Soft Deletes*: Critical entities like `Restaurant` and `MenuItem` implement soft deletion, ensuring that data is never permanently lost from the database unless explicitly purged, which is vital for historical integrity and audit trails.

=== Performance Balancing and Raw SQL
While Eloquent provides significant developer productivity, it incurs a performance overhead due to object hydration. The system architecture adopts a pragmatic approach: standard operations use Eloquent for safety and speed of development, while high-performance, complex read operations bypass the ORM in favor of raw SQL or optimized Builder chains.

This hybrid approach is exemplified in the restaurant discovery features, where complex mathematical calculations for ranking and sorting are executed purely at the database level to minimize memory usage and processing time in the application layer. This decision reflects a nuanced understanding of the trade-offs between abstraction and bare-metal performance.
