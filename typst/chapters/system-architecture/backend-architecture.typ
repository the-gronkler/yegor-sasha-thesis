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

Authentication is provided by Laravel Sanctum @LaravelSanctumDocs, which offers both session-based authentication for web requests and token-based authentication for API consumers. Given the web-first nature of this application, session-based authentication is used exclusively.

The authentication flow relies on Laravel's default `web` guard with session storage. Upon successful login, a session is established and maintained through encrypted cookies. Subsequent requests are authenticated by validating the session against the database-backed session store.

==== Dual User Type Architecture

The system distinguishes between two user types — customers and employees — using a shared `users` table with separate profile tables (@database-design). The User model defined in #source_code_link("app/Models/User.php") automatically eager-loads both profiles via a global scope, ensuring role checks (`isCustomer()`, `isEmployee()`) execute without additional queries.

=== Request Validation Architecture

==== Validation Strategy

The application employs inline validation via `$request->validate()` for simple operations and dedicated Form Request classes for complex logic requiring rate limiting, custom error messages, or reuse. This balances locality (simple rules remain at point of use) with encapsulation (complex validation is extracted into reusable classes).

==== Rate Limiting for Security

Form Request classes can extend beyond input validation to incorporate security concerns such as rate limiting.

For example, the #source_code_link("app/Http/Requests/Auth/LoginRequest.php") embeds throttling logic within the validation layer, ensuring brute-force protection is enforced before authentication is attempted.

The throttle strategy identifies requests by a combination of user identity and client origin, mitigating both credential stuffing and IP-based brute-force attacks. This keeps security-specific logic out of the controller while co-locating it with the related validation rules, reinforcing the separation of concerns that the Form Request pattern provides.

=== Authorization Architecture

==== Policy-Based Access Control

Access control is implemented through Policy classes mapping to major resources. Policy methods receive the authenticated user and optional resource, returning boolean authorization decisions. The order policy defined in #source_code_link("app/Policies/OrderPolicy.php") enforces multi-tenancy: customers access only their own orders; employees access only their restaurant's orders; administrators access all orders.

A global gate in `AuthServiceProvider` grants administrators (`is_admin = true`) unrestricted access. When `Gate::before()` returns `true`, subsequent policy checks are skipped. This centralizes admin override logic.

Custom gates define cross-cutting rules. The `manage-restaurant` gate permits only restaurant administrators to perform management operations such as editing restaurant details or managing menu categories.

=== Controller Architecture

==== Thin Controller Pattern

Controllers in this application follow the thin controller pattern @FowlerPEAA2002, focusing exclusively on HTTP-layer concerns:

+ Parsing and validating request input
+ Invoking authorization checks via policies
+ Delegating business logic to services
+ Constructing and returning responses

Business logic, data transformation, and side effects (such as file uploads or event dispatching) are delegated to service classes or handled through model events. This separation ensures controllers remain testable and maintainable as the application grows.

For example, a review controller receives a review service through constructor injection and delegates all create, update, and delete operations to the service, handling only authorization, validation, and response formatting.

When business logic is sufficiently simple --- such as straightforward CRUD operations or single-model updates --- it may remain in the controller rather than being extracted into a dedicated service. Service classes are introduced when the logic grows complex enough that it would obscure the controller's orchestration responsibility, involves multiple models or external systems, or benefits from reuse across different entry points.

==== Domain-Organized Controllers

Controllers are organized by user domain rather than resource type. Customer-facing controllers reside in `App\Http\Controllers\Customer`, while employee-facing controllers reside in `App\Http\Controllers\Employee`. This organization reflects the architectural separation between user journeys and aligns with route grouping and middleware application.

=== Service Layer Architecture

==== Domain Services

Complex business logic spanning multiple models or external systems is encapsulated in stateless service classes within `App\Services`. The `ReviewService` defined in #source_code_link("app/Services/ReviewService.php") handles review creation with optional image uploads, updates with image coordination, deletion with storage cleanup, and automatic recalculation of parent restaurant ratings. The service returns `ReviewOperationResult` objects encapsulating results and upload errors.

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
