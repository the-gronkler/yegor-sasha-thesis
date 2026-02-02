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

=== Authentication with Laravel Sanctum

*Laravel Sanctum* provides the authentication layer. Sanctum offers session-based authentication for web requests and token-based authentication for API consumers, though this project primarily uses the session-based approach given its web-first nature.

The authentication system distinguishes between two user types: customers and employees. Both share a common user record but maintain separate profile tables with role-specific attributes. This design allows unified login while supporting divergent functionality based on user role.

=== Request Validation with Form Requests

All incoming data undergoes validation through *Form Request* classes. These dedicated classes encapsulate validation rules, authorization checks, and error messages for specific operations.

This pattern removes validation logic from controllers, keeping them focused on orchestrating responses. It also centralizes validation rules, making them easier to maintain and test. The system implements rate limiting within login requests to mitigate brute-force attacks.

=== Authorization with Policies

*Policy* classes govern access control throughout the application. Each major resource (orders, restaurants, menu items, reviews) has an associated policy defining which users may perform which actions.

The order policy, for example, ensures that customers can only view and modify their own orders, while employees can only manage orders belonging to their restaurant. These checks occur automatically when controllers invoke authorization methods, providing consistent security enforcement without repetitive conditional logic.

=== Queue System for Background Processing

Laravel's *queue system* handles operations that should not block user requests. When an order status changes, for example, the system dispatches a broadcast event to the queue rather than sending WebSocket messages synchronously. A background worker process consumes these jobs, ensuring responsive user interactions even during high-traffic periods.

The project uses the database queue driver, storing pending jobs in a dedicated table. This approach requires no additional infrastructure beyond the existing database, simplifying deployment for resource-constrained environments.
