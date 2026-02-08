#import "../../config.typ": code_example, source_code_link

== Media Uploads and Storage Implementation

The implementation of the media system is centered around the seamless integration of Cloudflare R2 via Laravel's filesystem abstraction. This allows the application to handle file uploads through a consistent interface, with all files being stored directly to Cloudflare R2's object storage.

_Note: Code examples in this section have been simplified for clarity. Production code includes additional error handling, logging, and uses configuration constants where appropriate._

=== Filesystem Configuration
The connection to Cloudflare R2 is defined in the filesystem configuration using the `s3` driver with custom endpoint and disabled path-style endpoints for R2's subdomain structure (see `config/filesystems.php`).

=== Image Entity and URL Resolution
Using the Accessor pattern described in @sec:orm, the `Image` model computes full URLs at runtime (see #source_code_link("app/Models/Image.php")). The database stores only relative paths as part of the path-based persistence strategy described in @sec:media-storage; the Accessor resolves these into absolute URLs using the active storage configuration via `Storage::disk('r2')->url($this->image)`.

=== Input Validation and Security
Before file operations, the system validates file properties (image type, max 5MB) and user authorization to prevent malicious uploads and cross-restaurant data access (see #source_code_link("app/Http/Controllers/Employee/EstablishmentController.php")). Authorization is enforced through ownership verification before any operation.

=== Transactional Upload Handling
To prevent orphaned files or broken links, the upload process wraps file storage and database insertion in a transactional workflow. If database insertion fails, the file is actively deleted from storage using a try-catch rollback pattern.

=== Image Deletion Workflow
The deletion process follows a two-step sequence: database record removal followed by storage file deletion. Unlike the upload workflow, deletion does not employ a database transaction, reflecting fundamentally different failure modes between creation and destruction operations.

In the upload case, the file is persisted to R2 before the database transaction begins. If the database operation fails, the catch block must clean up the orphaned file to maintain consistency. In deletion, the database record is removed first (an atomic operation), then the storage file is deleted. If the storage deletion fails, the database record is already gone - the user will not encounter broken image references in the application interface. The trade-off is acceptable: a potential orphaned file in R2 (incurring negligible storage cost) versus user-facing errors from dangling database references. Moreover, database transactions cannot meaningfully wrap external service calls like R2 deletions, as these operations exist outside the transactional boundary and cannot be rolled back atomically.

#code_example[
  The deletion workflow in #source_code_link("app/Http/Controllers/Employee/EstablishmentController.php") removes images from both database and storage.
  ```php
  <?php
  public function destroyImage(Request $request, Image $image): RedirectResponse
  {
      // Verify image belongs to authenticated user's restaurant
      $this->ensureImageBelongsToRestaurant($image, $restaurant);

      // Capture path before database deletion
      $path = $image->image;

      // Delete database record first
      $image->delete();

      // Then delete file from R2 storage
      Storage::disk('r2')->delete($path);

      return back()->with('success', 'Image deleted successfully.');
  }
  ```
]
