#import "../../config.typ": code_example, source_code_link

== Object-Relational Mapping (ORM) <sec:orm>

To abstract the complexity of raw database interactions and accelerate development, the system utilizes *Eloquent*, Laravel's native Object-Relational Mapper. Eloquent implements the Active Record pattern @FowlerPEAA2002, where each database table is represented by a corresponding "Model" class (e.g., `Restaurant`, `Order`).

As Eloquent is intrinsically integrated with Laravel, it is the default choice for the framework. However, a contextual comparison with other ORM patterns is provided later in this section to further justify this architectural choice.


=== Key Technical Advantages

The decision to utilize Eloquent is reinforced by its feature set, which supports the project's requirements for rapid iteration and maintainable code:

- *Relationship Definitions*: Supports one-to-one, one-to-many, and many-to-many patterns with pivot table attributes, essential for an ordering system where associations carry contextual data.

- *Eager Loading*: Preloads related records in a single query batch, preventing the N+1 query problem @FowlerPEAA2002.

- *Attribute Casting*: Automatically transforms database values into PHP types including dates and enumerations @PHPEnumsDocs, providing type-safe order states with single-line declarations.

- *Query Scopes*: Encapsulates domain-specific filtering logic (e.g., geospatial proximity, availability checks) behind a chainable interface.

- *Computed Attributes*: Accessors expose derived values (e.g., order totals) as virtual model properties.

- *Lifecycle Events*: Models emit events at creation, update, and deletion, enabling decoupled side effects such as real-time broadcasts (see @real-time-broadcasting).

=== Architectural Context: Active Record vs. Data Mapper

Although Eloquent is the standard ORM for the Laravel ecosystem, it is relevant to contextualize its design philosophy - the *Active Record* pattern - against the *Data Mapper* pattern @FowlerPEAA2002 commonly found in enterprise Java (Spring Data JPA) or .NET (Entity Framework) environments.

*Architectural Trade-offs*: The Active Record implementation in Eloquent couples database interaction logic directly with the model class. This approach contrasts with the Data Mapper pattern, which enforces a strict separation between in-memory objects and the database layer. In a Data Mapper implementation, domain entities are pure objects unaware of the database. CRUD operations are distinct responsibilities delegated to a dedicated *Repository* class or *Entity Manager*, which mediates between the object graph and the relational schema. While Data Mapper offers greater architectural purity and testability for large-scale enterprise systems @FowlerPEAA2002, it incurs significant boilerplate overhead in defining and maintaining these intermediary layers.

*Rapid Development Focus*: The project prioritizes development velocity and code conciseness. The approach taken by Eloquent allows for expressive and readable code (e.g., `Order::find(1)->update(...)`) without the necessity for separate repository classes or the explicit mapping configurations required by Spring or stricter Entity Framework implementations.

*Navigation Properties*: Unlike the strongly-typed, interface-driven approach of Spring Data JPA, Eloquent relies on dynamic property access. This trade-off involves a reduction in compile-time safety in exchange for the flexibility of dynamic relationship loading and the rapid definition of accessors.

*Conclusion*: The selection of Eloquent represents a deliberate preference for the agility of the Active Record pattern over the strict separation of the Data Mapper pattern. This decision aligns with the project objective of delivering a functional, feature-rich implementation while focusing on development speed within the required timeframe.

=== Comparative Analysis: Eloquent vs. Enterprise ORMs

To further validate the technology choice, it is constructive to compare Eloquent with industry-standard ORMs from the Java (JPA/Hibernate) and .NET (Entity Framework) ecosystems. This comparison highlights why Eloquent is particularly well-suited for the rapid development of this platform, while acknowledging trade-offs inherent in its design.

==== Strengths of Eloquent

*Query Expressiveness vs. Criteria API*: Eloquent prioritizes a fluent, natural language syntax. Queries such as `Restaurant::where('active', true)->first()` are distinctively concise. In contrast, establishing similar dynamic queries in JPA often necessitates the verbose Criteria API @JakartaPersistence, requiring the construction of `CriteriaBuilder`, `Root`, and `Predicate` objects, which significantly increases code volume and cognitive load.

*Convention over Configuration vs. Explicit Mapping*: Eloquent models rely on conventions (e.g., inferring `restaurants` table from `Restaurant` class). This eliminates the need for the extensive annotation metadata (`@Table`, `@Column`, `@JoinColumn`) or XML configuration files mandatory in Hibernate or older Entity Framework versions, thereby streamlining the codebase.

*Handling Semi-Structured Data*: Features such as Eloquent's Attribute Casting allow seamless JSON-to-object conversion. Achieving this in strict environments like Java often mandates the creation of custom `AttributeConverter` classes to handle the serialization logic manually, whereas Eloquent handles it declaratively.

*Simplified Relationship Handling*: Complex associations such as Polymorphic Relationships are defined with a single method call. In strongly-typed ORMs, achieving similar behavior typically forces a strict Table-Per-Hierarchy or Table-Per-Type inheritance strategy (using `@Inheritance`), introducing complex database schemas and deeper object hierarchies.

==== Limitations and Trade-offs

*Type Safety and Refactoring*: The primary disadvantage compared to Entity Framework or JPA is the lack of strict compile-time safety. Renaming a database column requires careful manual verification across string literals in the codebase.

_Mitigation_: This risk is managed through the consistent use of PHPDoc annotations on models to document properties and methods, enabling IDE code completion and basic type inference, albeit without the guarantee of compilation errors.

*Separation of Concerns*: Eloquent models, by design, mix domain logic with persistence logic. While beneficial for speed, this violates the Single Responsibility Principle @MartinCleanArch2017, whereas strict Data Mapper implementations keep domain entities pure.

_Mitigation_: To prevent "fat models," the architecture enforces a separation of duties: complex business logic is delegated to *Service classes*, and complex validation is handled by *FormRequests*. This ensures Models remain focused solely on data access and relationship definitions, with controllers orchestrating the transformation of data for Inertia responses
