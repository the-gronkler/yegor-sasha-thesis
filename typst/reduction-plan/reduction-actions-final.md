# Thesis Reduction -- Final Action Document

**Goal:** Reduce thesis from ~155 pages to 110-130 pages
**Strategy:** Execute all Tier 1 + ~55% of Tier 2 actions = ~900-1,100 lines saved (~36-44 pages)
**Predicted result:** ~111-119 pages

---

## Execution Passes

Execute in this order. Each pass is a complete sweep through the thesis.

---

## PASS 1: Pure Deletions (no rewriting needed)

These items can be deleted without writing replacement text.

### 1.1 Delete stub files

**File: `typst/chapters/development-process/planning.typ`**

- DELETE entire file (stub: heading + `...` placeholder)
- Also remove its `#include` from `development-process-main.typ`

**File: `typst/chapters/development-process/documentation.typ`**

- DELETE entire file (stub: heading + `...` placeholder)
- Also remove its `#include` from `development-process-main.typ`

**File: `typst/chapters/development-process/automations.typ`**

- DELETE entire file (27 lines of commented-out code, renders as empty section)
- Also remove its `#include` from `development-process-main.typ`

_Savings: ~40 lines_

### 1.2 Delete copy-paste duplicate

**File: `typst/chapters/database-design.typ`**

- DELETE lines 83-96 (the second copy of "=== System Columns and Infrastructure Tables" through end of "Framework Infrastructure Tables")
- This is a character-for-character duplicate of lines 68-81

_Savings: 14 lines_

### 1.3 Delete architecture restatements from implementation

**File: `typst/chapters/implementation/map-functionality.typ`**

Action 1: DELETE lines 19-36 ("=== Requirements translated into implementation constraints")

- Entire section restates architecture chapter constraints. Lines 35-36 literally say "These constraints map directly to the controller's deterministic three-phase pipeline."

Action 2: DELETE lines 301-308 ("==== Database indexing strategy for geospatial queries")

- Directly restates `@map-arch-indexing` from architecture chapter.

Action 3: DELETE lines 714-734 ("=== Summary")

- All 21 lines are bullets referencing @labels from architecture chapter. Architecture already has its own summary.
- **MUST be deleted together with A2/A3/A4** to avoid orphaned references.

Action 4: DELETE lines 412-436 ("==== MapLayout: preventing body scroll conflicts")

- 25 lines about CSS `overflow:hidden`. Standard full-screen UI pattern.
- Replace with 1 sentence in the composition section above: "The `MapLayout` component prevents body scroll conflicts by toggling CSS classes that set `overflow: hidden` on mount."

Action 5: DELETE lines 226-229 ("Phase B to Phase C boundary")

- Internal code organization detail.

_Savings: ~75 lines_

### 1.4 Delete redundant architecture sections

**File: `typst/chapters/system-architecture/map-architecture.typ`**

Action 1: DELETE lines 251-259 ("==== Inertia.js Bridge Pattern")

- Says "relies on the Inertia.js integration described in @inertia-technology" then restates it.

Action 2: DELETE lines 174-186 ("==== Geolocation Integration Pattern")

- Component-level wiring detail, not architecture.

Action 3: DELETE lines 188-201 ("==== Query Optimization Strategy")

- SQL patterns belong in implementation. The principle ("compute once, use many times") is already implicit in Three-Phase Pipeline description.
- Keep the `<map-arch-query-optimization>` label concept by adding 1 sentence to Three-Phase Pipeline (lines 39-47): "The query architecture computes distance once using a subquery and reuses it in scoring, following a single-pass computation principle."

Action 4: DELETE lines 203-212 ("==== Bounding Box Prefilter Pattern")

- SQL WHERE/HAVING clauses are implementation detail.

_Savings: ~44 lines_

### 1.5 Delete from map-architecture Summary

**File: `typst/chapters/system-architecture/map-architecture.typ`**

- ABRIDGE lines 295-307 ("=== Summary") from 13 lines to 5 lines.
- Keep: Three-phase pipeline, Service layer, Layered state management. Remove the rest (they duplicate content from sections that remain).

_Savings: ~8 lines_

### 1.6 Delete unused/speculative technology content

**File: `typst/chapters/technologies/database.typ`**

- DELETE "JSON Compatibility" (lines 18-20) -- explicitly stated as unused
- DELETE "Multi-Master Replication" (lines 22-26) -- speculative future scaling

**File: `typst/chapters/technologies/blob-storage.typ`**

- DELETE "Edge Integration" (lines 20-21) -- hedges with "not strictly a storage feature"

**File: `typst/chapters/technologies/map-technologies.typ`**

- DELETE "Summary" section (lines 52-63) -- 12 lines restating preceding content

**File: `typst/chapters/technologies/backend-technologies.typ`**

- DELETE "PHP Language Maturity and Framework Ecosystem" (lines 21-31) -- 11-line defensive essay about PHP's reputation.
- Add 1 replacement sentence: "PHP 8.x provides modern language features (typed properties, enums, fibers) and Laravel benefits from a mature ecosystem of first-party packages."

_Savings: ~39 lines_

### 1.7 Delete unimplemented requirements (move to Future Work)

**File: `typst/chapters/functional-requirements.typ`**

- DELETE "Order Sharing" section (lines 45-47)
- DELETE "Dynamic Pricing and Promotions" section (lines 68-70)
- ADD to `conclusions-and-future-work.typ`: "Future features under consideration include group order sharing with split payment, and dynamic pricing tools for off-peak promotions."

_Savings: ~4 lines (net, after Future Work addition)_

### 1.8 Delete duplicate content from implementation

**File: `typst/chapters/implementation/frontend-types.typ`**

- DELETE "Custom Hook Type Exports" code block (lines 153-175) -- direct duplication of code shown in `frontend-search.typ`

**File: `typst/chapters/implementation/frontend-forms.typ`**

- DELETE "Optional Field Reset on Success" (lines 143-157) -- duplicates "Basic useForm Pattern" within same file

_Savings: ~32 lines_

### 1.9 Delete overview filler

**File: `typst/chapters/development-process/overview.typ`**

- DELETE bulleted chapter outline (lines 9-16) -- reader has actual TOC

_Savings: ~7 lines_

**PASS 1 TOTAL: ~263 lines saved**

---

## PASS 2: Code Block Replacements (replace with source_code_link)

Replace verbose code blocks with brief prose + `source_code_link()`. Each replacement follows the pattern: 1-3 sentences describing what the code does + a link.

### 2.1 Implementation database.typ

**File: `typst/chapters/implementation/database.typ`**

| Lines   | Section                                      | Replace With                                                                                                                                                                                                      |
| ------- | -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 13-39   | Users migration code block                   | "The users migration creates the authentication table with email uniqueness constraint, password hash, and session management columns." + `source_code_link("database/migrations")`                               |
| 44-81   | Role-Specific Profile Tables (2 code blocks) | Keep employees migration as ONE example. Replace customers with: "The customers table follows the same pattern with role-specific fields." + source_code_link                                                     |
| 83-119  | Menu Hierarchy (2 code blocks)               | "Separate migrations create the `food_types` and `menu_items` tables, implementing the hierarchical categorization strategy from @database-design." + source_code_links                                           |
| 121-164 | Many-to-Many Pivots                          | Keep order_items code block (stateful pivot). Replace allergens with 1-sentence prose + source_code_link                                                                                                          |
| 166-188 | Geospatial Column Definition                 | "The restaurant migration defines standard `DOUBLE` columns for latitude and longitude, implementing the coordinate-based approach described in @database-design." + source_code_link                             |
| 190-276 | Model Relationship Definitions (3 blocks)    | Keep MenuItem model (most non-trivial). Replace User + Restaurant models with prose + source_code_links                                                                                                           |
| 355-454 | Database Seeding Strategy                    | Keep OrderStatusSeeder code block. Replace DatabaseSeeder + RestaurantSeeder with prose + source_code_links                                                                                                       |
| 462-495 | Artisan Command for Database Reset           | "A custom `mfs` (migrate-fresh-seed) Artisan command wraps the standard `migrate:fresh --seed` workflow, adding visual progress output and serving as a single development reset entry point." + source_code_link |

_Savings: ~242 lines_

### 2.2 Implementation frontend-types.typ

**File: `typst/chapters/implementation/frontend-types.typ`**

| Lines  | Section                        | Replace With                                                                                                                                                                                                    |
| ------ | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 8-51   | Centralized Model Definitions  | Show 1 short interface example (Restaurant, ~8 lines). Replace others with: "Similar interfaces define `MenuItem`, `Order`, `Review`, and related models." + `source_code_link("resources/js/types/models.ts")` |
| 52-73  | Enumerations for Finite States | "TypeScript string enums encode finite-state values (`OrderStatus`, `UserRole`) ensuring compile-time exhaustiveness checks." + source_code_link                                                                |
| 75-101 | Generic Pagination Interface   | "A generic `Paginated<T>` interface wraps Laravel's standard pagination response shape, providing type-safe access to paginated data across all list views."                                                    |

_Savings: ~56 lines_

### 2.3 Implementation broadcasting.typ

**File: `typst/chapters/implementation/broadcasting.typ`**

| Lines    | Section                  | Replace With                                                                                                                                                                                                                                                                      |
| -------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ~20-38   | OrderUpdated event class | "Each broadcastable event extends Laravel's base event class, specifying the channel name and payload. The `booted()` model lifecycle hook automatically dispatches the event on status changes." + source_code_link. Keep the booted() pattern code if present (unique pattern). |
| ~155-169 | Channel auth code block  | "Channel authorization routes verify that the authenticated user owns the order before granting access to the private channel." + source_code_link                                                                                                                                |

_Savings: ~30 lines_

### 2.4 Implementation media-uploads.typ

**File: `typst/chapters/implementation/media-uploads.typ`**

| Lines    | Section                             | Replace With                                                                                                                                     |
| -------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| 9-27     | Filesystem Configuration code block | "The filesystem is configured to use Cloudflare R2 as the default disk, with credentials sourced from environment variables." + source_code_link |
| ~104-122 | Image Deletion Workflow code block  | Keep the rationale paragraph about why NOT to use a transaction. Replace code with source_code_link.                                             |

_Savings: ~27 lines_

### 2.5 Implementation frontend-workflow.typ

**File: `typst/chapters/implementation/frontend-workflow.typ`**

| Lines | Section                    | Replace With                                                                                                                                                              |
| ----- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 14-35 | Vite HMR config code block | "The Vite configuration enables hot module replacement for React components and processes SCSS through the standard build pipeline." + source_code_link("vite.config.js") |

_Savings: ~12 lines_

**PASS 2 TOTAL: ~367 lines saved**

---

## PASS 3: Prose Abridgements (rewriting required)

These items require rewriting prose to be shorter. Prioritized by savings.

### 3.1 High-value abridgements (>10 lines each)

**File: `typst/chapters/development-process/version-control.typ`**

- Lines 26-73 ("Commit Conventions"): ABRIDGE from 48 lines to ~18 lines. Keep: 1 sentence citing Conventional Commits spec, the format template, 2 example commits, the scope table (compressed to 4 rows). Remove: full type enumeration table, verbose descriptions of each type.
- _Savings: ~30 lines_

**File: `typst/chapters/implementation/map-functionality.typ`**

- Lines 163-224 (Phase B): Remove getBoundingBox code block (already in database.typ scopes). Trim intro restating architecture. _-30 lines_
- Lines 231-298 (Phase C): Merge 2 code blocks into 1 showing the key `fromSub`/`joinSub` pattern. Cut restated prose. _-20 lines_
- Lines 530-553 (Geolocation error handler): Replace standard browser error switch with 2-line prose + source*code_link. *-22 lines\_
- Lines 615-653 (Map component flyTo + token validation): Remove standard Mapbox API call. _-25 lines_
- Lines 670-712 (Bottom sheet): Keep prose techniques, replace code with source*code_links. *-25 lines\_
- Lines 367-410 (Entry composition TSX): Show key composition pattern ~15 lines, not all props. _-18 lines_
- Lines 469-500 ("Search here"): Replace code block with prose + source*code_link, keep threshold note. *-18 lines\_
- Lines 336-357 (Distance formatting): Remove trivial formatDistance code. _-16 lines_
- Lines 76-84 + 121-122 (Phase A intro/closing): Cut restated priority cascade. _-10 lines_
- Lines 123-141 (Session persistence prose): Reference architecture, keep code only. _-8 lines_
- Lines 153-159 (Constants list): Remove internal constants. _-7 lines_
- Lines 68-74 (Authorization restatement): Abridge to 1-sentence cross-ref. _-8 lines_
- Lines 441-445 (useMapPage bullets): Cut restated architecture. _-8 lines_
- Lines 359-365 (Frontend intro): Remove restated hierarchy. _-5 lines_
- Lines 7-17 (Artifacts list): Abridge to 4-5 primary files. _-5 lines_
- _Savings from map-functionality: ~225 lines_

**File: `typst/chapters/technologies/orm.typ`**

- Lines 39-61 ("Comparative Analysis"): ABRIDGE from 23 lines to ~4 lines. _-16 lines_
- Lines 10-24 ("Key Technical Advantages"): ABRIDGE each subsection to 1 sentence. _-12 lines_
- Lines 27-37 ("Active Record vs Data Mapper"): ABRIDGE to ~4 lines. _-6 lines_
- _Savings: ~34 lines_

**File: `typst/chapters/system-architecture/map-architecture.typ`**

- Lines 132-160 ("Data Flow and Synchronization"): Compress 29 lines of numbered steps to ~11 lines of prose. _-18 lines_
- Lines 64-78 ("Session-Based Location Persistence" ASCII diagram): Replace with prose. _-12 lines_
- Lines 88-106 + 108-112 ("Component Hierarchy"): Compress to top 2 levels. _-14 lines_
- Lines 225-249 ("Architectural Guarantees"): Keep Radius Determinism + Session Isolation only. _-12 lines_
- Lines 114-131 ("State Management"): Compress with cross-ref. _-10 lines_
- Lines 29-37 (Three-Phase Pipeline motivation): Compress to 3 sentences. _-8 lines_
- Lines 162-172 ("Controlled Map Component"): Compress to 3 lines. _-7 lines_
- Lines 49-58 ("Service Layer Abstraction"): Keep 2-line reference. _-7 lines_
- Lines 214-223 ("Payload Shaping"): Compress to 4 lines. _-6 lines_
- Lines 272-293 ("Scalability"): Remove duplicate points. _-7 lines_
- Lines 261-270 ("Mapbox Integration"): Remove GPU/declarative commentary. _-5 lines_
- _Savings from map-architecture: ~106 lines_

**File: `typst/chapters/system-architecture/backend-architecture.typ`**

- Lines 35-56 ("Request Validation"): ABRIDGE to ~10 lines. _-12 lines_
- Lines 107-124 ("Service Layer"): Compress. _-8 lines_
- Lines 86-105 ("Controller Architecture"): Compress. _-6 lines_
- Lines 58-85 ("Authorization"): Compress policy rules. _-6 lines_
- Lines 126-142 ("Middleware"): Compress to 1 sentence. _-5 lines_
- Lines 145-155 ("Summary"): Compress. _-4 lines_
- Lines 21-27 ("Sanctum"): Compress. _-3 lines_
- _Savings: ~44 lines_

### 3.2 Medium-value abridgements (5-10 lines each)

**File: `typst/chapters/technologies/react-frontend.typ`**

- Lines 9-23 ("Framework Selection Rationale"): Replace prose with comparison table. _-12 lines_
- Lines 47-65 ("Fuse.js"): Remove API docs. _-8 lines_
- Lines 35-45 ("Vite"): Remove generic features. _-5 lines_
- _Savings: ~25 lines_

**File: `typst/chapters/development-process/thesis-documentation.typ`**

- Lines 17-28 ("Typst vs. LaTeX"): ABRIDGE to 2-3 sentences. _-8 lines_
- Lines 30-34 ("Typst vs. WYSIWYG"): DELETE. _-5 lines_
- Lines 7-15 ("Typst Integration"): Remove hedging. _-4 lines_
- Lines 36-43 ("Repository Structure"): Merge with above. _-5 lines_
- Lines 44-47 ("Workflow and Versioning"): DELETE. _-3 lines_
- _Savings: ~25 lines_

**File: `typst/chapters/development-process/ai-use.typ`**

- Lines 16-35 ("Agent Instructions"): ABRIDGE to 1 citation + 1 explanation. _-13 lines_
- Lines 38-47 ("Ethical Considerations"): Merge sub-paragraphs. _-6 lines_
- Lines 49-55 ("Impact"): Trim. _-3 lines_
- Lines 6-9 ("AI in Research"): Compress. _-2 lines_
- _Savings: ~24 lines_

**File: `typst/chapters/implementation/frontend-state.typ`**

- Lines 7-64 ("Context Provider"): Show trimmed version. _-15 lines_
- Lines 91-123 ("Synchronization"): Brief prose. _-15 lines_
- Lines 125-150 ("Type-Safe Context"): Brief prose. _-15 lines_
- _Savings: ~45 lines_

**File: `typst/chapters/implementation/frontend-forms.typ`**

- Lines 33-39 + 42-54 ("Basic useForm"): Condense. _-18 lines_
- Lines 59-93 ("TypeScript Generics"): Reference frontend-types.typ. _-18 lines_
- Lines 124-141 ("Processing State"): Brief prose. _-12 lines_
- Lines 95-122 ("Validation Error Display"): MERGE with frontend-accessibility.typ. _-12 lines_
- _Savings: ~60 lines_

**File: `typst/chapters/implementation/frontend-search.typ`**

- Lines 29-48 ("Fuse.js Configuration"): 2-sentence description. _-12 lines_
- Lines ~117-129 ("Context-Specific Configurations"): Show restaurant search only. _-15 lines_
- _Savings: ~27 lines_

**File: `typst/chapters/implementation/frontend-accessibility.typ`**

- Lines 7-31 ("Semantic HTML"): Brief prose. _-10 lines_
- Lines 54-96 ("Form Label Association"): MERGE with frontend-forms.typ. _-15 lines_
- Lines 98-122 ("Focus Management"): Brief prose. _-10 lines_
- _Savings: ~35 lines_

**File: `typst/chapters/implementation/frontend-structure.typ`**

- Lines 3-41 ("Directory Structure"): Compact list. _-15 lines_
- Lines 42-72 ("Convention in Practice"): Compact import list. _-15 lines_
- _Savings: ~30 lines_

### 3.3 Lower-value abridgements (<5 lines each)

Various files across chapters -- see master-reduction-plan.md for complete list of items R6-R26, T7-T32, D8-D20, A27-A37. These are individually small but collectively significant.

**PASS 3 TOTAL: ~700+ lines saved**

---

## PASS 4: Cross-Chapter Merges

Execute these coordinated changes after Passes 1-3:

### 4.1 data-persistence.typ redistribution

- Move "Reactive Persistence" content to `real-time-events.typ` (add 1 sentence about ORM lifecycle hooks)
- Move "Handling Many-to-Many" to `database-design.typ` "Orders" section
- Move "Unified Identity Composition" to `database-design.typ` "User and Role Data" section
- Move "Schema Definition" to `database-design.typ` (1-sentence cross-ref)
- After redistribution, `data-persistence.typ` may be eliminable

### 4.2 employee-customer.typ elimination

- Move 1-sentence divide statement to `backend-architecture.typ` "Layered Architecture Overview"
- Delete `employee-customer.typ` and remove include

### 4.3 media-storage.typ elimination

- Move URL generation detail to `database-design.typ` "Images" section
- Move virtual state concept to implementation if unique
- Delete `media-storage.typ` and remove include

### 4.4 Form + Accessibility merge

- Create ONE "Accessible Form Field" example pattern in `frontend-forms.typ`
- Remove duplicate from `frontend-accessibility.typ`

### 4.5 Types + Search dedup

- Keep `useSearch` hook definition in `frontend-search.typ` only
- Remove duplicate from `frontend-types.typ` (already done in Pass 1)

### 4.6 Database scopes + Map Phase B

- Make `database.typ` scopes section canonical for bounding box pattern
- Map Phase B references scopes section instead of re-showing code

---

## PASS 5: Validation

After all changes:

1. **Compile thesis**: `typst compile typst/main.typ`
2. **Check page count**: Target 110-130 pages
3. **Check for broken references**: Search output for `@` reference warnings
4. **Verify aims coverage**: Each of the 5 objectives in `aims-and-objectives.typ` still has supporting content
5. **Spot-check source_code_links**: Ensure all new links point to valid file paths

---

## Summary

| Pass      | Type                    | Lines Saved       | Difficulty         |
| --------- | ----------------------- | ----------------- | ------------------ |
| Pass 1    | Pure deletions          | ~263              | Easy               |
| Pass 2    | Code block replacements | ~367              | Easy-Medium        |
| Pass 3    | Prose abridgements      | ~700+             | Medium (rewriting) |
| Pass 4    | Cross-chapter merges    | ~50 (incremental) | Medium             |
| **Total** |                         | **~1,380+**       |                    |

At ~25 lines/page, this removes ~55 pages, bringing the thesis from ~155 to ~100 pages. Since this exceeds the target range (110-130), **stop when reaching ~1,000 lines saved** (after Pass 2 + ~60% of Pass 3) for a final count of ~115 pages.

### Stopping Point Recommendation

Execute Passes 1 + 2 fully (~630 lines saved, ~130 pages). Then execute Pass 3 high-value items (section 3.1) selectively until reaching target. This avoids the diminishing returns of small abridgements in section 3.2/3.3.
