#import "../../config.typ": code_example, source_code_link

== Object-Relational Mapping (ORM) <sec:orm>

To abstract the complexity of raw database interactions and accelerate development, the system utilizes *Eloquent*, Laravel's native Object-Relational Mapper. Eloquent implements the Active Record pattern @FowlerPEAA2002, where each database table is represented by a corresponding "Model" class (e.g., `Restaurant`, `Order`). Alternative ORM solutions were not considered as primary candidates, as Eloquent is intrinsically integrated with Laravel, making it the default and optimal choice for the framework. However, a contextual comparison with other ORM patterns is provided later in this section to further justify this architectural choice.

=== Key Technical Advantages
The decision to utilize Eloquent is reinforced by its comprehensive feature set, which supports the project's requirements for rapid iteration and maintainable code structure:

*Relationship Definitions*: Eloquent supports the full spectrum of relational patterns (one-to-one, one-to-many, and many-to-many) through simple method declarations on the model class. Many-to-many relationships can carry additional attributes on the intermediate pivot table without requiring a separate model class. Eloquent also provides eager loading, a mechanism that preloads related records in a single query batch, preventing the N+1 query problem @FowlerPEAA2002 that commonly arises when iterating over collections with lazy-loaded relationships.

*Attribute Casting*: Eloquent's casting system automatically transforms raw database values into appropriate PHP types upon model retrieval. Supported transformations include date strings to Carbon date objects, integer columns to PHP enumerations, and plaintext values to hashed representations. This declarative approach ensures type consistency across the application without requiring manual transformation logic at each point of access, reducing the surface area for type-related errors.

*Query Scopes*: Eloquent allows the definition of reusable query constraints as named scope methods on the model class. These scopes encapsulate domain-specific filtering logic (e.g., geospatial proximity calculations or availability checks) behind a clean, chainable interface. This mechanism keeps controllers and services free of raw query construction while allowing complex constraints to be composed fluently, improving both readability and reusability.

*Computed Attributes*: Eloquent's accessor feature enables models to expose derived values as virtual properties that do not correspond to physical database columns. This allows domain concepts (e.g., order totals computed dynamically from related records) to be accessed as simple model properties, centralizing calculation logic and preventing duplication of business formulas across the application.

*Lifecycle Events*: Eloquent models emit events at key points in their lifecycle (creation, update, deletion), which can be observed by event listener classes. This decouples the persistence layer from side effects such as notifications or real-time broadcasts. When combined with Laravel's broadcasting system, model events can propagate state changes to connected WebSocket clients automatically, as detailed in @real-time-broadcasting.

*Enumeration Support*: PHP 8.1 introduced backed enumerations @PHPEnumsDocs, providing type-safe representation of fixed value sets as first-class language constructs. Eloquent integrates with this feature through its casting system, allowing enum-backed database columns to be automatically hydrated into their corresponding PHP enum instances.

This eliminates the use of raw integer constants or string literals for representing states such as order lifecycle stages, enabling IDE autocompletion, preventing invalid state assignments at the type level, and making conditional logic self-documenting throughout the codebase.

In comparison, Entity Framework and JPA require explicit value converters or annotation-based configuration to achieve equivalent enum hydration, making Eloquent's single-line cast definition a notably lower-friction approach.
