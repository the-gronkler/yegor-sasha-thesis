#import "../../config.typ": code_example, source_code_link

== Media Uploads and Storage Implementation

The implementation of the media system is centered around the seamless integration of Cloudflare R2 via Laravel's filesystem abstraction. This allows the application to handle file uploads through a consistent interface, with all files being stored directly to Cloudflare R2's object storage.

=== Filesystem Configuration
The connection to Cloudflare R2 is defined in the filesystem configuration. To ensure compatibility with the R2 API, the `s3` driver is utilized with a custom endpoint. The configuration explicitly disables path-style endpoints to work correctly with Cloudflare's sub-domain structure.

#code_example[
  The configuration for the R2 disk in `config/filesystems.php`.
  ```php
  'r2' => [
      'driver' => 's3',
      'key' => env('CLOUDFLARE_R2_ACCESS_KEY_ID'),
      'secret' => env('CLOUDFLARE_R2_SECRET_ACCESS_KEY'),
      'region' => 'auto',
      'bucket' => env('CLOUDFLARE_R2_BUCKET'),
      'url' => env('CLOUDFLARE_R2_URL'),
      'endpoint' => env('CLOUDFLARE_R2_ENDPOINT'),
      'use_path_style_endpoint' => false,
  ],
  ```
]

=== Image Entity and Virtual Attributes (Accessors)
The `Image` model serves as the logic layer for media assets. A key implementation detail is the utilization of a virtual attribute - implemented in Laravel as an "Accessor" - to dynamically generate full URLs at runtime. Virtual attributes are computed properties that do not exist as physical database columns but are calculated on-demand when the model is accessed. This pattern ensures that the database remains agnostic of the actual storage domain (e.g., `pub-REDACTED.r2.dev`), allowing for easier migration or CDN changes in the future.

#code_example[
  The `getUrlAttribute` accessor in #source_code_link("app/Models/Image.php") resolves the full URL based on the active storage disk.
  ```php
  public function getUrlAttribute()
  {
      // If the image path is already a full URL (legacy or external), return it.
      if (str_starts_with($this->image, 'http://') || str_starts_with($this->image, 'https://')) {
          return $this->image;
      }

      // Resolve the URL using the configured R2 storage disk
      return Storage::disk('r2')->url($this->image);
  }
  ```
]

=== Input Validation and Security
Before any file operations occur, the system validates both the file properties and user authorization. Input validation prevents malicious file uploads and ensures data integrity, while authorization checks prevent cross-restaurant data access.

#code_example[
  Validation rules in #source_code_link("app/Http/Controllers/Employee/EstablishmentController.php") enforce strict constraints on uploaded files.
  ```php
  $validated = $request->validate([
      'image' => ['required', 'image', 'max:5120'],  // 5MB maximum
      'description' => ['nullable', 'string', 'max:255'],
      'is_primary' => ['boolean'],
  ]);
  ```
]

The `image` validation rule ensures that only valid image files (JPEG, PNG, GIF, SVG, WebP) are accepted. The 5MB size limit balances image quality with storage costs and upload performance. Authorization is enforced through ownership verification - before any operation (upload, delete, update), the system confirms that the image belongs to the authenticated user's restaurant, returning a 403 Forbidden status if ownership cannot be established.

=== Transactional Upload Handling
To prevent "orphaned" files (files stored in R2 but not recorded in the database) or "broken links" (database records with no corresponding file), the upload process is wrapped in a transactional workflow. If the database insertion fails, the file is actively rolled back (deleted) from storage.

#code_example[
  The transactional upload logic in the Controller handles failures gracefully.
  ```php
  public function storeImage(Request $request)
  {
      // Upload file to R2 storage (explicit disk specification)
      $path = $request->file('image')->store('restaurants', 'r2');

      try {
          DB::transaction(function () use ($validated, $restaurant, $path) {
              Image::create([
                  'restaurant_id' => $restaurant->id,
                  'image' => $path,
                  'description' => $validated['description'] ?? null,
                  'is_primary_for_restaurant' => $validated['is_primary'] ?? false,
              ]);
          });
      } catch (\Throwable $e) {
          // Rollback: Delete file from R2 if DB insert fails
          Storage::disk('r2')->delete($path);
          throw $e;
      }
  }
  ```
]

=== Image Deletion Workflow
The deletion process follows a deliberate two-step sequence: database record removal followed by storage file deletion. Unlike the upload workflow, deletion does not employ a database transaction. This design reflects fundamentally different failure modes between creation and destruction operations.

In the upload case, the file is persisted to R2 before the database transaction begins. If the database operation fails, the catch block must clean up the orphaned file to maintain consistency. In deletion, the database record is removed first (an atomic operation), then the storage file is deleted. If the storage deletion fails, the database record is already gone - the user will not encounter broken image references in the application interface. The trade-off is acceptable: a potential orphaned file in R2 (incurring negligible storage cost) versus user-facing errors from dangling database references. Moreover, database transactions cannot meaningfully wrap external service calls like R2 deletions, as these operations exist outside the transactional boundary and cannot be rolled back atomically.

#code_example[
  The deletion workflow in #source_code_link("app/Http/Controllers/Employee/EstablishmentController.php") removes images from both database and storage.
  ```php
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
