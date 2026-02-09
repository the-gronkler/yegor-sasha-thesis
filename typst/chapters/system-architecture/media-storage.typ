#import "../../config.typ": code_example, source_code_link

== Media Asset Management <sec:media-storage>

The architecture treats media assets (restaurant covers, menu item photos) as external resources, decoupling their storage from the application runtime. No user-generated content is persisted on the application server, maintaining the stateless design discussed in @sec:blob-storage.

=== Storage Abstraction Layer
The interactions with the storage backend are mediated through Laravel's filesystem abstraction. This design adheres to the Dependency Inversion Principle: high-level modules (Controllers) depend on the Storage facade abstraction rather than concrete implementations such as the Amazon S3 SDK. All file operations (upload, retrieval, deletion) target the configured storage disk through this facade, ensuring consistent behavior across the application lifecycle.

=== Architecture of the Image Entity
To manage the metadata associated with creating and displaying images, the system implements two complementary entities. The primary `Image` entity#footnote[#source_code_link("app/Models/Image.php")] manages restaurant and menu item media through a dedicated `images` table linked to restaurants via a `restaurant_id` foreign key. Menu items can optionally reference a specific image through an `image_id` foreign key on the `menu_items` table. A separate `ReviewImage` entity#footnote[#source_code_link("app/Models/ReviewImage.php")] manages customer-uploaded review photos through the `review_images` table, linked to individual reviews via a `review_id` foreign key. This dual-entity design separates restaurant-managed media (curated by staff) from user-generated content (uploaded by customers), allowing different storage policies and access controls for each category.

*Path-Based Persistence*: The database stores only the relative path (key) of the file within the storage bucket (e.g., `restaurants/12/cover.jpg`), rather than the absolute URL. This design choice prevents domain leakage into the database and allows the Storage Provider's endpoint to change (e.g., moving to a new CDN domain) without requiring a massive database migration to rewrite millions of rows.

*Dynamic URL Generation*: The absolute public URL for an image is generated at runtime via an Accessor on the model. When the frontend requests an image entity, the API response includes a computed `url` property. The Model interacts with the Storage Abstraction Layer to resolve the current public endpoint for the stored path.
