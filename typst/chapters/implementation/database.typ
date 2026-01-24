#import "../../config.typ": code_example, source_code_link

== Database Implementation

The implementation of the persistence layer conforms to the architectural decisions outlined in the System Architecture chapter, specifically adhering to the Active Record pattern via Laravel's Eloquent ORM. The implementation strategy prioritizes three non-functional requirements: data integrity, geospatial query performance, and strict strict type safety within the domain boundary.

The database schema and its interactions are defined entirely through valid PHP code ("Code-First"), ensuring that the persistence state is version-controlled and reproducible across development, testing, and production environments.

=== Schema Engineering and Version Control

The database schema is managed using Laravel's migration system, which provides a programmatic interface for defining table structures, constraints, and indices. This approach prevents "schema drift" by treating database modifications as atomic, reversible deployment steps.

==== Migration Strategy
Each modification to the database structure is captured in a discrete migration class. The implementation uses a timestamp-based naming convention to ensure that migrations run in a deterministic order.

For instance, the core `restaurants` table definition explicitly selects double-precision floating-point types for geospatial coordinates rather than standard decimals. This design choice aligns with the requirement for high-fidelity mapping, where standard coordinate truncation could introduce significant positional errors.

#code_example[
  The initial migration defines the schema with strict type definitions and nullable constraints for optional metadata.

  ```php
  <?php
  public function up(): void
  {
      Schema::create('restaurants', function (Blueprint $table) {
          $table->id();
          $table->string('name');
          $table->string('address');
          // Double precision is strictly required for avoiding
          // floating point drift in coordinate calculations
          $table->double('latitude')->nullable();
          $table->double('longitude')->nullable();
          $table->string('description', 512)->nullable();
          $table->double('rating')->nullable();
          $table->timestamps();
      });
  }
  ```
]

==== Post-Deployment Schema Evolution
As the application requirements evolved, the schema was effectively refactored through incremental migrations. A critical performance optimization was the introduction of spatial indices to the restaurant table. Rather than modifying the original migration (which would require a destructive database reset), a dedicated evolution migration was implemented.

This migration applies a composite, high-performance B-Tree index structure to the coordinate columns. This structure dramatically accelerates the bounding-box pre-filtering phase of the geospatial query pipeline.

#code_example[
  The schema evolution applies targeted indexing without altering the table's primary structure.

  ```php
  <?php
  public function up(): void
  {
      Schema::table('restaurants', function (Blueprint $table) {
          // B-Tree indexing for range queries (min/max lat/lng)
          $table->index(['latitude', 'longitude'], 'geo_composite_index');
      });
  }
  ```
]

=== Domain Modelling and Active Record Implementation

The application leverages the Eloquent ORM to map database tables to object-oriented domain entities. The implementation moves beyond simple CRUD wrappers, using the models to encapsulate business rules, relationship traversal logic, and dynamic attribute calculation.

==== Identity Composition Strategy
A key implementation detail is the handling of user roles. Rather than using Single Table Inheritance (which often leads to sparse tables with many null columns) or polymorphic relations (which forfeit foreign key integrity), the system implements a *Shared Primary Key* strategy.

The `User` model acts as the aggregate root for identity, dealing with authentication and authorization. The `Customer` and `Employee` models represent distinct roles and are stored in separate tables. Crucially, these extension tables share the exact same primary key ID as the parent `User` record, effectively functioning as a partitioned vertical extension of the user entity.

#code_example[
  The `Customer` model explicitly disables auto-incrementing IDs to enforce the shared primary key constraint.

  ```php
  <?php
  class Customer extends Model
  {
      // The primary key is the user_id, which is not auto-incrementing
      protected $primaryKey = 'user_id';
      public $incrementing = false;

      public function user(): BelongsTo
      {
          return $this->belongsTo(User::class);
      }
  }
  ```
]

To make this physical separation transparent to the application logic, the `User` model registers a Global Scope in its `boot` lifecycle method. This scope forces the ORM to automatically eager-load the role relationships whenever a user context is retrieved, effectively re-assembling the "Unified Identity" in memory.

#code_example[
  The `User` model #source_code_link("app/Models/User.php") applies a global scope to ensure the role composition is always available, abstracting the underlying table split.

  ```php
  <?php
  protected static function boot()
  {
      parent::boot();

      static::addGlobalScope('withRelations', function ($builder) {
          // Automatically join/load the split identity tables
          $builder->with(['customer', 'employee']);
      });
  }
  ```
]

==== Rich Association Implementation
The system handles complex many-to-many relationships by elevating the intermediate table to a first-class domain citizen. This is exemplified by the `OrderItem` model.

Unlike a standard pivoting relationship (which returns a generic `stdClass` or array), the `OrderItem` is a full Eloquent model. It extends the internal `Pivot` class but defines its own relationships back to the parent `Order` and `MenuItem`. This allows the implementation to place validation logic, state management (e.g., locking line item prices at the time of purchase), and accessors strictly within the association itself.

#code_example[
  The `OrderItem` #source_code_link("app/Models/OrderItem.php") encapsulates the state of the relationship, such as quantity, while maintaining traversal capability.

  ```php
  <?php
  use Illuminate\Database\Eloquent\Relations\Pivot;

  class OrderItem extends Pivot
  {
      protected $table = 'order_items';

      protected $fillable = [
          'order_id',
          'menu_item_id',
          'quantity',
      ];

      public function menuItem(): BelongsTo
      {
          return $this->belongsTo(MenuItem::class);
      }
  }
  ```
]

==== Explicit Polymorphism for Media Resources
For handling images, the implementation deliberately avoids the standard "Polymorphic Relation" (`morphable_id`, `morphable_type`) pattern often found in Laravel applications. While standard polymorphism is flexible, it breaks strict referential integrity (foreign keys cannot enforce constraints across multiple target tables).

Instead, the `Image` model implements a "Nullable Foreign Key" strategy. The table contains explicit `restaurant_id` and `menu_item_id` columns. This allows the database engine to enforce strict foreign key constraints, ensuring that an image cannot be orphaned if its parent entity is deleted.

The `Image` model also encapsulates the complexity of resource retrieval. A virtual accessor (`getUrlAttribute`) dynamically generates the signed URL for the cloud storage provider (Cloudflare R2), isolating the storage implementation details from the view layer.

#code_example[
  The `Image` model #source_code_link("app/Models/Image.php") abstracts the storage logic using an attribute accessor.

  ```php
  <?php
  public function getUrlAttribute()
  {
      // Abstraction of the Cloudflare R2 storage disk
      return Storage::disk('r2')->url($this->image);
  }
  ```
]

=== Geospatial Query Implementation

The implementation of geospatial features required a rigorous approach to query construction to ensure scalability on standard hardware.

==== Server-Side Spatial Calculation
To avoid fetching all restaurant records into PHP memory for filtering, the system pushes the distance calculation down into the MariaDB engine. The `Restaurant` model implements a reusable scope, `scopeWithDistanceTo`, which utilizes the native `ST_Distance_Sphere` function.

This function provides high-precision calculation accounting for the Earth's curvature (haversine formula), which is significant at the city scales the application operates within. The scope injects a computed `distance` column into the result set, allowing the application to sort and filter by this derived value entirely within the database engine.

#code_example[
  The `Restaurant` model #source_code_link("app/Models/Restaurant.php") leverages raw SQL expression injection to perform geometric math at the database level.

  ```php
  <?php
  public function scopeWithDistanceTo($query, float $lat, float $lng)
  {
      // ST_Distance_Sphere is native to MariaDB and MySQL 5.7+
      $sql = "ST_Distance_Sphere(POINT(longitude, latitude), POINT(?, ?)) as distance";

      return $query
          ->selectRaw($sql, [$lng, $lat])
          ->orderBy('distance');
  }
  ```
]

=== Database Seeding and Synthetic Data Generation

To facilitate rigorous testing and UI development without manual data entry, the implementation includes a sophisticated seeding infrastructure. This system allows for the deterministic generation of thousands of relational records, simulating a production-grade dataset state.

==== Orchestration and Determinism
The seeding process is not a monolithic script but an orchestrated pipeline managed by the `DatabaseSeederService`. This separation of concerns allows specific domains (like "only static data" or "only a specific restaurant") to be seeded independently during integration tests.

The implementation prioritizes determinism. Factories use fixed seeds where possible, ensuring that visual regression tests run against an identical data topology on every execution, preventing "flaky" tests caused by random data variations.

#code_example[
  The `DatabaseSeeder` orchestrates the flow, ensuring site-wide constraints (like the existence of an Admin user) are satisfied before delegating to domain-specific seeders.

  ```php
  <?php
  public function run(DatabaseSeederService $service): void
  {
      // 1. Establish Invariant State (Admin)
      $service->createAdminUser();

      // 2. Populate Dictionary Tables (Enums)
      $this->call([
          OrderStatusSeeder::class,
          AllergenSeeder::class,
      ]);

      // 3. Generate Domain Graph (Restaurants, Menus, Orders)
      $this->call(RestaurantSeeder::class);
  }
  ```
]

==== Dictionary Data and Enums
For static dictionary tables, the seeders bridge the gap between PHP Enumerations and Database rows. The implementation iterates over enum cases to ensure that the database reference table is perfectly synchronized with the application code constants.

#code_example[
  The `OrderStatusSeeder` uses `updateOrCreate` to enforce ID consistency between the PHP Enum and the database `id` column.

  ```php
  <?php
  foreach (OrderStatusEnum::cases() as $status) {
      OrderStatus::updateOrCreate(
          ['id' => $status->value], // Rigidly bind ID to Enum int value
          ['name' => $status->label()]
      );
  }
  ```
]

==== Relational Integrity in Factories
A significant complexity in generating synthetic data is maintaining semantic validity. For example, an `Order` appearing in the system must only contain `MenuItems` that actually belong to the `Restaurant` where the order was placed.

The implementation handles this via `afterCreating` hooks in the factories. Instead of simple random assignment, the factory inspects the parent relationship graph to select valid child candidates.

#code_example[
  The `OrderFactory` logic ensures that an order only consists of items available at the chosen restaurant, preventing impossible data states.

  ```php
  <?php
  public function configure(): static
  {
      return $this->afterCreating(function (Order $order) {
          // 1. Retrieve the menu specific to this restaurant
          $availableItems = $order->restaurant->menuItems;

          // 2. Randomly select a subset to attach
          if ($availableItems->isNotEmpty()) {
              $order->menuItems()->attach(
                  $availableItems->random(rand(1, 3))->pluck('id'),
                  ['quantity' => rand(1, 4)]
              );
          }
      });
  }
  ```
]

==== Mathematical Generation: Box-Muller Transform
To validate the performance of the spatial indices, the seeding implementation required the generation of realistic, clustered data sets rather than pure random noise. The `RestaurantFactory` implements the *Box-Muller transform*, a mathematical algorithm that generates identifying normally distributed pairs of numbers from a uniform source.

This allows the seeder to create "clusters" of restaurants around specific city centers, realistically simulating high-density urban zones vs. sparse outer suburbs. This distribution is critical for stress-testing the B-Tree composite indices.

#code_example[
  The `RestaurantFactory` #source_code_link("database/factories/RestaurantFactory.php") implements the Box-Muller transform to simulate realistic urban density.

  ```php
  <?php
  private function gaussianRandom(float $mean, float $stddev): float
  {
      // Box-Muller transform for normal distribution
      do {
          $u1 = mt_rand() / mt_getrandmax();
      } while ($u1 <= 0.0 || $u1 >= 1.0);

      $u2 = mt_rand() / mt_getrandmax();

      // Transform uniform randoms to standard normal variables
      $z0 = sqrt(-2.0 * log($u1)) * cos(2.0 * M_PI * $u2);

      return $z0 * $stddev + $mean;
  }
  ```
]

==== Visual Data Simulation
Testing the UI requires realistic imagery, but storing thousands of files is impractical. The implementation simulates a polymorphic media relationship using the `ImageFactory`. Rather than uploading files, records are generated pointing to a carefully curated pool of high-quality CDN assets.

The seeder attaches these image records to Restaurants and Menu Items using a "Pool and Distribute" strategy, ensuring every UI card has a high-fidelity cover image without bloating the development environment storage.

==== Automated Environment Provisioning
To streamline the development workflow, a custom Artisan command `mfs` ("Migrate, Fresh, Seed") was implemented. Unlike the standard Laravel seeding command which relies on hardcoded environment variables or default factory counts, `mfs` provides a parametric interface for defining the dataset topology at runtime.

This command serves as the primary entry point for environment resets, allowing developers to generate specific scenarios (e.g., "Heavy Load" with 10,000 orders vs "Minimal" for rapid UI iteration) without modifying configuration files. It specifically overrides the default migration path to ensure all modular migrations are discovered and executes the `DatabaseSeederService` methods with validated CLI arguments.

#code_example[
  The `Mfs` command #source_code_link("app/Console/Commands/Mfs.php") exposes granular control over the data generation volume, validating inputs before triggering the provisioning pipeline.

  ```php
  <?php
  protected $signature = 'mfs
                         {--restaurants= : Number of restaurants to seed}
                         {--customers= : Number of customers to seed}
                         {--orders-per-customer= : Number of orders per customer}';

  public function handle(): void
  {
      // Dynamic injection of volumetric parameters into the service layer
      $service->seedRestaurants(
          (int) $this->option('restaurants'),
          (float) $this->option('radius')
      );
  }
  ```
]

=== Transactional Integrity and Security

The implementation enforces data consistency through strict transaction management and input sanitization policies.

==== Atomic Provisioning Workflow
The registration process requires the simultaneous creation of a `User` record and its corresponding role entity (`Customer` or `Employee`). To prevent partial failure states (e.g., a User created without a Customer profile), the implementation wraps these operations in a Database Transaction.

Using the `DB::transaction` closure, the system ensures that the set of operations is atomic: either all records are committed to the database, or none are. This guarantees the referential integrity of the "Identity Composition" strategy described earlier.

#code_example[
  The registration flow utilises an atomic transaction block to guarantee consistency across the split identity tables.

  ```php
  <?php
  DB::transaction(function () use ($userData, $roleData) {
      // 1. Create Base User
      $user = User::create($userData);

      // 2. Create Role Profile (linked by ID)
      Customer::create([
          'user_id' => $user->id,
          ...$roleData
      ]);
  });
  ```
]

==== Mass Assignment Protection
To mitigate Mass Assignment vulnerabilities, every model in the implementation strictly defines a `$fillable` property. This "allow-list" approach ensures that sensitive columns—such as `is_admin`, `remember_token`, or `email_verified_at`—cannot be maliciously injected via HTTP request payloads.

#code_example[
  The `User` model allow-list strictly limits which attributes can be bulk assigned, excluding the `is_admin` flag.

  ```php
  <?php
  class User extends Authenticatable
  {
      protected $fillable = [
          'name',
          'email',
          'password',
      ];
      // 'is_admin' is implicitly protected by exclusion
  }
  ```
]

The implementation explicitly excludes administrative flags from these lists, forcing the developer to set them via explicit setters or specific administrative controllers, thus providing a code-level defense layer against privilege escalation attacks.

=== Performance Optimization and Composite Scoring

A specific challenge of the implementation was the generation of the "Recommended Restaurants" feed. This requires sorting entities by a weighted score derived from three heterogeneous factors: aggregate rating, popularity (review volume), and user proximity.

Processing this in the application layer (PHP) would require an $O(N log N)$ sorting operation on the entire dataset. Instead, the implementation utilizes a "Composite Score" SQL injection directly in the `MapController`.

==== Database-Side Composite Scoring
The scoring logic is implemented as a raw SQL expression that normalizes the three metrics and applies weighting coefficients.
- *Rating (50%)*: Direct linear contribution.
- *Popularity (30%)*: A logarithmic dampening function `LOG10(count)` is applied to review counts. This prevents a statistically insignificant distinction (e.g., 5000 vs 5001 reviews) from outweighing quality metrics, while still distinguishing established venues from new ones.
- *Proximity (20%)*: An inverse linear decay function.

#code_example[
  The `MapController` #source_code_link("app/Http/Controllers/Customer/MapController.php") injects the mathematical scoring model directly into the query builder.

  ```php
  <?php
  $query->selectRaw(
      '(
          (COALESCE(rating, 0) / 5.0 * 50) +           -- Quality Component
          (LEAST(30, LOG10(reviews_count + 1) * 10)) + -- 30% Weight: Review Volume
          (GREATEST(0, 20 * (1 - (distance / 20))))    -- Proximity Component
      ) as composite_score'
  );

  $query->orderByRaw('composite_score DESC');
  ```
]

==== Payload Optimization
To minimize network latency, especially for the mobile context, the implementation adheres to a strict "Column Projection" policy. The `select()` statement is used to retrieve only the columns necessary for the UI card presentation, significantly reducing the JSON payload size and memory usage compared to a generic `SELECT *`.

Additionally, user-specific state—such as whether a restaurant is "Favorited"—is resolved via an optimized `LEFT JOIN` pattern. Rather than executing an N+1 query (checking the favorite status for each of the 50 results individually), the controller joins the `favorite_restaurants` table on the current user ID. This collapses the operation into a single constant-time check within the main database query.

#code_example[
  The "Favorited" status is efficiently resolved using a conditional join, avoiding N+1 query performance pitfalls.

  ```php
  <?php
  if ($customerId) {
      $query->leftJoin('favorite_restaurants', function ($join) use ($customerId) {
          $join->on('restaurants.id', '=', 'favorite_restaurants.restaurant_id')
               ->where('favorite_restaurants.customer_user_id', '=', $customerId);
      })
      ->addSelect(\DB::raw('CASE WHEN favorite_restaurants.restaurant_id IS NOT NULL
                           THEN 1 ELSE 0 END as is_favorited'));
  }
  ```
]
#source_code_link("app/Http/Controllers/Customer/MapController.php") provides the complete context for these optimizations.
