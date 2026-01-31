#import "../../config.typ": code_example, source_code_link

== Backend Framework: Laravel 11

The backend of the system is built on *Laravel 11*, a PHP-based web application framework. This section outlines the rationale behind selecting Laravel and provides an overview of the key framework features employed throughout the project.

=== Framework Selection Rationale

When selecting a backend framework, three primary candidates were evaluated: Laravel (`PHP`), Spring Boot (`Java`), and ASP.NET Core (`C#`). Each framework offers mature ecosystems and robust feature sets, but Laravel was ultimately chosen for the following reasons:

*Rapid Development and Expressiveness* — Laravel's syntax is designed for developer productivity. Common tasks such as routing, authentication, and database operations require minimal boilerplate code compared to Spring Boot or ASP.NET Core. For a project with a defined timeline and a small development team, this reduced overhead translates directly into faster iteration cycles.

*Built-in Feature Set* — Laravel provides out-of-the-box solutions for authentication (Sanctum), real-time broadcasting (Reverb), queue management, and email handling. In contrast, Spring Boot often requires additional configuration or third-party libraries to achieve equivalent functionality, while ASP.NET Core, though feature-rich, demands more explicit setup for similar capabilities.

*Ecosystem Alignment* — The decision to use Inertia.js for bridging the backend to a React frontend strongly favored Laravel. Inertia.js was originally developed alongside Laravel and offers first-class integration, including dedicated middleware, shared data patterns, and form handling utilities. While Inertia adapters exist for other frameworks, the Laravel integration remains the most mature and well-documented.

*Deployment Simplicity* — PHP applications deploy straightforwardly on commodity hosting environments. Unlike Java applications requiring JVM configuration or .NET applications needing runtime installation, PHP runs natively on most web servers with minimal setup. This aligns with the project goal of providing a solution accessible to small restaurant operators without dedicated IT infrastructure.

*Learning Curve and Team Familiarity* — The development team possessed prior experience with PHP and Laravel conventions. Leveraging existing knowledge reduced ramp-up time and minimized the risk of architectural missteps common when adopting unfamiliar frameworks.

=== Addressing PHP Misconceptions

A common criticism in developer communities characterizes PHP as an outdated or poorly designed language. While early PHP versions lacked modern language features and encouraged inconsistent practices, PHP 8.x represents a fundamentally different language. Modern PHP includes strict typing, attributes (annotations), named arguments, match expressions, enumerations, and readonly properties — features comparable to those in contemporary languages.

Laravel amplifies these improvements through its documentation and ecosystem. The Laravel documentation is widely regarded as among the best in the web development industry, providing comprehensive guides, practical examples, and clear explanations for every framework feature. This documentation quality significantly reduces onboarding time and enables developers to implement complex features without extensive external research.

The Laravel community further strengthens the ecosystem. Laracasts, the official learning platform, offers thousands of video tutorials covering Laravel and adjacent technologies. The Laravel News portal aggregates ecosystem updates, package announcements, and best practices. Active forums, Discord communities, and Stack Overflow presence ensure that developers can find solutions to most problems within minutes. This community infrastructure rivals or exceeds that of frameworks built on languages traditionally considered more "enterprise-ready."

=== Inertia.js: Server-Side Rendering Bridge

*Inertia.js 2.0* serves as the bridge between the Laravel backend and the React 19 frontend. Unlike traditional API-driven architectures where the backend exposes JSON endpoints consumed by a separate single-page application, Inertia allows the backend to render pages directly while still providing a modern, reactive user experience.

This approach offers several advantages for this project:

- *Simplified Routing* — Routes are defined once on the backend. The frontend receives fully rendered page components with their required data, eliminating the need for duplicate route definitions or client-side data fetching logic.

- *Shared Data Patterns* — Common data such as the authenticated user, flash messages, and shopping cart contents are shared automatically with every page response through Inertia middleware.

- *Form Handling* — Inertia provides utilities for form submission that integrate directly with Laravel's validation system, enabling seamless error display without custom API error handling.

Complementing Inertia, the *Ziggy* package exposes Laravel's named routes to the JavaScript frontend. This allows React components to generate URLs using the same route names defined in Laravel, ensuring consistency between backend and frontend navigation without hardcoding paths.

=== Eloquent ORM and Database Abstraction

*Eloquent*, Laravel's object-relational mapper, handles all database interactions. Each database table corresponds to a model class that encapsulates query logic, relationships, and business rules. Eloquent follows the Active Record pattern, where model instances represent database rows and provide methods for persistence operations.

The syntax prioritizes developer convenience and readability. Finding a restaurant by ID requires only `Restaurant::find($id)`, while filtering restaurants within a geographic radius uses fluent method chaining like `Restaurant::withinRadiusKm($lat, $lng, 10)->get()`. This expressiveness eliminates the verbose query builders or XML mappings common in Java-based ORMs like Hibernate.

The system employs Eloquent's relationship system extensively. Restaurants have many menu items, which in turn have many allergens through a pivot table. Orders belong to both customers and restaurants while containing many order items. These relationships are defined declaratively using methods like `hasMany()`, `belongsTo()`, and `belongsToMany()`, allowing complex queries to be expressed concisely. Accessing related data becomes as simple as property access: `$restaurant->menuItems` automatically loads associated menu items.

To prevent performance degradation from excessive database queries, the codebase uses eager loading via the `with()` method. This technique retrieves related records in a single query rather than issuing separate queries for each relationship, addressing the common N+1 query problem.

==== Database Seeding and Factories

Eloquent integrates with Laravel's *Factory* and *Seeder* system for generating test and development data. Model factories define blueprints for creating realistic fake records using the Faker library. A restaurant factory, for example, generates plausible names, addresses, coordinates, and ratings without manual data entry.

Seeders orchestrate factory execution to populate the database with a complete dataset. The project includes a custom seeder that accepts parameters for customization — running `php artisan mfs --restaurants=50` generates fifty restaurants with associated menu items, employees, customers, and orders. This capability proves invaluable during development and testing, allowing the team to reset the database to a known state within seconds.

=== Authentication with Laravel Sanctum

*Laravel Sanctum* provides the authentication layer. Sanctum offers session-based authentication for web requests and token-based authentication for API consumers, though this project primarily uses the session-based approach given its web-first nature.

The authentication system distinguishes between two user types: customers and employees. Both share a common user record but maintain separate profile tables with role-specific attributes. This design allows unified login while supporting divergent functionality based on user role.

=== Request Validation with Form Requests

All incoming data undergoes validation through *Form Request* classes. These dedicated classes encapsulate validation rules, authorization checks, and error messages for specific operations.

This pattern removes validation logic from controllers, keeping them focused on orchestrating responses. It also centralizes validation rules, making them easier to maintain and test. The system implements rate limiting within login requests to mitigate brute-force attacks.

=== Authorization with Policies

*Policy* classes govern access control throughout the application. Each major resource (orders, restaurants, menu items, reviews) has an associated policy defining which users may perform which actions.

The order policy, for example, ensures that customers can only view and modify their own orders, while employees can only manage orders belonging to their restaurant. These checks occur automatically when controllers invoke authorization methods, providing consistent security enforcement without repetitive conditional logic.

=== Service Classes for Business Logic

Complex operations are delegated to *service classes* rather than residing in controllers or models. The review service, for instance, handles review creation including image uploads to cloud storage, error tracking for failed uploads, and cleanup operations on deletion.

This separation keeps controllers thin and focused on HTTP concerns while encapsulating business logic in testable, reusable units. The geo service similarly abstracts location-based calculations, providing distance computations and bounding box queries used throughout the restaurant discovery features.

=== Queue System for Background Processing

Laravel's *queue system* handles operations that should not block user requests. When an order status changes, for example, the system dispatches a broadcast event to the queue rather than sending WebSocket messages synchronously. A background worker process consumes these jobs, ensuring responsive user interactions even during high-traffic periods.

The project uses the database queue driver, storing pending jobs in a dedicated table. This approach requires no additional infrastructure beyond the existing database, simplifying deployment for resource-constrained environments.
