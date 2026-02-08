#import "../../config.typ": code_example, source_code_link

== Object-Relational Mapping (ORM) <sec:orm>

To abstract the complexity of raw database interactions and accelerate development, the system utilizes *Eloquent*, Laravel's native Object-Relational Mapper. Eloquent implements the Active Record pattern @FowlerPEAA2002, where each database table is represented by a corresponding "Model" class (e.g., `Restaurant`, `Order`). Alternative ORM solutions were not considered as primary candidates, as Eloquent is intrinsically integrated with Laravel, making it the default and optimal choice for the framework. However, a contextual comparison with other ORM patterns is provided later in this section to further justify this architectural choice.

=== Key Technical Advantages
The decision to utilize Eloquent is reinforced by its comprehensive feature set, which supports the project's requirements for rapid iteration and maintainable code structure:

Eloquent supports the full spectrum of relational patterns through simple method declarations, including pivot table attributes and eager loading to prevent the N+1 query problem @FowlerPEAA2002.

Its casting system automatically transforms raw database values into appropriate PHP types -- including Carbon date objects and PHP enumerations @PHPEnumsDocs -- ensuring type consistency without manual transformation logic.

Reusable query constraints can be defined as named scope methods, encapsulating domain-specific filtering logic behind a chainable interface that keeps controllers free of raw query construction.

Eloquent's accessor feature enables models to expose derived values as virtual properties, centralizing calculation logic such as dynamically computed order totals.

Model lifecycle events (creation, update, deletion) decouple persistence from side effects such as notifications or real-time broadcasts, as detailed in @real-time-broadcasting.


=== Architectural Context: Active Record vs. Data Mapper

Although Eloquent is the standard ORM for the Laravel ecosystem, it is relevant to contextualize its *Active Record* pattern against the *Data Mapper* pattern @FowlerPEAA2002 used in enterprise Java (Spring Data JPA) and .NET (Entity Framework). Data Mapper enforces strict separation between domain objects and the database layer, offering greater architectural purity at the cost of significant boilerplate overhead. The project prioritizes development velocity; Eloquent's approach allows expressive code (e.g., `Order::find(1)->update(...)`) without separate repository classes, representing a deliberate preference for agility over strict separation of concerns.

=== Comparative Analysis: Eloquent vs. Enterprise ORMs

Compared with JPA/Hibernate and Entity Framework, Eloquent's fluent query syntax (e.g., `Restaurant::where('active', true)->first()`) is notably more concise than JPA's verbose Criteria API @JakartaPersistence, and its convention-over-configuration approach eliminates the extensive annotation metadata required by Hibernate or older Entity Framework versions. Eloquent also simplifies semi-structured data handling and polymorphic relationships through declarative single-method definitions. The primary trade-off is the lack of strict compile-time type safety -- renaming a database column requires manual verification across string literals -- mitigated through PHPDoc annotations for IDE support. Additionally, Eloquent models mix domain and persistence logic, violating the Single Responsibility Principle @MartinCleanArch2017; this is addressed by delegating complex business logic to *Service classes* and validation to *FormRequests*.
