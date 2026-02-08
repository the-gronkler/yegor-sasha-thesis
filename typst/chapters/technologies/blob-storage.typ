#import "../../config.typ": code_example, source_code_link

== Object Storage: Cloudflare R2 <sec:blob-storage>

To handle the storage and delivery of dynamic media assets, specifically restaurant cover images and menu item photos, the system employs Cloudflare R2. This object storage service allows the application to offload static assets from the application server, ensuring that the database remains lightweight by storing only file paths (see @sec:media-storage) and the application servers remain stateless.

=== Justification for Cloudflare R2

Cloudflare R2 was selected as the blob storage backend to align with the constraints of an academic thesis project - specifically, the need to minimize operational costs while maintaining production-grade architecture.

==== Cost Efficiency and Free Tier
The R2 pricing model, particularly its generous free tier, is sufficient to support the entire development, testing, and presentation lifecycle of the thesis without incurring costs. This minimizes the financial barrier to entry for the project implementation. Unlike traditional providers where costs accrue with traffic, R2 allows for predictable, zero-cost operation during the academic evaluation phase.

==== Vendor Independence (Zero Egress)
One of the key considerations for this project's technology choices is the avoidance of vendor lock-in. Cloudflare's zero egress fees policy ensures that data can be migrated out of the platform at any time without financial cost @CloudflareR2Docs. In a real-world production scenario, this grants the freedom to switch providers if requirements change, contrasting with hyperscalers where high egress fees often effectively trap data within their ecosystem.

==== AWS S3 API Compatibility
R2 provides full interface compatibility with the Amazon S3 API @CloudflareR2Docs. This feature allows the application to utilize Laravel's native S3 file storage driver without requiring any custom integration code. Because the application depends on Laravel's Storage facade abstraction rather than R2-specific APIs, the codebase remains provider-agnostic - switching to alternative S3-compatible providers would require only configuration changes without modifying business logic.

==== Edge Integration
As part of the Cloudflare ecosystem, R2 is naturally integrated with the Cloudflare Content Delivery Network (CDN) @CloudflareR2Docs. While not strictly a storage feature, this proximity ensures that assets are cached and delivered from edge locations closer to the user, reducing latency and improving the perceived performance of the application.

=== Comparison with Alternatives

*Amazon S3*: The industry standard for object storage. While it offers unmatched separate feature sets (such as lifecycle policies and Glacier archival), its pricing structure - specifically the charge for outbound data transfer - was deemed prohibitive for this project. The complexity of AWS IAM (Identity and Access Management) also introduces a steeper learning curve compared to R2's simplified token management.

*Local Filesystem Storage*: Storing images directly on the application server's disk was rejected for production. This approach builds state into the server, preventing horizontal scaling (e.g., adding a second server would result in split-brain asset availability) and complicating containerized deployments where the filesystem is ephemeral @TwelveFactorApp.

*DigitalOcean Spaces*: A viable alternative with a fixed pricing model. However, Cloudflare R2's free tier is significantly more generous for smaller workloads, and its "zero egress" policy offers better long-term scalability protection against traffic spikes compared to DigitalOcean's bundled bandwidth limits.
