#import "../../config.typ": code_example, source_code_link

== Backend Framework: Laravel 11

The backend of the system is built on *Laravel 11*, a PHP-based web application framework. This section outlines the rationale behind selecting Laravel and provides an overview of the key framework features employed throughout the project.

=== Framework Selection Rationale

When selecting a backend framework, three primary candidates were evaluated: Laravel (`PHP`), Spring Boot (`Java`), and ASP.NET Core (`C#`). Each framework offers mature ecosystems and robust feature sets, but Laravel was ultimately chosen for the following reasons:

*Rapid Development and Expressiveness*  -  Laravel's syntax is designed for developer productivity. Common tasks such as routing, authentication, and database operations require minimal boilerplate code compared to Spring Boot or ASP.NET Core. For a project with a defined timeline and a small development team, this reduced overhead translates directly into faster iteration cycles.

*Built-in Feature Set*  -  Laravel provides out-of-the-box solutions for authentication (Sanctum), real-time broadcasting (Reverb), queue management, and email handling @LaravelDocs. In contrast, Spring Boot often requires additional configuration or third-party libraries to achieve equivalent functionality, while ASP.NET Core, though feature-rich, demands more explicit setup for similar capabilities.

*Ecosystem Alignment*  -  The decision to use Inertia.js for bridging the backend to a React frontend strongly favored Laravel. Inertia.js was originally developed alongside Laravel and offers first-class integration, including dedicated middleware, shared data patterns, and form handling utilities @InertiaJSDocs. While Inertia adapters exist for other frameworks, the Laravel integration remains the most mature and well-documented.

*Deployment Simplicity*  -  PHP applications deploy straightforwardly on commodity hosting environments @PHP8Release. Unlike Java applications requiring JVM configuration or .NET applications needing runtime installation, PHP runs natively on most web servers with minimal setup. This aligns with the project goal of providing a solution accessible to small restaurant operators without dedicated IT infrastructure.

*Learning Curve and Team Familiarity*  -  The development team possessed prior experience with PHP and Laravel conventions. Leveraging existing knowledge reduced ramp-up time and minimized the risk of architectural missteps common when adopting unfamiliar frameworks.

=== PHP Language Maturity and Framework Ecosystem

A common perception in software development discussions positions PHP as lacking the sophistication of more modern languages. This perception largely stems from earlier PHP versions (pre-7.0), which indeed lacked many features now considered standard in contemporary programming languages @PHP8Release. However, PHP 8.x represents a substantial evolution from its earlier iterations.

Modern PHP 8.x includes strict typing, attributes (annotations), named arguments, match expressions, enumerations, and readonly properties @PHP8Release. These features provide capabilities comparable to those found in Java, `C#`, and other statically-typed languages commonly employed for enterprise web applications. The language's evolution directly addresses the historical limitations that informed earlier criticisms, positioning PHP 8.x as a viable foundation for type-safe, maintainable application development.

When evaluating backend technologies for this project, the language's current feature set and ecosystem maturity proved more relevant than its historical reputation. PHP 8.3 provides the type safety, performance characteristics, and developer tooling necessary for building reliable, maintainable enterprise applications. This modern feature set, combined with Laravel's framework abstractions, reduces the gap between PHP-based development and alternatives built on languages traditionally favored for enterprise systems.

Laravel's documentation and community resources further strengthen the framework's suitability for production applications. The official Laravel documentation provides comprehensive coverage of framework features, architectural patterns, and integration points, with practical examples and detailed API references. This documentation quality reduces dependency on external resources during development and enables developers to implement complex features with minimal research overhead.

The Laravel ecosystem extends beyond official documentation. Laracasts offers structured video tutorials covering framework features and related technologies @Laracasts. Community support channels - including forums, Discord servers, and Stack Overflow - provide accessible problem-solving resources. This ecosystem maturity contributed significantly to the framework selection decision, as comprehensive documentation and active community support reduce development friction and accelerate feature implementation.

=== Queue System Selection

Laravel's built-in *queue system* was selected over external message brokers such as RabbitMQ or Amazon SQS for background task processing. The primary considerations driving this decision were:

*Infrastructure Simplicity*  -  Laravel's queue abstraction supports multiple backends, including database-driven queues that require no additional services @LaravelDocs. For a restaurant ordering application targeting small operators, avoiding external dependencies reduces deployment complexity and operational overhead.

*Framework Integration*  -  The queue system integrates natively with Laravel's event broadcasting, job dispatching, and failure handling. This tight coupling eliminates the need for custom adapters or serialization logic that would be required when using standalone message brokers.

*Scalability Path*  -  While the database driver suffices for moderate workloads, Laravel's queue abstraction allows transparent migration to Redis or dedicated queue services without code changes. This provides a scalability path should throughput requirements increase beyond database queue capacity.

The architectural integration of queues with real-time broadcasting is detailed in @real-time-events.
