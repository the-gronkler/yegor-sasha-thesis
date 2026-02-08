#import "../../config.typ": code_example, source_code_link

== Laravel Backend Architecture <backend-architecture>

The backend of the restaurant ordering system is built on Laravel 11, following a layered architecture that separates concerns across distinct responsibilities: HTTP handling, business logic, data access, and cross-cutting concerns such as authentication and authorization. This section describes the architectural patterns that govern how requests flow through the system, how access control is enforced, and how domain logic is organized.

=== Layered Architecture Overview

The system implements a clear architectural separation between customer-facing and employee-facing modules, reflecting different user journeys, authorization requirements, and interaction patterns. This separation is enforced at the routing level, controller organization, and UI layout structure.

The backend is organized into four primary layers, each with well-defined responsibilities:

/ Routing Layer: Maps incoming HTTP requests to controller actions based on URL patterns and HTTP methods. Routes are organized by domain (authentication, customer operations, employee operations) in separate route files.

/ Controller Layer: Handles HTTP request/response concerns - parsing input, invoking authorization checks, delegating to services, and returning responses. Controllers are kept deliberately thin, avoiding business logic.

/ Service Layer: Encapsulates domain-specific business logic that does not naturally belong to a single model or controller. Services provide stateless methods for complex operations involving multiple models or external systems.

/ Model Layer: Represents domain entities using Eloquent ORM, defining relationships, attribute casting, computed properties, query scopes, and model events.

Cross-cutting concerns (authentication, authorization, validation) are handled through dedicated subsystems that integrate with these layers without creating tight coupling.

=== Authentication Architecture

==== Laravel Sanctum Integration

Authentication is provided by Laravel Sanctum @LaravelSanctumDocs using session-based authentication exclusively, given the web-first nature of the application. Upon successful login, a session is established and maintained through encrypted cookies, with subsequent requests validated against the database-backed session store.

==== Dual User Type Architecture

The system distinguishes between two user types — customers and employees — while maintaining a unified authentication mechanism. The underlying schema (a shared `users` table with separate `customers` and `employees` profile tables) is described in @database-design. From an authentication perspective, this design enables unified login regardless of user type, while supporting divergent functionality based on the associated profile.

The User model defined in #source_code_link("app/Models/User.php") automatically eager-loads both profile relationships via a global scope, ensuring that role checks (`isCustomer()`, `isEmployee()`) execute without additional queries. This determines which middleware groups, controller namespaces, and authorization policies apply to the authenticated user.

=== Request Validation Architecture

The application employs a pragmatic two-tier validation strategy. Most controller methods use inline `$request->validate()` for simple validation rules co-located with handling logic. For complex operations --- such as authentication with rate limiting or registration with custom error formatting --- dedicated Form Request classes encapsulate rules, authorization checks, and custom messages into reusable objects (e.g., #source_code_link("app/Http/Requests/Auth/LoginRequest.php"), which embeds throttling logic within the validation layer for brute-force protection).

This approach balances locality (simple rules remain visible at point of use) with encapsulation (complex validation is extracted into dedicated classes, keeping controllers focused on orchestration).

=== Authorization Architecture

==== Policy-Based Access Control

Access control is implemented through Policy classes, with each major resource (orders, restaurants, menu items, reviews) having an associated policy. Policy methods receive the authenticated user and the target resource, returning a boolean indicating whether the action is permitted.

A global `Gate::before()` callback grants administrators unrestricted access, bypassing all subsequent policy checks. When it returns `null`, normal policy evaluation proceeds.

==== Context-Aware Authorization

Policies evaluate the user's relationship to the resource. The order policy (#source_code_link("app/Policies/OrderPolicy.php")) permits viewing for the owning customer or associated restaurant employees, restricts updates to restaurant employees (for status changes) or customers (only for `InCart` orders), and prevents deletion of placed orders. These checks enforce multi-tenancy boundaries across the application.

Beyond resource policies, custom gates define cross-cutting rules. The `manage-restaurant` gate permits only restaurant administrators to perform management operations such as editing details or managing categories.

=== Controller Architecture

Controllers follow the thin controller pattern @FowlerPEAA2002, focusing exclusively on HTTP-layer concerns: parsing input, invoking authorization, delegating to services, and returning responses. Business logic and side effects are delegated to service classes or model events. When logic is sufficiently simple (straightforward CRUD), it remains in the controller; services are introduced when complexity warrants extraction.

Controllers are organized by user domain (`App\Http\Controllers\Customer`, `App\Http\Controllers\Employee`) rather than resource type, aligning with route grouping and middleware application.

=== Service Layer Architecture

Complex business logic spanning multiple models or external systems is encapsulated in stateless service classes within `App\Services`, receiving dependencies through constructor injection. The `ReviewService` (#source_code_link("app/Services/ReviewService.php")) exemplifies this pattern: it coordinates review creation with optional image uploads to cloud storage (R2), handles updates with image addition and deletion, manages storage cleanup on deletion, and recalculates the parent restaurant's aggregate rating after every mutation. Services return data transfer objects (e.g., `ReviewOperationResult`) that encapsulate results and any errors without exposing service internals.

Cross-cutting utility services, such as the `GeoService` (#source_code_link("app/Services/GeoService.php")), centralize shared technical concerns (session-based location persistence, bounding box calculation, distance formatting) to prevent duplication across consumers.

=== Middleware Architecture

Custom middleware enforces role membership at the route group level, rejecting requests from users lacking the required profile before controller logic executes. This complements policy-based authorization: middleware answers "may this user access employee routes at all?" while policies answer "may this user modify this specific order?" The `HandleInertiaRequests` middleware (#source_code_link("app/Http/Middleware/HandleInertiaRequests.php")) bridges the backend with the React frontend by sharing authentication state, flash messages, and environment configuration with every Inertia response.


=== Summary

The backend architecture combines layered separation (routing, controllers, services, models), unified authentication with profile-based role differentiation, multi-layered authorization (middleware, policies, gates with admin bypass), thin controllers with service delegation, and stateless domain services. These patterns support maintainability, testability, and security for a multi-tenant restaurant ordering system.
