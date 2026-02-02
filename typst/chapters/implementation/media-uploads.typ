#import "../../config.typ": code_example, source_code_link

== Media Uploads and Storage Implementation

The implementation of the media system is centered around the seamless integration of Cloudflare R2 via Laravel's filesystem abstraction. This allows the application to handle file uploads as if they were local files, while automatically pushing them to the edge storage network in production.

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

=== Image Entity and Virtual Attributes
The `Image` model serves as the logic layer for media assets. A key implementation detail is the utilization of a Laravel "Accessor" to dynamically generate full URLs. This ensures that the database remains agnostic of the actual storage domain (e.g., `pub-REDACTED.r2.dev`), allowing for easier migration or CDN changes in the future.

#code_example[
  The `getUrlAttribute` accessor in #source_code_link("app/Models/Image.php") resolves the full URL based on the active storage disk.
  ```php
  public function getUrlAttribute()
  {
      // If the image path is already a full URL (legacy or external), return it.
      if (str_starts_with($this->image, 'http')) {
          return $this->image;
      }

      // Resolve the URL using the configured storage disk
      return Storage::disk('r2')->url($this->image);
  }
  ```
]

=== Transactional Upload Handling
To prevent "orphaned" files (files stored in R2 but not recorded in the database) or "broken links" (database records with no corresponding file), the upload process is wrapped in a transactional workflow. If the database insertion fails, the file is actively rolled back (deleted) from storage.

#code_example[
  The transactional upload logic in the Controller handles failures gracefully.
  ```php
  public function storeImage(Request $request)
  {
      $path = $request->file('image')->store('restaurants');

      try {
          DB::transaction(function () use ($restaurant, $path) {
              Image::create([
                  'restaurant_id' => $restaurant->id,
                  'image' => $path,
                  // ... validation inputs
              ]);
          });
      } catch (\Throwable $e) {
          // Rollback: Delete file if DB insert fails
          Storage::delete($path);
          throw $e;
      }
  }
  ```
]
