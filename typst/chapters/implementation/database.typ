#import "../../config.typ": code_example, source_code_link

== Database Implementation

The database implementation translates the schema design from @database-design and persistence architecture from @data-persistence into concrete migration files, model classes, and seeding logic. This section details the migration structure, relationship definitions, query scopes, and seeding strategies that establish the operational database layer.

=== Migration Structure and Execution Order

Database migrations are stored in #source_code_link("database/migrations") as timestamped PHP class files. The timestamp prefix determines execution order, ensuring that tables are created before their dependent foreign key constraints.

Laravel migrations use anonymous class syntax extending `Migration` base class, with `up()` and `down()` methods defining forward and rollback operations respectively. The Schema facade provides a fluent API for table definition.

#code_example[
  The users table migration establishes the authentication principal with standard Laravel conventions.

  ```php
  <?php
  return new class extends Migration
  {
      public function up(): void
      {
          Schema::create('users', function (Blueprint $table) {
              $table->id();
              $table->string('name');
              $table->string('email');
              $table->timestamp('email_verified_at')->nullable();
              $table->string('password');
              $table->boolean('is_admin')->default(false);
              $table->rememberToken();
              $table->timestamps();
          });
      }

      public function down(): void
      {
          Schema::dropIfExists('users');
      }
  };
  ```
]

The `id()` method creates an auto-incrementing unsigned big integer primary key. The `is_admin` boolean distinguishes site administrators from regular users. The `rememberToken()` column stores persistent login session tokens. The `timestamps()` method adds `created_at` and `updated_at` columns with automatic maintenance. Note that the `surname` field is added in a later migration following the evolution of requirements.

=== Role-Specific Profile Tables

The disjoint role inheritance pattern described in @database-design materializes through separate `customers` and `employees` tables with foreign keys to `users`.

#code_example[
  The customers table links user authentication to customer-specific data.

  ```php
  <?php
  Schema::create('customers', function (Blueprint $table) {
      $table->unsignedBigInteger('user_id')->primary();
      $table->string('payment_method_token')->nullable();
      $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
      $table->timestamps();
  });
  ```
]

The customers table uses `user_id` as the primary key rather than a separate auto-incremented id, enforcing the one-to-one constraint at the schema level. Cascade deletion removes customer profiles when the associated user is deleted.

#code_example[
  The employees table similarly extends users with restaurant association.

  ```php
  <?php
  Schema::create('employees', function (Blueprint $table) {
      $table->unsignedBigInteger('user_id')->primary();
      $table->unsignedBigInteger('restaurant_id');
      $table->boolean('is_admin');
      $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
      $table->foreign('restaurant_id')->references('id')->on('restaurants')->onDelete('cascade');
      $table->timestamps();
  });
  ```
]

The employees table follows the same primary key strategy. The `is_admin` boolean enables role-based permissions within a restaurant context, and cascade deletion on the `restaurant_id` foreign key prevents orphaned employee records.

=== Menu Hierarchy Implementation

The menu structure implements the transitive categorization strategy through `food_types` and `menu_items` tables with enforced foreign keys.

#code_example[
  The food_types (categories) table establishes the categorization layer.

  ```php
  <?php
  Schema::create('food_types', function (Blueprint $table) {
      $table->id();
      $table->string('name');
      $table->unsignedBigInteger('restaurant_id')->nullable();
      $table->foreign('restaurant_id')->references('id')
          ->on('restaurants')->onDelete('set null');
      $table->timestamps();
  });
  ```
]

#code_example[
  Menu items link to food types, inheriting restaurant association.

  ```php
  <?php
  Schema::create('menu_items', function (Blueprint $table) {
      $table->id();
      $table->string('name');
      $table->double('price');
      $table->string('description', 512)->nullable();
      $table->unsignedBigInteger('food_type_id');
      $table->foreign('food_type_id')->references('id')->on('food_types')->onDelete('cascade');
      $table->timestamps();
  });
  ```
]

The menu_items table includes a direct `restaurant_id` foreign key for efficient querying, in addition to the `food_type_id` relationship. Price uses `double()` for numeric storage. The `is_available` boolean is added in a subsequent migration, following the evolution of feature requirements and demonstrating the incremental schema modification approach.

=== Many-to-Many Relationship Pivots

Stateless many-to-many relationships use pivot tables with composite unique constraints preventing duplicate associations.

#code_example[
  The allergen association table links menu items to allergen definitions.

  ```php
  <?php
  Schema::create('menu_item_allergen', function (Blueprint $table) {
      $table->unsignedBigInteger('menu_item_id');
      $table->unsignedBigInteger('allergen_id');
      $table->primary(['menu_item_id', 'allergen_id']);
      $table->foreign('menu_item_id')->references('id')
          ->on('menu_items')->onDelete('cascade');
      $table->foreign('allergen_id')->references('id')
          ->on('allergens')->onDelete('cascade');
      $table->timestamps();
  });
  ```
]

No separate `id` column exists on this table — the composite primary key on `['menu_item_id', 'allergen_id']` enforces uniqueness and prevents duplicate associations.

Stateful associations such as order items carry additional data columns beyond the foreign key pair.

#code_example[
  Order items store the quantity of each menu item associated with an order.

  ```php
  <?php
  Schema::create('order_items', function (Blueprint $table) {
      $table->unsignedBigInteger('order_id');
      $table->unsignedBigInteger('menu_item_id');
      $table->integer('quantity');
      $table->primary(['order_id', 'menu_item_id']);
      $table->foreign('order_id')->references('id')->on('orders')->onDelete('cascade');
      $table->foreign('menu_item_id')->references('id')->on('menu_items')->onDelete('cascade');
      $table->timestamps();
  });
  ```
]

The order_items table uses a composite primary key `['order_id', 'menu_item_id']` rather than a separate auto-incrementing id. This design enforces that each menu item can appear at most once per order, with the `quantity` column indicating how many. The current implementation retrieves menu item prices at order display time rather than storing historical price snapshots, prioritizing simplicity over audit-trail completeness.

=== Geospatial Column Definition

Spatial data uses standard double-precision float columns as described in @database-design, with explicit indexes for bounding box queries.

#code_example[
  Restaurant locations use nullable double-precision coordinates.

  ```php
  <?php
  Schema::create('restaurants', function (Blueprint $table) {
      $table->id();
      $table->string('name');
      $table->string('address');
      $table->double('latitude')->nullable();
      $table->double('longitude')->nullable();
      $table->string('description', 512)->nullable();
      $table->double('rating')->nullable();
      $table->timestamps();
  });
  ```
]

The description uses a `string(512)` constraint rather than unbounded text for predictable storage. Separate indexes on `latitude` and `longitude` are added in a later migration to accelerate the bounding box queries described in @database-design. The `opening_hours` column is similarly introduced in a subsequent migration as requirements evolve.

=== Model Relationship Definitions

Eloquent relationships translate foreign key constraints into traversable object graph edges. Relationships are defined as methods on model classes returning relationship objects.

#code_example[
  The User model defines optional relationships to Customer and Employee profiles.

  ```php
  <?php
  class User extends Authenticatable
  {
      public function customer(): HasOne
      {
          return $this->hasOne(Customer::class, 'user_id');
      }

      public function employee(): HasOne
      {
          return $this->hasOne(Employee::class, 'user_id');
      }
  }
  ```
]

The `HasOne` return type annotation enables IDE autocomplete and static analysis. Although Laravel can infer the `user_id` foreign key from conventions, the source specifies it explicitly for clarity.

#code_example[
  The Restaurant model defines the menu hierarchy through food types.

  ```php
  <?php
  class Restaurant extends Model
  {
      public function foodTypes(): HasMany
      {
          return $this->hasMany(FoodType::class);
      }

      public function images(): HasMany
      {
          return $this->hasMany(Image::class);
      }

      public function employees(): HasMany
      {
          return $this->hasMany(Employee::class);
      }
  }
  ```
]

Inverse relationships complete the bidirectional traversal graph.

#code_example[
  FoodType and MenuItem define their parent relationships.

  ```php
  <?php
  class FoodType extends Model
  {
      public function restaurant(): BelongsTo
      {
          return $this->belongsTo(Restaurant::class);
      }

      public function menuItems(): HasMany
      {
          return $this->hasMany(MenuItem::class);
      }
  }

  class MenuItem extends Model
  {
      public function foodType(): BelongsTo
      {
          return $this->belongsTo(FoodType::class);
      }

      public function allergens(): BelongsToMany
      {
          return $this->belongsToMany(Allergen::class, 'menu_item_allergen');
      }
  }
  ```
]

The `BelongsToMany` relationship for allergens specifies the pivot table name explicitly, as Laravel's convention-based inference would expect `allergen_menu_item` (alphabetically sorted) rather than the actual `menu_item_allergen` table name.

=== Query Scopes for Geospatial Filtering

Query scopes encapsulate reusable query logic in model methods prefixed with `scope`, enabling chainable query construction with semantic naming. The `Restaurant` model defines three geospatial scopes that form the foundation of location-based restaurant discovery.

#code_example[
  The `Restaurant` model defines scopes for computing distance, filtering by radius, and ordering by proximity.

  ```php
  <?php
  class Restaurant extends Model
  {
      public function scopeWithDistanceTo($query, float $lat, float $lng)
      {
          if (is_null($query->getQuery()->columns)) {
              $query->select($query->getModel()->getTable().'.*');
          }

          return $query->selectRaw(
              '(ST_Distance_Sphere(
                  POINT(longitude, latitude), POINT(?, ?)
              ) / 1000) AS distance',
              [$lng, $lat]
          );
      }

      public function scopeWithinRadiusKm($query, float $lat, float $lng, float $radiusKm)
      {
          $bounds = app(GeoService::class)->getBoundingBox($lat, $lng, $radiusKm);

          $query->whereBetween('latitude', [$bounds['latMin'], $bounds['latMax']])
              ->whereBetween('longitude', [$bounds['lngMin'], $bounds['lngMax']]);

          return $query->having('distance', '<=', $radiusKm);
      }

      public function scopeOrderByDistance($query)
      {
          return $query->orderBy('distance', 'asc');
      }
  }
  ```
]

The `scopeWithDistanceTo` computes a virtual `distance` column using MariaDB's `ST_Distance_Sphere` function, which returns spherical distance in meters (divided by 1000 for kilometers). The scope preserves existing column selections by conditionally adding `restaurants.*` before appending the computed column. The `scopeWithinRadiusKm` applies a two-stage filter: first a bounding box prefilter using `whereBetween` on the indexed latitude and longitude columns, then an exact distance constraint via a `HAVING` clause on the computed distance. The `scopeOrderByDistance` simply orders results by the computed distance ascending. These scopes compose naturally in controllers — for example, `Restaurant::withDistanceTo($lat, $lng)->withinRadiusKm($lat, $lng, 10)->orderByDistance()`.

=== Accessors for Computed Attributes

Accessors expose virtual properties calculated from stored data, centralizing computation logic and maintaining the Active Record pattern's encapsulation.

#code_example[
  The Order model computes total price from its menu items relationship.

  ```php
  <?php
  class Order extends Model
  {
      protected $appends = ['total'];

      public function getTotalAttribute(): float
      {
          return $this->menuItems->sum(
              fn ($item) => $item->price * $item->pivot->quantity
          );
      }

      public function menuItems(): BelongsToMany
      {
          return $this->belongsToMany(MenuItem::class, 'order_items')
              ->withPivot('quantity')
              ->withTimestamps();
      }
  }
  ```
]

This accessor allows controllers to reference `$order->total` as if it were a stored column. The `$appends` array ensures the computed value is automatically included in JSON serialization. The computation traverses the `BelongsToMany` relationship to `MenuItem`, reading the current `price` from the menu item and the `quantity` from the pivot table. The naming convention `getTotalAttribute` automatically maps to the `total` property.

=== Database Seeding Strategy

Seeders populate the database with required reference data and optional test fixtures. The main #source_code_link("database/seeders/DatabaseSeeder.php") orchestrates execution order.

#code_example[
  The DatabaseSeeder class creates test users and runs all required seeders in dependency order. The `DatabaseSeederService` is injected to provide shared seeding logic.

  ```php
  <?php
  class DatabaseSeeder extends Seeder
  {
      public function run(DatabaseSeederService $service): void
      {
          $adminUser = User::factory()->create([
              'name' => 'admin',
              'surname' => 'user',
              'email' => 'test@example.com',
              'password' => bcrypt('admin'),
          ]);

          Customer::factory()->create([
              'user_id' => $adminUser->id,
          ]);

          $this->call([
              AllergenSeeder::class,
              OrderStatusSeeder::class,
              RestaurantSeeder::class,
              EmployeeSeeder::class,
              CustomerSeeder::class,
          ]);

          $service->createDefaultEmployee();
      }
  }
  ```
]

Reference data seeders populate dictionary tables with fixed values.

#code_example[
  The OrderStatusSeeder creates the enumerated status values used throughout the system.

  ```php
  <?php
  class OrderStatusSeeder extends Seeder
  {
      public function run(): void
      {
          foreach (OrderStatusEnum::cases() as $status) {
              OrderStatus::updateOrCreate(
                  ['id' => $status->value],
                  ['name' => $status->label()]
              );
          }
      }
  }
  ```
]

The seeder iterates over a PHP enum's cases rather than maintaining a hardcoded array. This approach keeps status definitions centralized in the enum class where they can be referenced throughout the application. The `updateOrCreate` pattern makes seeding idempotent—running seeders multiple times updates existing records rather than creating duplicates.

Entity seeders use Model Factories for generating realistic test fixtures, with configurable counts and progress reporting for use by the `mfs` command.

#code_example[
  The RestaurantSeeder creates restaurants in batches using the factory's fluent geolocation API.

  ```php
  <?php
  class RestaurantSeeder extends Seeder
  {
      public function run(
          ?int $count = null,
          ?float $lat = null,
          ?float $lon = null,
          ?float $radius = null,
          ?callable $progressCallback = null
      ): void {
          $count ??= config('seeding.restaurants');
          $created = 0;
          $batchSize = 100;

          while ($created < $count) {
              $batchCount = min($batchSize, $count - $created);
              Restaurant::factory()
                  ->center($lat ?? config('seeding.center_lat'),
                           $lon ?? config('seeding.center_lon'))
                  ->radius($radius ?? config('seeding.radius'))
                  ->count($batchCount)
                  ->create();

              $created += $batchCount;
              if ($progressCallback) {
                  $progressCallback($created, $count);
              }
          }
      }
  }
  ```
]

=== Model Factories

Laravel Model Factories define how to generate realistic model instances for seeding and testing. The project contains factories for all major entities: `Restaurant`, `User`, `Customer`, `Employee`, `MenuItem`, `FoodType`, `Image`, `Order`, `Review`, and `Allergen`. Each factory uses Faker to produce random but plausible attribute values and exposes custom state methods for configuring specific variants — for example, `EmployeeFactory` provides `admin()` and `forRestaurant()` states that modify the generated output via a fluent API.

The most notable factory is `RestaurantFactory`, which uses a Gaussian distribution (Box-Muller transform) to scatter restaurant coordinates around a configurable center point, and registers an `afterCreating` callback that builds an entire relationship tree — food types, menu items with allergen associations, and images — so that calling `Restaurant::factory()->create()` produces a fully populated entity graph in a single call.

=== Artisan Command for Database Reset

The custom `mfs` command provides a single-command database reset workflow during development, combining migration refresh and configurable seeding. The command evolved from a simple two-line Artisan alias into a dedicated command class with parameterized seeding, input validation, and progress reporting.

#code_example[
  The `mfs` command is implemented as a dedicated Artisan command class with configurable options. Each option falls back to defaults defined in the `config/seeding.php` configuration file.

  ```php
  <?php
  class Mfs extends Command
  {
      protected $signature = 'mfs
          {--force : Force the operation to run when in production}
          {--restaurants= : Number of restaurants to seed}
          {--customers= : Number of customers to seed}
          {--employees-min= : Minimum employees per restaurant}
          {--employees-max= : Maximum employees per restaurant}
          {--reviews-per-customer= : Number of reviews per customer}
          {--orders-per-customer= : Number of orders per customer}
          {--radius= : Radius in km for restaurant distribution}';

      public function handle(): void
      {
          $params = $this->validateOptions();
          $this->runMigrations();
          $this->seedData($params);
          $this->displaySummary($params);
      }
  }
  ```
]

The command accepts optional flags for controlling the number of seeded entities (restaurants, customers, employees, reviews, orders) and their distribution radius. All options are validated using Laravel's `Validator` facade before execution. A dedicated `DatabaseSeederService` encapsulates the seeding logic, invoked in a defined order: static data (allergens, order statuses), restaurants, admin user, customers with reviews and orders, and employees. A `ConsoleOutputHelper` provides progress bars for long-running seeding steps, giving the developer visual feedback during the process. Default values are externalized in a `config/seeding.php` configuration file, keeping the command itself free of hardcoded constants.
