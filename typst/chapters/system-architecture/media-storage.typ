#import "../../config.typ": code_example, source_code_link

== Media Asset Management

The architecture treats media assets (restaurant covers, menu item photos) as external resources, decoupling their storage from the application runtime. This stateless design ensures that the application servers remain horizontally scalable, as they do not persist user-generated content on their local file systems.

=== Storage Abstraction Layer
The interactions with the storage backend are mediated through a File System Abstraction Layer (Laravel Flysystem). This architectural component provides a unified interface for file operations, isolating the business logic from specific storage drivers.

*Environment Adaptability*: The system is configured to swap storage drivers dynamically based on the environment.
- *Local Environment*: Uses the local disk driver for rapid development and offline testing.
- *Production Environment*: Automatically switches to the `r2` driver (S3-compatible) via environment variables, without any code modifications.

This abstraction adheres to the Dependency Inversion Principle, where high-level modules (Controllers) depend on abstractions (Storage Facade), not concrete implementations (Amazon S3 SDK).

=== Architecture of the Image Entity
To manage the metadata associated with creating and displaying images, the system implements a unified `Image` entity#footnote[#source_code_link("app/Models/Image.php")]. A dedicated `images` table serves as a central registry for all media assets, linked to domain entities (Restaurants, Menu Items) via foreign keys.

*Path-Based Persistence*: The database stores only the relative path (key) of the file within the storage bucket (e.g., `restaurants/12/cover.jpg`), rather than the absolute URL. This design choice prevents domain leakage into the database and allows the Storage Provider's endpoint to change (e.g., moving to a new CDN domain) without requiring a massive database migration to rewrite millions of rows.

*Dynamic URL Generation*: The absolute public URL for an image is generated at runtime via a "Virtual Attribute" (Accessor) on the model. When the frontend requests an image entity, the API response includes a computed `url` property. The Model interacts with the Storage Abstraction Layer to resolve the current public endpoint for the stored path.
