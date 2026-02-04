#import "../../config.typ": code_example, source_code_link

== Laravel Backend Architecture <backend-architecture>

The backend of the restaurant ordering system is built on Laravel 11, following a layered architecture that separates concerns across distinct responsibilities: HTTP handling, business logic, data access, and cross-cutting concerns such as authentication and authorization. This section describes the architectural patterns that govern how requests flow through the system, how access control is enforced, and how domain logic is organized.

=== Layered Architecture Overview

The backend is organized into four primary layers, each with well-defined responsibilities:

/ Routing Layer: Maps incoming HTTP requests to controller actions based on URL patterns and HTTP methods. Routes are organized by domain (authentication, customer operations, employee operations) in separate route files.

/ Controller Layer: Handles HTTP request/response concerns - parsing input, invoking authorization checks, delegating to services, and returning responses. Controllers are kept deliberately thin, avoiding business logic.

/ Service Layer: Encapsulates domain-specific business logic that does not naturally belong to a single model or controller. Services provide stateless methods for complex operations involving multiple models or external systems.

/ Model Layer: Represents domain entities using Eloquent ORM, defining relationships, attribute casting, computed properties, query scopes, and model events.

Cross-cutting concerns (authentication, authorization, validation) are handled through dedicated subsystems that integrate with these layers without creating tight coupling.

=== Authentication Architecture

==== Laravel Sanctum Integration

Authentication is provided by Laravel Sanctum, which offers both session-based authentication for web requests and token-based authentication for API consumers. Given the web-first nature of this application, session-based authentication is used exclusively.

The authentication flow relies on Laravel's default `web` guard with session storage. Upon successful login, a session is established and maintained through encrypted cookies. Subsequent requests are authenticated by validating the session against the database-backed session store.

==== Dual User Type Architecture

The system distinguishes between two user types - customers and employees - while maintaining a unified authentication mechanism. This is achieved through a shared `User` model with separate profile tables for role-specific attributes.

The architectural pattern is as follows:

/ Base User Record: The `users` table stores common authentication data (email, password, name) and a global `is_admin` flag for system administrators.

/ Customer Profile: The `customers` table uses `user_id` as its primary key (a one-to-one relationship), storing customer-specific attributes. A user with an associated customer record is considered a customer.

/ Employee Profile: The `employees` table similarly uses `user_id` as its primary key, with an additional `restaurant_id` foreign key binding the employee to a specific restaurant. Employees may also have an `is_admin` flag granting restaurant-level administrative privileges.

This design enables unified login regardless of user type, while supporting divergent functionality based on the associated profile. A user may theoretically hold both profiles, though the application enforces separation through distinct registration flows.

The User model defined in #source_code_link("app/Models/User.php") automatically eager-loads both profile relationships via a global scope, ensuring that role checks (`isCustomer()`, `isEmployee()`) execute without additional queries.

=== Request Validation Architecture

==== Form Request Pattern

All incoming data undergoes validation through dedicated Form Request classes. These classes extend Laravel's `FormRequest` base and encapsulate validation rules, authorization checks, and custom error messages for specific operations.

This pattern provides several architectural benefits:

- *Separation of Concerns*: Validation logic is removed from controllers, keeping them focused on request orchestration.
- *Reusability*: Common validation rules are centralized and consistently applied.
- *Testability*: Validation logic can be tested independently of controller behavior.
- *Self-Documentation*: Form Request classes serve as documentation of expected input formats.

==== Rate Limiting for Security

The authentication system implements rate limiting within the login Form Request to mitigate brute-force attacks. The `LoginRequest` class defined in #source_code_link("app/Http/Requests/Auth/LoginRequest.php") enforces a limit of five authentication attempts per email/IP combination.

When the limit is exceeded, a `Lockout` event is fired and the user receives a validation error indicating the remaining cooldown period. The throttle key combines the transliterated email address with the client IP address, preventing both credential stuffing (many IPs, one email) and IP-based attacks (one IP, many emails) while avoiding false positives from legitimate users behind shared networks.

=== Authorization Architecture

==== Policy-Based Access Control

Access control is implemented through Policy classes, with each major resource (orders, restaurants, menu items, reviews) having an associated policy that defines which users may perform which actions. Policies are registered in #source_code_link("app/Providers/AuthServiceProvider.php"), which maps fifteen model classes to their corresponding policy classes.

Policy methods receive the authenticated user and (optionally) the resource being accessed, returning a boolean indicating whether the action is permitted. Standard Laravel authorization methods (`view`, `create`, `update`, `delete`) are implemented alongside custom methods for domain-specific actions.

==== Admin Bypass Gate

A global gate defined in the `AuthServiceProvider` grants system administrators (`is_admin = true`) unrestricted access to all resources. This gate fires before any policy check:

When `Gate::before()` returns `true`, all subsequent policy checks are skipped, granting full access. When it returns `null`, normal policy evaluation proceeds. This pattern centralizes the admin override logic rather than repeating it in every policy method.

==== Context-Aware Authorization

Policies implement context-aware checks that consider the user's relationship to the resource. The order policy defined in #source_code_link("app/Policies/OrderPolicy.php") demonstrates this pattern:

- *View*: Permitted for the owning customer, employees of the associated restaurant, or administrators.
- *Update*: Permitted for restaurant employees (for status changes), or customers only when the order status is `InCart`.
- *Delete*: Permitted for customers only when the order status is `InCart`, preventing deletion of placed orders.

These checks enforce multi-tenancy boundaries, ensuring employees can only access orders belonging to their restaurant and customers can only access their own orders. The pattern prevents cross-restaurant data leakage through explicit relationship verification rather than implicit trust.

==== Custom Gate Definitions

Beyond resource policies, custom gates define cross-cutting authorization rules. The `manage-restaurant` gate, for example, permits only restaurant administrators (employees with `is_admin = true` for their restaurant) to perform management operations such as editing restaurant details or managing menu categories.

=== Controller Architecture

==== Thin Controller Pattern

Controllers in this application follow the thin controller pattern, focusing exclusively on HTTP-layer concerns:

+ Parsing and validating request input
+ Invoking authorization checks via policies
+ Delegating business logic to services
+ Constructing and returning responses

Business logic, data transformation, and side effects (such as file uploads or event dispatching) are delegated to service classes or handled through model events. This separation ensures controllers remain testable and maintainable as the application grows.

The `ReviewController` defined in #source_code_link("app/Http/Controllers/Customer/ReviewController.php") exemplifies this pattern: it receives a `ReviewService` through constructor injection and delegates all create, update, and delete operations to the service, handling only authorization, validation, and response formatting.

==== Domain-Organized Controllers

Controllers are organized by user domain rather than resource type. Customer-facing controllers reside in `App\Http\Controllers\Customer`, while employee-facing controllers reside in `App\Http\Controllers\Employee`. This organization reflects the architectural separation between user journeys and aligns with route grouping and middleware application.

=== Service Layer Architecture

==== Domain Services

Complex business logic that spans multiple models or involves external systems is encapsulated in service classes within the `App\Services` namespace. Services are stateless, receiving dependencies through constructor injection, and provide focused methods for specific domain operations.

The `ReviewService` defined in #source_code_link("app/Services/ReviewService.php") demonstrates this pattern. It handles:

- Review creation with optional image uploads to cloud storage (R2)
- Review updates with image addition and deletion coordination
- Review deletion with storage cleanup and error logging

The service returns a `ReviewOperationResult` data transfer object that encapsulates both the resulting review and any upload errors, allowing the controller to provide appropriate feedback without exposing service internals.

==== Geospatial Service

The `GeoService` defined in #source_code_link("app/Services/GeoService.php") provides geospatial utilities used across the application:

- *Session Persistence*: Stores and retrieves user location coordinates with 24-hour expiry.
- *Bounding Box Calculation*: Computes latitude/longitude bounds for a given radius, accounting for spherical geometry.
- *Distance Formatting*: Normalizes distance values for consistent display.

By centralizing geospatial logic in a dedicated service, controllers and models remain focused on their primary responsibilities while sharing consistent coordinate handling.

=== Middleware Architecture

==== Role-Based Route Protection

Access to protected routes is enforced through custom middleware classes that verify user roles before allowing request processing. Three middleware classes implement this pattern:

/ EnsureUserIsEmployee: Defined in #source_code_link("app/Http/Middleware/EnsureUserIsEmployee.php"), this middleware aborts with HTTP 403 if the authenticated user lacks an employee profile. It is applied to all employee-facing routes.

/ EnsureUserIsCustomer: Aborts with HTTP 403 if the authenticated user lacks a customer profile. Applied to customer-only routes requiring authentication.

/ BlockEmployees: Prevents employees from accessing customer-facing pages, ensuring role separation in the user interface.

These middleware classes complement policy-based authorization: middleware enforces coarse-grained access (which route groups a user may access), while policies enforce fine-grained access (which specific resources a user may manipulate).

==== Inertia Request Handling

The `HandleInertiaRequests` middleware defined in #source_code_link("app/Http/Middleware/HandleInertiaRequests.php") bridges the Laravel backend with the React frontend through Inertia.js. It shares common data with every response:

- *Authentication State*: The authenticated user, their restaurant ID (if employee), and restaurant admin status.
- *Flash Messages*: Success and error messages from the session for user feedback.
- *Configuration*: Environment-specific values such as the Mapbox public key.

This middleware ensures consistent data availability across all pages without repetitive controller logic.

=== Model Architecture

==== Eloquent Relationship Patterns

Models define relationships using Eloquent's relationship methods, establishing the object graph that represents the domain. Common patterns include:

- *One-to-One*: User to Customer/Employee profiles, using shared primary keys.
- *One-to-Many*: Restaurant to Employees, Orders, MenuItems, Reviews.
- *Many-to-Many*: Orders to MenuItems through pivot table with quantity, Customers to FavoriteRestaurants with rank.

Relationships are defined with appropriate foreign key specifications, enabling eager loading to prevent N+1 query problems.

==== Attribute Casting

Models leverage Laravel's attribute casting to ensure type consistency:

- *Password Hashing*: The User model casts `password` as `hashed`, ensuring automatic hashing on assignment.
- *Enum Casting*: The Order model casts `order_status_id` to the `OrderStatus` enum, enabling type-safe status comparisons.
- *DateTime Casting*: Timestamp fields are cast to Carbon instances for consistent date manipulation.

==== Computed Attributes

Models define computed attributes using accessors, exposing derived values as properties. The Order model's `total` attribute, for example, calculates the sum of menu item prices multiplied by their quantities from the pivot table.

==== Query Scopes

Local scopes encapsulate reusable query constraints. The Restaurant model defined in #source_code_link("app/Models/Restaurant.php") provides geospatial scopes:

- `scopeWithDistanceTo`: Adds a computed `distance` column using `ST_Distance_Sphere` or a Haversine fallback.
- `scopeWithinRadiusKm`: Filters restaurants within a radius using bounding box prefiltering and exact distance constraints.
- `scopeOrderByDistance`: Orders results by the computed distance.

These scopes enable composable query building while encapsulating geospatial complexity.

==== Model Events and Broadcasting

Models dispatch events through the `booted` method to trigger side effects without coupling to specific implementations. The Order model defined in #source_code_link("app/Models/Order.php") dispatches an `OrderUpdated` event on creation and status changes.

The event class implements `ShouldBroadcast`, causing Laravel to forward it to the Reverb WebSocket server for real-time client notification. This integration is detailed in @real-time-events.

=== Enumeration Pattern

PHP 8.1 backed enums provide type-safe representation of fixed value sets. The `OrderStatus` enum defined in #source_code_link("app/Enums/OrderStatus.php") represents the order lifecycle:

- `InCart` → `Placed` → `Accepted`/`Declined` → `Preparing` → `Ready` → `Fulfilled`/`Cancelled`

The enum provides a `label()` method for human-readable display names. Using enums rather than integer constants or string values enables IDE autocompletion, prevents invalid state assignments, and makes status checks self-documenting in policy and controller code.

=== Summary

The Laravel backend architecture demonstrates several key patterns:

- *Layered Separation*: Routing, controllers, services, and models have distinct responsibilities.
- *Dual User Types*: Unified authentication with profile-based role differentiation.
- *Multi-Layered Authorization*: Middleware for route protection, policies for resource access, gates for custom rules, with admin bypass.
- *Thin Controllers*: HTTP concerns only, delegating business logic to services.
- *Domain Services*: Stateless classes encapsulating complex operations.
- *Rich Models*: Relationships, scopes, casting, computed attributes, and event dispatching.
- *Type Safety*: Backed enums for fixed value sets, attribute casting for consistency.

These patterns support maintainability, testability, and security while providing the flexibility needed for a multi-tenant restaurant ordering system.
