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
// TODO: theres probably duplication with one of the database sections, make sure this make sense to explain.
/ Base User Record: The `users` table stores common authentication data (email, password, name) and a global `is_admin` flag for system administrators.

/ Customer Profile: The `customers` table uses `user_id` as its primary key (a one-to-one relationship), storing customer-specific attributes. A user with an associated customer record is considered a customer.

/ Employee Profile: The `employees` table similarly uses `user_id` as its primary key, with an additional `restaurant_id` foreign key binding the employee to a specific restaurant. Employees may also have an `is_admin` flag granting restaurant-level administrative privileges.

This design enables unified login regardless of user type, while supporting divergent functionality based on the associated profile. A user may theoretically hold both profiles, though the application enforces separation through distinct registration flows.

The User model defined in #source_code_link("app/Models/User.php") automatically eager-loads both profile relationships via a global scope, ensuring that role checks (`isCustomer()`, `isEmployee()`) execute without additional queries.

=== Request Validation Architecture

==== Validation Strategy

The application employs a two-tier validation strategy, choosing the mechanism based on complexity and reuse requirements.

For the majority of controller methods, validation is performed inline using Laravel's `$request->validate()` method directly within the controller action. This approach keeps simple validation rules co-located with the handling logic, reducing indirection for straightforward operations such as CRUD actions, status updates, and form submissions.

For operations involving complex validation logic --- such as authentication with rate limiting or registration with custom error messages and attribute aliases --- dedicated Form Request classes are used. These classes extend Laravel's `FormRequest` base and encapsulate validation rules, authorization checks, custom messages, and additional business logic (such as the rate-limited authentication method in `LoginRequest`) into a single reusable object.

This pragmatic approach balances two concerns:

- *Locality*: Simple validation rules remain visible at the point of use, keeping controllers self-contained for straightforward operations.
- *Encapsulation and Reusability*: Complex or security-critical validation is extracted into dedicated classes that can be reused across multiple controller actions, preventing controller methods from becoming cluttered with validation logic that would obscure their primary orchestration responsibility.

==== Rate Limiting for Security

Form Request classes can extend beyond input validation to incorporate security concerns such as rate limiting.

For example, the #source_code_link("app/Http/Requests/Auth/LoginRequest.php") embeds throttling logic within the validation layer, ensuring brute-force protection is enforced before authentication is attempted.

The throttle strategy identifies requests by a combination of user identity and client origin, mitigating both credential stuffing and IP-based brute-force attacks. This keeps security-specific logic out of the controller while co-locating it with the related validation rules, reinforcing the separation of concerns that the Form Request pattern provides.

=== Authorization Architecture

==== Policy-Based Access Control

Access control is implemented through Policy classes, with each major resource (orders, restaurants, menu items, reviews) having an associated policy that defines which users may perform which actions. Policies are registered in #source_code_link("app/Providers/AuthServiceProvider.php"), which maps fifteen model classes to their corresponding policy classes.

Policy methods receive the authenticated user and (optionally) the resource being accessed, returning a boolean indicating whether the action is permitted. Standard Laravel authorization methods (`view`, `create`, `update`, `delete`) are implemented alongside custom methods for domain-specific actions.

==== Admin Bypass Gate

A global gate defined in the `AuthServiceProvider` grants system administrators (`is_admin = true`) unrestricted access to all resources. This gate fires before any policy check:

When `Gate::before()` returns `true`, all subsequent policy checks are skipped, granting full access. When it returns `null`, normal policy evaluation proceeds. This pattern centralizes the admin override logic rather than repeating it in every policy method.

==== Context-Aware Authorization

Policies evaluate the user's relationship to the resource being accessed. The order policy defined in #source_code_link("app/Policies/OrderPolicy.php") demonstrates this pattern:

- View is permitted for the owning customer, employees of the associated restaurant, or administrators.
- Update is permitted for restaurant employees (for status changes), or customers only when the order status is `InCart`.
- Delete is permitted for customers only when the order status is `InCart`, preventing deletion of placed orders.

These checks enforce multi-tenancy boundaries, ensuring employees can only access orders belonging to their restaurant and customers can only access their own orders.

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

When business logic is sufficiently simple --- such as straightforward CRUD operations or single-model updates --- it may remain in the controller rather than being extracted into a dedicated service. Service classes are introduced when the logic grows complex enough that it would obscure the controller's orchestration responsibility, involves multiple models or external systems, or benefits from reuse across different entry points.

==== Domain-Organized Controllers

Controllers are organized by user domain rather than resource type. Customer-facing controllers reside in `App\Http\Controllers\Customer`, while employee-facing controllers reside in `App\Http\Controllers\Employee`. This organization reflects the architectural separation between user journeys and aligns with route grouping and middleware application.

=== Service Layer Architecture

==== Domain Services

Complex business logic that spans multiple models or involves external systems is encapsulated in service classes within the `App\Services` namespace. Services are stateless, receiving dependencies through constructor injection, and provide focused methods for specific domain operations.

The `ReviewService` defined in #source_code_link("app/Services/ReviewService.php") demonstrates this pattern. It handles:

- Review creation with optional image uploads to cloud storage (R2)
- Review updates with image addition and deletion coordination
- Review deletion with storage cleanup and error logging
- Automatic recalculation of the parent restaurant's aggregate rating after every create, update, or delete operation, ensuring the displayed rating always reflects current review data

The service returns a `ReviewOperationResult` data transfer object that encapsulates both the resulting review and any upload errors, allowing the controller to provide appropriate feedback without exposing service internals.

==== Cross-Cutting Utility Services

Beyond domain-specific operations, services also encapsulate cross-cutting technical concerns that are shared across multiple controllers and models. For example, the #source_code_link("app/Services/GeoService.php") centralizes geospatial logic --- session-based location persistence, bounding box calculation, and distance formatting --- so that coordinate handling remains consistent throughout the application without duplicating spatial algorithms across consumers.

=== Middleware Architecture

==== Role-Based Route Protection

Custom middleware classes enforce role membership at the route group level, rejecting requests from users who lack the required profile (customer or employee) before controller logic executes. This provides early rejection and prevents users from reaching endpoints outside their role entirely.

This complements the policy-based authorization described earlier: middleware answers "may this user access employee routes at all?" while policies (invoked from controllers) answer "may this user modify this specific order?"

==== Inertia Request Handling

The `HandleInertiaRequests` middleware defined in #source_code_link("app/Http/Middleware/HandleInertiaRequests.php") bridges the Laravel backend with the React frontend through Inertia.js. It shares common data with every response:

- *Authentication State*: The authenticated user, their restaurant ID (if employee), and restaurant admin status.
- *Flash Messages*: Success and error messages from the session for user feedback.
- *Configuration*: Environment-specific values such as the Mapbox public key.

This middleware ensures consistent data availability across all pages without repetitive controller logic.


=== Summary

The Laravel backend architecture demonstrates several key patterns:

- *Layered Separation*: Routing, controllers, services, and models have distinct responsibilities.
- *Dual User Types*: Unified authentication with profile-based role differentiation.
- *Multi-Layered Authorization*: Middleware for route protection, policies for resource access, gates for custom rules, with admin bypass.
- *Thin Controllers*: HTTP concerns only, with service delegation for complex business logic.
- *Domain Services*: Stateless classes encapsulating complex operations.
These patterns support maintainability, testability, and security while providing the flexibility needed for a multi-tenant restaurant ordering system.
