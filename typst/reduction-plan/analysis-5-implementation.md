# Implementation Chapter -- Reduction Analysis

**Chapter size:** ~2,444 source lines across 14 files (~49% of thesis content)
**Target:** Identify abridgements, merges, and removals to significantly reduce page count.

**Key reference files for overlap detection:**

- `typst/chapters/system-architecture/map-architecture.typ` (308 lines) -- map architectural patterns
- `typst/chapters/system-architecture/backend-architecture.typ` (155 lines) -- backend layered architecture
- `typst/chapters/database-design.typ` (108 lines) -- schema design, ERD, rationale

---

## File-by-File Analysis

---

### 1. `implementation-main.typ` (12 lines)

| Section                    | Verdict  | Justification                       | Line Savings |
| -------------------------- | -------- | ----------------------------------- | :----------: |
| Chapter heading + includes | **KEEP** | Structural file, no content to cut. |      0       |

---

### 2. `database.typ` (495 lines) -- HIGH PRIORITY TARGET

This file contains **10+ full migration/model code blocks** that reproduce standard Laravel boilerplate. The database-design chapter already describes the schema rationale, ERD, and entity relationships. The implementation file then re-shows the same tables as raw PHP migration code. Most of this is reference material that could be replaced with a **single summary table of migrations** plus `source_code_link()` references.

#### Section: "Database Implementation" intro (lines 3-5)

| Verdict       | **KEEP**                                     |
| ------------- | -------------------------------------------- |
| Justification | Brief intro paragraph, appropriately scoped. |
| Line savings  | 0                                            |

#### Section: "Migration Structure and Execution Order" (lines 7-42)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The explanatory paragraph (lines 9-11) about anonymous class syntax is generic Laravel documentation. The full `users` table migration code block (lines 13-39) is a standard Laravel migration. Replace with a 2-line prose summary noting key fields (`is_admin`, `rememberToken`) + `source_code_link("database/migrations")`. The follow-up paragraph (lines 42) about `id()`, `timestamps()` etc. explains standard Laravel API. |
| Line savings  | **~28**                                                                                                                                                                                                                                                                                                                                                                                                                               |

#### Section: "Role-Specific Profile Tables" (lines 44-81)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                               |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Two code blocks (customers: 10 lines, employees: 12 lines) show nearly identical patterns -- FK as PK with cascade. These directly implement the disjoint inheritance already described in `database-design.typ` Section "User and Role Data". Replace with one prose paragraph describing the shared PK pattern + a source_code_link, or show ONE example (employees, as it has the `restaurant_id` FK) and describe the other in prose. |
| Line savings  | **~25**                                                                                                                                                                                                                                                                                                                                                                                                                                   |

#### Section: "Menu Hierarchy Implementation" (lines 83-119)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                              |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | Two code blocks (food_types: 10 lines, menu_items: 12 lines) implement exactly what `database-design.typ` Section "Restaurant and Menu" describes. Replace both code blocks with a prose paragraph noting the transitive categorization strategy is implemented via FK constraints, plus source_code_links. Keep the observation about `is_available` being added later. |
| Line savings  | **~28**                                                                                                                                                                                                                                                                                                                                                                  |

#### Section: "Many-to-Many Relationship Pivots" (lines 121-164)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                      |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Two code blocks (menu_item_allergen: 12 lines, order_items: 12 lines). Stateless vs. stateful pivots is a useful distinction but the full code is boilerplate. Show ONE pivot example (order_items, as it has the `quantity` column making it more interesting) and describe the other in prose. The paragraph about price snapshots (line 164) is a useful design note -- keep. |
| Line savings  | **~20**                                                                                                                                                                                                                                                                                                                                                                          |

#### Section: "Geospatial Column Definition" (lines 166-188)

| Verdict       | **MERGE/ABRIDGE**                                                                                                                                                                                                                                                                                                                   |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The restaurant migration code block (13 lines) shows standard columns that are already visible in the ERD. The prose about `double()` coordinates is already covered in `database-design.typ` Section "Spatial Data Representation". Replace code with a brief 2-line reference to the ERD + note about `string(512)` and indexing. |
| Line savings  | **~18**                                                                                                                                                                                                                                                                                                                             |
| Merge with    | `database-design.typ` Section "Spatial Data Representation"                                                                                                                                                                                                                                                                         |

#### Section: "Model Relationship Definitions" (lines 190-276)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Three code blocks: User model (13 lines), Restaurant model (20 lines), FoodType+MenuItem (27 lines). These are standard Eloquent relationship definitions. The patterns (`HasOne`, `HasMany`, `BelongsTo`, `BelongsToMany`) are generic Laravel. Replace all three with ONE code example (pick the MenuItem model with `BelongsToMany` allergens as the most non-trivial) and replace the other two with prose + source_code_links. The paragraph about explicit pivot table naming (line 276) is a useful observation -- keep. |
| Line savings  | **~50**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

#### Section: "Query Scopes for Geospatial Filtering" (lines 278-321)

| Verdict       | **MERGE/ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | This 44-line section shows the `scopeWithDistanceTo`, `scopeWithinRadiusKm`, `scopeOrderByDistance` methods. However, `map-functionality.typ` Phase B (lines 163-224) shows the SAME geospatial query logic re-implemented in the controller using raw `DB::table` queries. The reader sees distance calculation + bounding box filtering TWICE. Keep this scopes section as the canonical place for the geospatial pattern, but ABRIDGE the code to show only `scopeWithinRadiusKm` (the most complex one) and describe the distance/ordering scopes in prose. In `map-functionality.typ`, the Phase B code should reference these scopes rather than re-showing the pattern. |
| Line savings  | **~15** (here) + savings noted in map-functionality.typ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| Merge with    | `map-functionality.typ` Phase B to eliminate double-showing of bounding box pattern                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |

#### Section: "Accessors for Computed Attributes" (lines 323-353)

| Verdict       | **KEEP**                                                                                                                  |
| ------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Justification | The Order total accessor demonstrates a unique pattern (computed from pivot, appended to JSON). Not duplicated elsewhere. |
| Line savings  | 0                                                                                                                         |

#### Section: "Database Seeding Strategy" (lines 355-454)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Three code blocks: DatabaseSeeder (27 lines), OrderStatusSeeder (14 lines), RestaurantSeeder (27 lines). The seeding strategy is development tooling, not core system behavior. The OrderStatusSeeder demonstrates the useful `enum iteration + updateOrCreate` pattern. The RestaurantSeeder batch/progress pattern is detailed but peripheral. Replace with: keep OrderStatusSeeder (good pattern), summarize DatabaseSeeder as a dependency-ordered call list in prose, and replace RestaurantSeeder code with a brief prose description + source_code_link. |
| Line savings  | **~45**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

#### Section: "Model Factories" (lines 456-461)

| Verdict       | **KEEP**                                             |
| ------------- | ---------------------------------------------------- |
| Justification | Already just a prose paragraph. Appropriately brief. |
| Line savings  | 0                                                    |

#### Section: "Artisan Command for Database Reset" (lines 462-495)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                    |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | The `mfs` command code block (22 lines) + explanation paragraph detail a developer convenience tool. While mentioned in README/CLAUDE.md, the full command signature and architecture is not thesis-critical. Replace with a brief prose paragraph (3-4 lines) noting the command exists, its purpose, and `source_code_link`. |
| Line savings  | **~28**                                                                                                                                                                                                                                                                                                                        |

#### **database.typ Total Estimated Savings: ~257 lines (495 -> ~238)**

**Recommended alternative structure:** Replace most migration code blocks with a single **summary table** listing all migrations, their key columns, and key constraints. Show only 2-3 code blocks for non-obvious patterns (pivot with data, geospatial scope, enum-driven seeder). This could cut the file down to ~150-180 lines.

---

### 3. `media-uploads.typ` (123 lines)

This file is reasonably well-scoped with 5 code blocks covering a complete feature lifecycle (config, accessor, validation, upload, deletion).

#### Section: "Filesystem Configuration" (lines 9-27)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                      |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The R2 configuration code block (12 lines) is a standard Laravel filesystem config array. Replace with a 2-line prose description noting S3-compatible driver with custom endpoint + source_code_link("config/filesystems.php"). |
| Line savings  | **~12**                                                                                                                                                                                                                          |

#### Section: "Image Entity and URL Resolution" (lines 29-47)

| Verdict       | **KEEP**                                                                                                                                                                     |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The accessor pattern demonstrates runtime URL resolution from stored paths, which is the architectural approach described in the design chapter. Good implementation detail. |
| Line savings  | 0                                                                                                                                                                            |

#### Section: "Input Validation and Security" (lines 49-64)

| Verdict       | **ABRIDGE**                                                                                                                                                                               |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The validation code block (8 lines) is a standard Laravel validation array. The explanation of `image` rule and 5MB limit is useful but could be 2 lines of prose without the code block. |
| Line savings  | **~8**                                                                                                                                                                                    |

#### Section: "Transactional Upload Handling" (lines 66-94)

| Verdict       | **KEEP**                                                                                                                                                                      |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The transaction + rollback pattern is a significant implementation detail showing how consistency is maintained between database and external storage. Worth keeping in full. |
| Line savings  | 0                                                                                                                                                                             |

#### Section: "Image Deletion Workflow" (lines 96-122)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                            |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The design rationale paragraph (lines 97-99) explaining why deletion does NOT use a transaction is excellent. However, the code block (18 lines) shows a straightforward delete-then-cleanup pattern. The prose is more valuable than the code here. Replace code with source_code_link, keep the rationale paragraph. |
| Line savings  | **~15**                                                                                                                                                                                                                                                                                                                |

#### **media-uploads.typ Total Estimated Savings: ~35 lines (123 -> ~88)**

---

### 4. `broadcasting.typ` (187 lines)

#### Section: Broadcasting intro (lines 3-8)

| Verdict       | **KEEP**                             |
| ------------- | ------------------------------------ |
| Justification | Sets context for real-time features. |
| Line savings  | 0                                    |

#### Section: "Backend Event Broadcasting" (lines 9-73)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The two-paragraph intro (lines 10-15) about ShouldBroadcast, open-closed principle, and separation of concerns is somewhat over-justified for a standard Laravel feature. Three code blocks follow: OrderUpdated event (18 lines), Order booted() method (12 lines), and touch() after sync (5 lines). The event class is standard Laravel broadcasting boilerplate. The `booted()` dispatching and `touch()` pattern are more interesting. Keep the `booted()` example, replace OrderUpdated code with prose + source_code_link, and integrate the `touch()` example into the booted explanation. Cut the SoC/OCP paragraph to one sentence. |
| Line savings  | **~30**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |

#### Section: "Frontend Abstraction: useChannelUpdates Hook" (lines 75-140)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The prose description of the hook (lines 76-91) is thorough but overly detailed -- the 5-bullet parameter documentation (lines 85-89) reads like API docs rather than thesis content. The specific hooks list (lines 93-98) is useful. Three code blocks follow: useOrderUpdates (13 lines), usage in customer page (3 lines), usage in employee page (3 lines). The last two are trivially simple one-liners. Replace parameter documentation with a brief prose summary. Keep the useOrderUpdates code as the illustrative example. Remove the two trivial usage examples (they add nothing beyond what the wrapper already shows). |
| Line savings  | **~25**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |

#### Section: "Channel Security and Authorization" (lines 142-169)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                      |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The channel authorization code block (15 lines) shows standard Laravel Broadcast channel auth. The logic is straightforward (customer OR employee check). Replace with a prose description of the authorization rules + source_code_link("routes/channels.php"). |
| Line savings  | **~15**                                                                                                                                                                                                                                                          |

#### Section: "Environment Configuration and Protocol Handling" (lines 171-181)

| Verdict       | **KEEP**                                                                                                                       |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Justification | The split protocol architecture is a non-obvious deployment detail that caused implementation challenges. Worth keeping as-is. |
| Line savings  | 0                                                                                                                              |

#### Section: "Performance Considerations and Error Handling" (lines 183-187)

| Verdict       | **KEEP**                                      |
| ------------- | --------------------------------------------- |
| Justification | Brief prose paragraph, appropriately concise. |
| Line savings  | 0                                             |

#### **broadcasting.typ Total Estimated Savings: ~70 lines (187 -> ~117)**

---

### 5. `optimistic-updates.typ` (22 lines)

| Section     | Verdict  | Justification                                                                                                    | Line Savings |
| ----------- | -------- | ---------------------------------------------------------------------------------------------------------------- | :----------: |
| Entire file | **KEEP** | Already very concise at 22 lines. Well-written explanation of the pattern with clear trade-offs. No code blocks. |      0       |

---

### 6. `map-functionality.typ` (734 lines) -- HIGHEST PRIORITY TARGET

This is the **single largest file** and has the **heaviest overlap** with `map-architecture.typ` (308 lines). The implementation file frequently references architecture sections with `@labels` but then re-explains the same concepts with code. Many sections begin with "As described in @map-arch-..." and then proceed to restate the architectural concept before showing its implementation. The summary section (21 lines) literally restates bullet points from both chapters.

#### Section: "Map-Based Restaurant Discovery Implementation" intro (lines 3-5)

| Verdict       | **KEEP**               |
| ------------- | ---------------------- |
| Justification | Brief intro paragraph. |
| Line savings  | 0                      |

#### Section: "Main implementation artifacts" list (lines 7-17)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                      |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | 11 source_code_links listed as bullets. This is a useful index but could be moved to a footnote or shortened to list only the 4-5 primary files. Several sub-components (mapStyles.ts, MapLayout.tsx) are minor. |
| Line savings  | **~5**                                                                                                                                                                                                           |

#### Section: "Requirements translated into implementation constraints" (lines 19-36)

| Verdict       | **REMOVE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | This entire 18-line section restates architectural goals from `map-architecture.typ` (Sections: Architectural Overview, Architectural Guarantees, Payload Shaping). Each bullet point here corresponds to a section or guarantee already defined in the architecture chapter. The final line (35-36) explicitly says "These constraints map directly to the controller's deterministic three-phase pipeline" -- confirming this is a summary of previously stated material. |
| Line savings  | **~18**                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |

#### Section: "Backend implementation: deterministic three-phase processing" header (lines 37-39)

| Verdict       | **KEEP**                                       |
| ------------- | ---------------------------------------------- |
| Justification | Brief section header referencing architecture. |
| Line savings  | 0                                              |

#### Section: "Authorization, validation, and response shape" (lines 40-74)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                       |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The code block (18 lines) shows controller validation. The two "important for correctness" paragraphs (lines 68-74) restate the dual location semantics already defined in `map-architecture.typ` Section "Session Isolation" and "Architectural Guarantees". Keep code block, cut the restated explanation to a single-sentence cross-reference. |
| Line savings  | **~8**                                                                                                                                                                                                                                                                                                                                            |

#### Section: "Phase A: center coordinate normalization" (lines 76-122)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                             |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The intro paragraph (lines 76-84) restates the priority cascade from `map-architecture.typ` Section "Three-Phase Processing Pipeline" Phase A. The code block (24 lines) is the real implementation -- keep. The closing sentence (line 121-122) restates exploration isolation from architecture guarantees. Cut intro to one sentence referencing architecture, cut closing sentence. |
| Line savings  | **~10**                                                                                                                                                                                                                                                                                                                                                                                 |

#### Section: "Session-based geolocation persistence" (lines 123-161)

| Verdict       | **MERGE/ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                              |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | This section heavily overlaps with `map-architecture.typ` Section "Session-Based Location Persistence". The code block (18 lines) shows `getValidGeoFromSession`. The constants list (lines 153-159, 7 lines) is pure reference data. Cut the constants list entirely (these are internal values, not thesis-worthy), keep the code block, reference architecture for the pattern description. |
| Line savings  | **~15**                                                                                                                                                                                                                                                                                                                                                                                        |
| Merge with    | `map-architecture.typ` "Session-Based Location Persistence"                                                                                                                                                                                                                                                                                                                                    |

#### Section: "Phase B: proximity-first selection" (lines 163-224)

| Verdict       | **MERGE/ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The intro restates `map-architecture.typ` Section "Three-Phase Processing Pipeline" Phase B. Two code blocks: `selectNearestRestaurantIds` (24 lines) and `getBoundingBox` (15 lines). The bounding box logic is ALREADY shown in `database.typ` Section "Query Scopes for Geospatial Filtering" (lines 278-321) where `scopeWithinRadiusKm` implements the same bounding box + HAVING pattern. Remove the `getBoundingBox` code block entirely (shown elsewhere). Keep the `selectNearestRestaurantIds` code but trim the intro. |
| Line savings  | **~30**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Merge with    | `database.typ` "Query Scopes for Geospatial Filtering" (bounding box pattern shown there)                                                                                                                                                                                                                                                                                                                                                                                                                                         |

#### Section: "Phase B to Phase C boundary" (lines 226-229)

| Verdict       | **REMOVE**                                                                                                                                                                                 |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | 4 lines explaining that a helper method "exists only to keep Phase boundaries explicit." This is an implementation detail about internal code organization that does not add thesis value. |
| Line savings  | **~4**                                                                                                                                                                                     |

#### Section: "Phase C: scoring once and ordering by quality in SQL" (lines 231-298)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Two large code blocks: scored subquery (32 lines) and final query (22 lines). These overlap conceptually with `map-architecture.typ` Section "Query Optimization Strategy" which describes the single-pass computation pattern. The prose between/after code blocks restates the architecture's design rationale. The code IS valuable (it's complex SQL), but could be condensed: merge both code blocks into a single combined example showing the pipeline end-to-end, and cut the restated prose. The paragraph about favorites detection (line 299) could be one sentence. |
| Line savings  | **~20**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

#### Section: "Database indexing strategy for geospatial queries" (lines 300-308)

| Verdict       | **REMOVE**                                                                                                                                                                                                                                 |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | 9 lines that directly restate `map-architecture.typ` Section "Strategic Indexing" (`map-arch-indexing`). Adds no new implementation information -- just notes which indexes matter. A brief inline mention within Phase B/C would suffice. |
| Line savings  | **~9**                                                                                                                                                                                                                                     |

#### Section: "Empty result handling and early termination" (lines 309-334)

| Verdict       | **ABRIDGE**                                                                                                                                                                 |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | A code block (14 lines) showing an `if empty -> return early` pattern. This is a standard defensive programming pattern. Replace with 2-line prose note + source_code_link. |
| Line savings  | **~20**                                                                                                                                                                     |

#### Section: "Distance formatting and payload optimization" (lines 336-357)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                     |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The `formatDistance` code block (10 lines) shows a trivial `round()` call. Not thesis-worthy. The payload optimization paragraph (lines 357) restates `map-architecture.typ` Section "Payload Shaping and Lazy Loading". Remove the code block, keep 2-3 lines about payload strategy referencing architecture. |
| Line savings  | **~16**                                                                                                                                                                                                                                                                                                         |

#### Section: "Frontend implementation: orchestration, state, and synchronized UI" intro (lines 359-365)

| Verdict       | **ABRIDGE**                                                                                                                                                                           |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Restates the component hierarchy from `map-architecture.typ` Section "Component Hierarchy and Separation of Concerns" and re-lists source_code_links already shown at the file's top. |
| Line savings  | **~5**                                                                                                                                                                                |

#### Section: "Entry composition: MapLayout + Overlay + Map + BottomSheet" (lines 367-410)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                   |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The TSX code block (35 lines) shows how props are wired. While illustrative, much of it is prop-passing boilerplate. Reduce to showing the key composition pattern (5-10 lines showing the three main children) rather than all prop details. |
| Line savings  | **~18**                                                                                                                                                                                                                                       |

#### Section: "MapLayout: preventing body scroll conflicts" (lines 412-436)

| Verdict       | **REMOVE**                                                                                                                                                                                                                                                                        |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | 25 lines about toggling CSS `overflow: hidden` on mount/unmount. This is a standard full-screen-UI pattern, not a thesis contribution. A single sentence in the composition section noting "MapLayout disables body scrolling to prevent conflicts with map pan events" suffices. |
| Line savings  | **~22**                                                                                                                                                                                                                                                                           |

#### Section: "`useMapPage`: single source of truth for page state" (lines 438-467)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                    |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The bullet list (lines 441-445) restates `map-architecture.typ` state management description. The code block (14 lines) showing `reloadMap` with Inertia partial reload is a good illustration. Keep the code block, cut the restated bullets to one sentence. |
| Line savings  | **~8**                                                                                                                                                                                                                                                         |

#### Section: "'Search here': exploration without losing user context" (lines 469-500)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                   |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The intro restates session isolation guarantee from architecture. The code block (22 lines) shows `searchInArea` which is similar in structure to the `reloadMap` function just shown above. Both demonstrate the same Inertia partial reload pattern. Keep a brief prose note about the 0.01-degree threshold, replace code with source_code_link or describe in prose the key difference (sending `search_lat/search_lng`). |
| Line savings  | **~18**                                                                                                                                                                                                                                                                                                                                                                                                                       |

#### Section: "Geolocation integration: trigger mechanism and error handling" (lines 502-553)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Restates the geolocation pattern from `map-architecture.typ` Section "Geolocation Integration Pattern". Two code blocks: trigger function (12 lines) and error handler (20 lines). The trigger function is concise enough to keep. The error handler is a standard switch statement mapping error codes to strings -- not thesis-worthy. Replace error handler with 2-line prose description + source_code_link. |
| Line savings  | **~22**                                                                                                                                                                                                                                                                                                                                                                                                          |

#### Section: "Overlay controls: location, radius, and manual entry" (lines 555-565)

| Verdict       | **KEEP**                                                    |
| ------------- | ----------------------------------------------------------- |
| Justification | 11 lines of prose only. Concise description of UX patterns. |
| Line savings  | 0                                                           |

#### Section: "Map component: clustering, selection, and click modes" (lines 567-653)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                          |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Three code blocks: click handler (34 lines), flyTo camera animation (10 lines), and token validation (8 lines). The click handler demonstrates meaningful multi-modal logic -- keep but trim. The flyTo is a standard Mapbox API call -- remove code, describe in 1 sentence. Token validation is defensive boilerplate -- remove entirely or mention in 1 sentence. |
| Line savings  | **~25**                                                                                                                                                                                                                                                                                                                                                              |

#### Section: "Bottom sheet: pointer-driven drag, snapping, and selection sync" (lines 655-712)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                     |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Two code blocks: toggle-after-drag prevention (10 lines) and transition-aware scroll (18 lines). The three-technique description (pointer capture, drag detection, snap-on-release) is good pattern documentation. However, the code examples show UI plumbing, not thesis contributions. Keep the prose describing the techniques, replace code blocks with source_code_links. |
| Line savings  | **~25**                                                                                                                                                                                                                                                                                                                                                                         |

#### Section: "Summary" (lines 714-734)

| Verdict       | **REMOVE**                                                                                                                                                                                                                                                                                                                                      |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | 21 lines of bullet points that restate findings from both `map-architecture.typ` and the current implementation file. Every bullet explicitly references an `@label` from the architecture chapter, confirming this is redundant summary. The architecture chapter already has its own summary section (lines 295-308 of map-architecture.typ). |
| Line savings  | **~21**                                                                                                                                                                                                                                                                                                                                         |

#### **map-functionality.typ Total Estimated Savings: ~319 lines (734 -> ~415)**

---

### 7. `frontend-implementation.typ` (37 lines)

| Section                      | Verdict     | Justification                                                                                                                                                                                                                                                                                                              | Line Savings |
| ---------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------: |
| Intro + section organization | **ABRIDGE** | The 17-line introductory paragraph describes what each subsection covers. This is a "preview of coming attractions" that adds page count without content. A 3-4 line intro would suffice. The section headings themselves (Foundation, State & Interaction, User Experience, Development Efficiency) are self-explanatory. |   **~10**    |

#### **frontend-implementation.typ Total Estimated Savings: ~10 lines (37 -> ~27)**

---

### 8. `frontend-structure.typ` (72 lines)

#### Section: "Directory Structure and Organization" (lines 3-41)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | This is a directory listing with prose descriptions. The same information is partially covered in `backend-architecture.typ` Section "Domain-Organized Controllers" and in the `frontend-implementation.typ` intro. The Pages, Layouts, Components, Hooks, Contexts, Types, and Utils directories are described in 7 bullet groups. This could be condensed into a single structured list (no explanatory prose per directory) since the naming conventions are self-documenting. |
| Line savings  | **~15**                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |

#### Section: "Convention in Practice" (lines 42-72)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                          |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The code block (22 lines) shows a page component importing from each layer. The purpose is to demonstrate the import convention. This could be reduced to a 5-line import list + 2-line explanation, or simply described in prose: "Page components import layouts, shared components, type definitions, and hooks following a predictable pattern." |
| Line savings  | **~15**                                                                                                                                                                                                                                                                                                                                              |

#### **frontend-structure.typ Total Estimated Savings: ~30 lines (72 -> ~42)**

---

### 9. `frontend-types.typ` (188 lines)

This file embeds **full TypeScript interface definitions** in the thesis body. These are reference material better suited to an appendix or replaced with source_code_links.

#### Section: "Centralized Model Definitions" (lines 8-51)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The code block (35 lines) shows `MenuItem` and `Restaurant` interfaces in full. These mirror Eloquent models already shown in `database.typ`. Showing full interfaces in the thesis body is reference material, not analytical content. Replace with a brief prose description of the pattern (interfaces mirror Eloquent models, optional `?` for non-eager-loaded relations) + source_code_link("resources/js/types/models.ts"). Show at most ONE short example (e.g., just `MenuItem` or just `Restaurant`). |
| Line savings  | **~25**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

#### Section: "Enumerations for Finite States" (lines 52-73)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                   |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The `OrderStatusEnum` code block (11 lines) maps integers to names. This is a lookup table. One sentence noting "TypeScript enums map database integer status codes to named constants for type-safe comparisons" + source_code_link replaces the code block. |
| Line savings  | **~13**                                                                                                                                                                                                                                                       |

#### Section: "Generic Pagination Interface" (lines 75-101)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                      |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The `PaginatedResponse<T>` code block (16 lines) reproduces a standard Laravel pagination response shape. This is framework documentation. Replace with a 2-line description noting the generic wrapper pattern. |
| Line savings  | **~18**                                                                                                                                                                                                          |

#### Section: "Global PageProps Interface" (lines 103-151)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                        |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | Two code blocks: `PageProps` (14 lines) and `ShowPageProps` (16 lines). The `PageProps` interface is important as it defines the Inertia shared data contract -- keep that one but trim the explanation. The `ShowPageProps` example demonstrates the extension pattern but is simple enough to describe in prose. |
| Line savings  | **~18**                                                                                                                                                                                                                                                                                                            |

#### Section: "Custom Hook Type Exports" (lines 153-175)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                  |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The `useSearch` typed return value code block (14 lines) is already shown in `frontend-search.typ` (lines 12-25, same hook signature). This is a direct duplication. Remove from this file and reference the search section. |
| Line savings  | **~18**                                                                                                                                                                                                                      |
| Merge with    | `frontend-search.typ` "Reusable useSearch Hook"                                                                                                                                                                              |

#### Section: "Strict Type Configuration" (lines 177-188)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                           |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Lists 5 tsconfig options with one-line explanations. This is standard TypeScript configuration documentation. Replace with a single sentence: "The project enforces `strict: true` in tsconfig.json, enabling comprehensive null checks and implicit-any prevention." |
| Line savings  | **~8**                                                                                                                                                                                                                                                                |

#### **frontend-types.typ Total Estimated Savings: ~100 lines (188 -> ~88)**

---

### 10. `frontend-state.typ` (150 lines)

#### Section: "Context Provider Pattern" (lines 7-64)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | The code block (37 lines) shows the full CartContext with interface + provider + custom hook. This is a comprehensive React Context example. However, the pattern (create context, provider with state, custom hook with throw guard) is a well-known React pattern. Show a trimmed version with only the key parts (interface + useCart hook, ~15 lines) and reference the full implementation. |
| Line savings  | **~15**                                                                                                                                                                                                                                                                                                                                                                                          |

#### Section: "Server State Initialization" (lines 66-89)

| Verdict       | **KEEP**                                                                                                                     |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Justification | Shows how server data (Inertia shared props) initializes client state. This is a project-specific pattern worth documenting. |
| Line savings  | 0                                                                                                                            |

#### Section: "Synchronization with Inertia Navigation" (lines 91-123)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The code block (20 lines) shows Inertia `router.on('success')` listener that re-syncs cart state. The pattern is similar to initialization (same flatMap transformation logic, lines 76-83 vs. 104-110 -- nearly identical code). Show the sync pattern briefly in prose noting it mirrors initialization. |
| Line savings  | **~15**                                                                                                                                                                                                                                                                                                    |

#### Section: "Type-Safe Context Consumption" (lines 125-150)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                 |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The code block (17 lines) shows a MenuItemCard consuming useCart. This is a standard React pattern (destructure context hook, use values). The concept is already covered by the `useCart()` custom hook shown above. Replace with 2-line prose noting "Components destructure the typed hook return to access cart state." |
| Line savings  | **~15**                                                                                                                                                                                                                                                                                                                     |

#### **frontend-state.typ Total Estimated Savings: ~45 lines (150 -> ~105)**

---

### 11. `frontend-search.typ` (145 lines)

#### Section: "Reusable useSearch Hook" (lines 7-27)

| Verdict       | **KEEP**                                                                                            |
| ------------- | --------------------------------------------------------------------------------------------------- |
| Justification | Hook signature. Note this is DUPLICATED in `frontend-types.typ` -- keep it here, remove from there. |
| Line savings  | 0                                                                                                   |

#### Section: "Fuse.js Configuration and Caching" (lines 29-68)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | Two code blocks: default options (8 lines) and useMemo instantiation (5 lines). The 4-bullet configuration parameters list (lines 49-53) explains what standard Fuse.js options do. Replace the options code block with a 2-sentence description mentioning key settings. Keep the useMemo code as it shows a React-specific optimization. |
| Line savings  | **~12**                                                                                                                                                                                                                                                                                                                                    |

#### Section: "Filtering Logic and Empty Query Optimization" (lines 70-87)

| Verdict       | **KEEP**                                            |
| ------------- | --------------------------------------------------- |
| Justification | Small code block (8 lines), well-justified pattern. |
| Line savings  | 0                                                   |

#### Section: "Context-Specific Configurations" (lines 89-129)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | Two code blocks showing different weight configurations: restaurant search (12 lines) and menu search (12 lines). These demonstrate the SAME concept (weighted Fuse.js keys) twice with slightly different weight numbers. Show ONE example (restaurant search, as it includes nested key path) and describe menu search weights in prose. |
| Line savings  | **~15**                                                                                                                                                                                                                                                                                                                                    |

#### Section: "Constraints and Trade-offs" (lines 131-145)

| Verdict       | **KEEP**                                                                                                      |
| ------------- | ------------------------------------------------------------------------------------------------------------- |
| Justification | Good analytical content discussing the client-side search performance/completeness trade-off. No code blocks. |
| Line savings  | 0                                                                                                             |

#### **frontend-search.typ Total Estimated Savings: ~27 lines (145 -> ~118)**

---

### 12. `frontend-forms.typ` (157 lines)

#### Section: "Basic useForm Pattern" (lines 8-57)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                            |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The registration form code block (15 lines) and the input binding code block (12 lines) show standard Inertia useForm usage. The 6-bullet API description (lines 33-39) reads like API documentation. Keep the registration example as the primary illustration, remove the input binding code (it's standard React controlled component pattern), condense the API list to 2-3 lines. |
| Line savings  | **~18**                                                                                                                                                                                                                                                                                                                                                                                |

#### Section: "TypeScript Generics for Type Safety" (lines 59-93)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                   |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The `MenuItemFormData` code block (17 lines) shows a typed form. The concept (generics prevent typos) is already covered in `frontend-types.typ`. Could be reduced to a brief prose note referencing the type system section. |
| Line savings  | **~18**                                                                                                                                                                                                                       |
| Merge with    | `frontend-types.typ` "Custom Hook Type Exports" section (overlapping pattern of TypeScript generics)                                                                                                                          |

#### Section: "Validation Error Display" (lines 95-122)

| Verdict       | **MERGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | The code block (15 lines) showing error display with conditional className overlaps significantly with `frontend-accessibility.typ` Section "Form Label Association" (lines 56-94) which shows nearly identical form field patterns with `aria-describedby` and `aria-invalid`. These two sections cover the SAME UI pattern (form field with label + input + error) from different angles (forms vs. accessibility). Merge into one location showing the complete accessible form field pattern once. |
| Line savings  | **~12**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| Merge with    | `frontend-accessibility.typ` "Form Label Association"                                                                                                                                                                                                                                                                                                                                                                                                                                                  |

#### Section: "Processing State for Button Feedback" (lines 124-141)

| Verdict       | **ABRIDGE**                                                                                                                                                   |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The code block (8 lines) shows a button with `disabled={form.processing}` and ternary text. This is a trivial pattern. Replace with a 1-2 line prose mention. |
| Line savings  | **~12**                                                                                                                                                       |

#### Section: "Optional Field Reset on Success" (lines 143-157)

| Verdict       | **REMOVE**                                                                                                                                                                                                                   |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The code block (5 lines) shows `form.reset('password', 'password_confirmation')` -- identical to what was already shown in the "Basic useForm Pattern" section (line 28). This is a direct duplication within the same file. |
| Line savings  | **~14**                                                                                                                                                                                                                      |

#### **frontend-forms.typ Total Estimated Savings: ~74 lines (157 -> ~83)**

---

### 13. `frontend-accessibility.typ` (122 lines)

#### Section: "Semantic HTML Structure" (lines 7-31)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                  |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | The code block (12 lines) shows a button element vs. a div with role="button". This is textbook accessibility content (use `<button>` not `<div>`) that any web developer would know. Replace with 2-line prose noting the preference for semantic elements. |
| Line savings  | **~10**                                                                                                                                                                                                                                                      |

#### Section: "Descriptive ARIA Labels for Context" (lines 33-52)

| Verdict       | **KEEP**                                                                                                              |
| ------------- | --------------------------------------------------------------------------------------------------------------------- |
| Justification | The code block (8 lines) shows dynamic `aria-label` with item name. This is a project-specific pattern worth keeping. |
| Line savings  | 0                                                                                                                     |

#### Section: "Form Label Association" (lines 54-96)

| Verdict       | **MERGE/ABRIDGE**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Two code blocks (10 lines + 15 lines) show form field patterns with id/htmlFor and aria-describedby. These overlap with `frontend-forms.typ` Section "Validation Error Display" which shows the same form field pattern. Merge into a single "Accessible Form Field" example that shows label association, error display, aria-describedby, and aria-invalid together in ONE code block in ONE location (either here or in forms). Remove the simpler id/htmlFor example as it's a subset of the aria-describedby example. |
| Line savings  | **~15**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| Merge with    | `frontend-forms.typ` "Validation Error Display"                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |

#### Section: "Focus Management and Keyboard Navigation" (lines 98-122)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                          |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | The SCSS code block (8 lines) shows `:focus` and `:focus-visible` styling. This is standard CSS accessibility practice. Replace with 2-line prose noting focus-visible approach. The modal focus trapping paragraph (lines 121-122) is good -- keep. |
| Line savings  | **~10**                                                                                                                                                                                                                                              |

#### **frontend-accessibility.typ Total Estimated Savings: ~35 lines (122 -> ~87)**

---

### 14. `frontend-workflow.typ` (72 lines)

#### Section: "Component Isolation and Change Impact" (lines 7-12)

| Verdict       | **KEEP**              |
| ------------- | --------------------- |
| Justification | Brief prose, no code. |
| Line savings  | 0                     |

#### Section: "Vite Hot Module Replacement" (lines 14-35)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                        |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Justification | The code block (10 lines) shows a standard Vite config. This is boilerplate configuration found in every Vite + React + Laravel project. Replace with a 2-line prose mention + source_code_link("vite.config.js"). |
| Line savings  | **~12**                                                                                                                                                                                                            |

#### Section: "SCSS Compilation Pipeline" (lines 37-46)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                 |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | Bullet list of SCSS directory structure. Four sub-bullets listing specific file names (`_main-colors.scss`, etc.) are too granular for thesis content. Keep the top-level structure description, remove specific filenames. |
| Line savings  | **~5**                                                                                                                                                                                                                      |

#### Section: "Separation of Components and Styling" (lines 48-54)

| Verdict       | **KEEP**                                           |
| ------------- | -------------------------------------------------- |
| Justification | Brief prose on CSS/component separation principle. |
| Line savings  | 0                                                  |

#### Section: "Production Code Splitting" (lines 56-61)

| Verdict       | **KEEP**                                      |
| ------------- | --------------------------------------------- |
| Justification | Brief prose on Inertia-driven code splitting. |
| Line savings  | 0                                             |

#### Section: "Bundle Optimization Strategies" (lines 63-72)

| Verdict       | **ABRIDGE**                                                                                                                                                                                                                                                                                                                     |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Justification | 4-bullet list (tree shaking, minification, compression, asset hashing) describes standard Vite features. This is Vite documentation, not project-specific work. Replace with a single sentence: "Production builds apply standard optimizations including tree shaking, minification, and content-hash-based caching via Vite." |
| Line savings  | **~7**                                                                                                                                                                                                                                                                                                                          |

#### **frontend-workflow.typ Total Estimated Savings: ~24 lines (72 -> ~48)**

---

## Grand Summary

### Total Estimated Line Savings by File

| File                          | Current Lines | Estimated Savings | Reduced Lines | % Reduction |
| ----------------------------- | :-----------: | :---------------: | :-----------: | :---------: |
| `implementation-main.typ`     |      12       |         0         |      12       |     0%      |
| `database.typ`                |      495      |      **257**      |      238      |   **52%**   |
| `media-uploads.typ`           |      123      |        35         |      88       |     28%     |
| `broadcasting.typ`            |      187      |      **70**       |      117      |     37%     |
| `optimistic-updates.typ`      |      22       |         0         |      22       |     0%      |
| `map-functionality.typ`       |      734      |      **319**      |      415      |   **43%**   |
| `frontend-implementation.typ` |      37       |        10         |      27       |     27%     |
| `frontend-structure.typ`      |      72       |        30         |      42       |     42%     |
| `frontend-types.typ`          |      188      |      **100**      |      88       |   **53%**   |
| `frontend-state.typ`          |      150      |        45         |      105      |     30%     |
| `frontend-search.typ`         |      145      |        27         |      118      |     19%     |
| `frontend-forms.typ`          |      157      |      **74**       |      83       |   **47%**   |
| `frontend-accessibility.typ`  |      122      |        35         |      87       |     29%     |
| `frontend-workflow.typ`       |      72       |        24         |      48       |     33%     |
| **TOTAL**                     |   **2,444**   |    **~1,026**     |  **~1,418**   |  **~42%**   |

### Top 10 Highest-Impact Reduction Opportunities (Ranked)

| Rank | Opportunity                                                                                                                                          | File(s)                                             | Est. Savings | Difficulty |
| :--: | ---------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- | :----------: | :--------: |
|  1   | **Replace migration code blocks with a summary table** + 2-3 selected examples                                                                       | `database.typ`                                      |  ~160 lines  |    Low     |
|  2   | **Remove restated architecture concepts** from map implementation (requirements, indexing strategy, summary, scattered re-explanations)              | `map-functionality.typ`                             |  ~75 lines   |    Low     |
|  3   | **Condense frontend map code blocks** -- remove trivial examples (MapLayout scroll, flyTo, token validation, formatDistance) and trim large examples | `map-functionality.typ`                             |  ~100 lines  |   Medium   |
|  4   | **Move TypeScript interface definitions** to prose descriptions + source_code_links; keep only 1-2 essential type examples                           | `frontend-types.typ`                                |  ~100 lines  |    Low     |
|  5   | **Eliminate dual geolocation code** -- bounding box pattern shown in both database.typ scopes AND map-functionality.typ Phase B                      | `database.typ` + `map-functionality.typ`            |  ~45 lines   |   Medium   |
|  6   | **Merge form field patterns** shown separately in forms and accessibility sections into one combined accessible form example                         | `frontend-forms.typ` + `frontend-accessibility.typ` |  ~40 lines   |   Medium   |
|  7   | **Condense broadcasting code blocks** -- remove standard event/channel boilerplate, keep only non-obvious patterns                                   | `broadcasting.typ`                                  |  ~70 lines   |    Low     |
|  8   | **Remove duplicate code within forms section** (password reset shown twice) and collapse trivial pattern illustrations                               | `frontend-forms.typ`                                |  ~44 lines   |    Low     |
|  9   | **Trim seeding and mfs command sections** to brief prose + source_code_links (developer tooling, not system behavior)                                | `database.typ`                                      |  ~73 lines   |    Low     |
|  10  | **Condense frontend-state.typ** -- collapse the three-pattern repetition (initialization, sync, consumption) that shows nearly identical code        | `frontend-state.typ`                                |  ~45 lines   |   Medium   |

### Key Structural Recommendations

1. **Migration table strategy for database.typ**: Create a table with columns (Table Name, Key Columns, Constraints, Notes) listing all 8+ migrations. Then show only 2-3 code blocks for non-obvious patterns: (a) the geospatial query scope, (b) the order total accessor, and (c) the enum-driven seeder. This single change could save ~160 lines.

2. **Architecture-to-implementation deduplication for map**: The map-functionality.typ file should assume the reader has read map-architecture.typ. Every section should open with "Implementing the pattern from @section" and jump DIRECTLY to the code, without re-explaining the architectural concept. This philosophy change alone removes ~75 lines of restated prose.

3. **Code-to-reference ratio**: Many code blocks show standard framework patterns (Laravel migrations, React Context, Inertia useForm, Vite config). These can be replaced with `source_code_link()` references. Reserve in-thesis code blocks for patterns that are (a) non-obvious, (b) project-specific, or (c) demonstrate a design trade-off worth analyzing.

4. **Frontend section consolidation**: The six frontend sub-files (structure, types, state, forms, search, accessibility) share overlapping patterns. The form field pattern appears in three places (forms section, accessibility section, and implicitly in state section). Consolidating these into fewer files with a "complete example" approach would reduce redundancy.
