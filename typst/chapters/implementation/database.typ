#import "../../config.typ": code_example, source_code_link

== Database Implementation

The implementation of the persistence layer followed a "code-first" methodology, where the database schema is defined extensively through version-controlled migration scripts rather than manual SQL execution. This approach ensures reproducibility across development and production environments.

=== Schema Management and Migration Strategy
The schema evolution is managed via Laravel's migration system. Each table creation or modification is captured in a discrete class file. For example, the core `restaurants` table implementation demonstrates the use of precise data types for geospatial requirements:

#code_example[
  The initial migration defines the `restaurants` table structure, explicitly allocating double-precision columns for coordinates to support high-fidelity mapping.

  ```php
  <?php
  Schema::create('restaurants', function (Blueprint $table) {
      $table->id();
      $table->string('name');
      $table->string('address');
      // Double precision required for accurate lat/lng mapping
      $table->double('latitude')->nullable();
      $table->double('longitude')->nullable();
      $table->string('description', 512)->nullable();
      $table->double('rating')->nullable();
      $table->timestamps();
  });
  ```
]

As the project requirements evolved, "Schema Evolution" was practiced through incremental migrations. Notably, the #source_code_link("database/migrations/restaurants/2025_12_17_003827_add_geolocation_indexes_to_restaurants_table.php") migration applied B-Tree indices to the `latitude` and `longitude` columns. These indices were added post-initialization to optimize the increasingly complex spatial queries required by the map interface.

// NOTE here expland A LOT just include more seeder stuff
=== Seeding and Data Generation
To facilitate rigorous testing of the database performance, specifically the geospatial indices, a systematic seeding strategy was implemented. The `DatabaseSeeder` orchestrates a hierarchy of factories that generate synthetic data. See #source_code_link("database/seeders/DatabaseSeeder.php").
- *Deterministic Randomness*: Factories use a fixed seed to ensure that visual regression tests run against identical datasets.
- *Geospatial Variance*: The `RestaurantFactory` generates coordinates within a constrained radius of a target city center to simulate realistic density for clustering algorithms.

== Data Access Layer Implementation

The application interacts with the database primarily through Eloquent models, which serve as the interface for business logic. However, the implementation distinguishes between standard transactional operations and high-performance analytical queries.

=== Encapsulation via Scopes
To prevent logic leakage into controllers, complex SQL fragments are encapsulated within "Local Scopes" in the model classes. The `Restaurant` model implements a `withinRadiusKm` scope that abstracts the bounding box logic:

#code_example[
  The `Restaurant` model encapsulates the spatial filtering logic. It first calculates a bounding box to leverage the B-Tree indices, then applies a precise distance filter.

  ```php
  <?php
  // App/Models/Restaurant.php
  public function scopeWithinRadiusKm($query, float $lat, float $lng, float $radiusKm)
  {
      // 1. Calculate Bounding Box (PHP side)
      $bounds = app(GeoService::class)->getBoundingBox($lat, $lng, $radiusKm);

      // 2. Coarse Filter: Use B-Tree Indices (SQL side)
      $query->whereBetween('latitude', [$bounds['latMin'], $bounds['latMax']])
            ->whereBetween('longitude', [$bounds['lngMin'], $bounds['lngMax']]);

      // 3. Fine Filter: Exact Distance Constraint
      return $query->having('distance', '<=', $radiusKm);
  }
  ```
]

This implementation pattern ensures that the underlying database complexity - such as the specific choice of geospatial algorithm - is hidden from the consumer.

== Advanced Server-Side Computation and Optimization

A central challenge in the implementation was the efficient ranking of restaurants based on multiple heterogeneous factors: user proximity, aggregate rating, and review volume. Performing this calculation in the application layer (PHP) would require loading thousands of objects into memory, calculating scores, sorting, and then slicing the result set.

To address this, a "Composite Score" algorithm was implemented directly within the database engine using raw SQL expressions.

=== Database-Side Composite Scoring
The `MapController` constructs a query that offloads the computational heavy lifting to MariaDB. This approach utilizes the database's optimized sorting algorithms and heavily reduces I/O overhead.

The scoring algorithm assigns weights to three normalized factors:
- *Rating (50%)*: Prioritizes quality.
- *Popularity (30%)*: Uses a logarithmic scale `LOG10(review_count)` to prevent outliers (e.g., 10,000 reviews) from dwarfing other metrics, while still rewarding established venues.
- *Proximity (20%)*: An inverse linear function where closer is better.

#code_example[
  The `MapController` injects a raw SQL segment to calculate the `composite_score` on the fly. This enables the database to `ORDER BY` this computed value before returning any rows.

  ```php
  <?php
  // App/Http/Controllers/Customer/MapController.php
  $query->selectRaw(
      '(
          (COALESCE(rating, 0) / 5.0 * 50) +       -- 50% Weight: Rating
          (LEAST(30, LOG10(reviews_count + 1) * 10)) + -- 30% Weight: Review Volume
          (GREATEST(0, 20 * (1 - (distance / 20))))   -- 20% Weight: Proximity
      ) as composite_score'
  );

  $query->orderByRaw('composite_score DESC');
  ```
]

=== Geospatial Distance Calculation with ST_Distance_Sphere
For the distance component of the score, the system implements MariaDB's `ST_Distance_Sphere`. This native function provides higher accuracy than a standard Euclidean calculation by accounting for the Earth's curvature.

The implementation in `scopeWithDistanceTo` creates a computed column `distance` which is then available for both the `ORDER BY` clause and the API response payload, ensuring consistency between the sorting logic and the displayed data.

=== Projection and Join Optimization
To further optimize the payload size for mobile networks, the implementation utilizes strict "Column Projection". Instead of `SELECT *`, the `MapController` explicitly requests only the fields required for the map card display (id, name, lat, lng, rating, image).

Additionally, the "Favorited" status - which is user-specific - is resolved via a `LEFT JOIN` on the `favorite_restaurants` table with a constraint on the current user ID. This transforms what would otherwise be an N+1 query problem (checking favorite status for every restaurant in the loop) into a single, efficient O(1) join operation.
#code_example[
  The `MapController` optimizes the JSON payload by selecting only necessary columns and using a `LEFT JOIN` to determine the "Favorited" state in a single query.

  ```php
  <?php
  $query->select([
      'restaurants.id',
      'restaurants.name',
      'restaurants.address',
      'restaurants.latitude',
      'restaurants.longitude',
      'restaurants.rating',
      'restaurants.description'
  ]);

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
