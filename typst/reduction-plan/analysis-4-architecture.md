# Analysis 4: System Architecture & Database Design -- Reduction Analysis (v2)

## File Inventory (line counts)

| File                              | Lines                       |
| --------------------------------- | --------------------------- |
| system-architecture.typ (wrapper) | 16                          |
| employee-customer.typ             | 7                           |
| data-persistence.typ              | 59                          |
| media-storage.typ                 | 16                          |
| backend-architecture.typ          | 155                         |
| frontend-architecture.typ         | 48                          |
| map-architecture.typ              | 307                         |
| real-time-events.typ              | 18                          |
| database-design.typ               | 108                         |
| **Total**                         | **734** (excluding wrapper) |

---

## Critical Issue: Duplicate Section in database-design.typ

**database-design.typ lines 69-81 and lines 83-96 are IDENTICAL.** The "System Columns and Infrastructure Tables" section (with both "Audit Timestamps" and "Framework Infrastructure Tables" subsections) is copy-pasted verbatim twice. This is clearly an error.

- **Verdict: REMOVE** the duplicate (lines 83-96)
- **Estimated savings: 14 lines**

---

## File-by-File, Section-by-Section Verdicts

### 1. system-architecture.typ (16 lines)

#### Chapter Intro (lines 1-16)

- **Verdict: KEEP**
- Justification: Necessary wrapper that includes sub-files and provides the chapter-level framing paragraph. After merging employee-customer.typ and media-storage.typ into other files, update the include list accordingly.
- Savings: 0 lines

---

### 2. employee-customer.typ (7 lines)

#### "Employee Customer Divide" (lines 1-7)

- **Verdict: MERGE into backend-architecture.typ**
- Justification: This file is a single paragraph (1 sentence of substance) stating the system separates customer-facing and employee-facing modules. This exact idea is already stated more thoroughly in backend-architecture.typ under "Dual User Type Architecture" (lines 29-33) and "Domain-Organized Controllers" (lines 103-105). The standalone heading adds a section break for one sentence of content. Absorb the sentence into the "Layered Architecture Overview" preamble of backend-architecture.typ and remove the standalone file.
- **Estimated savings: 7 lines (entire file eliminated as standalone section)**

---

### 3. data-persistence.typ (59 lines)

#### Lines 3-5: Section heading and intro paragraph

- **Verdict: ABRIDGE**
- Justification: The intro restates ORM mediation twice ("mediated exclusively through the ORM layer" + "managed within a unified architectural boundary"). Trim to one sentence.
- **Estimated savings: 2 lines**

#### Lines 7-12: "Persistence Strategy and Pattern Selection"

- **Verdict: KEEP**
- Justification: Establishes Active Record as the chosen pattern with a citation to Fowler. This is genuinely architectural and not duplicated elsewhere. The final paragraph ("The ORM handles tasks such as query construction...") can be trimmed as it restates what the Model Layer bullet in backend-architecture.typ line 17 already says.
- **Estimated savings: 2 lines**

#### Lines 14-31: "Domain Modelling and Capabilities"

- **Verdict: ABRIDGE**
- Justification: The bullet-point list of 7 "key responsibilities" (CRUD, Relationship Management, Eager Loading, Query Scopes, Computed Attributes, Lifecycle Hooks, Timestamps) is a generic description of what any ORM does. Most of these items are then discussed individually in their own subsections below (Query Scopes in lines 37-38, Computed Attributes in lines 40-41, Lifecycle Hooks in lines 43-44). Collapse the bullet list into a 2-3 sentence summary highlighting only project-specific capabilities (spatial query scopes, computed order totals, lifecycle hooks for broadcasting). Let the dedicated subsections carry the detail.
- **Estimated savings: 8 lines**

#### Lines 33-34: "Schema Definition and Version Control"

- **Verdict: MERGE with database-design.typ**
- Justification: This paragraph says migrations serve as version control for the schema. The same concept is described in database-design.typ's intro and in implementation/database.typ lines 7-9 ("Migration Structure and Execution Order"). Keep one description, ideally in database-design.typ. Replace this with a 1-sentence cross-reference.
- **Estimated savings: 4 lines**

#### Lines 37-38: "Query Abstraction and Semantic Scopes"

- **Verdict: KEEP**
- Justification: Concise and architecturally relevant -- explains the design decision to hide raw SQL behind semantic model scopes. Already terse.
- Savings: 0 lines

#### Lines 40-41: "Virtual State and Accessors"

- **Verdict: KEEP**
- Justification: Short, focused explanation of computed properties pattern. Appropriately concise.
- Savings: 0 lines

#### Lines 43-44: "Reactive Persistence and Event Integration"

- **Verdict: MERGE with real-time-events.typ**
- Justification: This paragraph describes ORM events triggering the event bus, which is the same concept described in real-time-events.typ ("Event Sources: Actions such as 'Order Placed' dispatch strongly typed Events"). Merge into real-time-events.typ by adding one sentence there noting that persistence lifecycle hooks are the trigger. Remove from here.
- **Estimated savings: 3 lines**

#### Lines 46-53: "Handling Many-to-Many Relationships"

- **Verdict: MERGE with database-design.typ**
- Justification: database-design.typ already describes the Orders many-to-many (lines 57-63) and image associations. The data-persistence version describes the same "stateless vs stateful" distinction at the abstract level. Move the conceptual framing (one brief paragraph) into database-design.typ alongside the entity cluster descriptions and remove the subsection here. Compress from 8 to 4 lines during the move.
- **Estimated savings: 6 lines**

#### Lines 55-57: "Unified Identity Composition"

- **Verdict: MERGE with database-design.typ "User and Role Data"**
- Justification: database-design.typ lines 27-31 already describe the User/Customer/Employee profile-based strategy. backend-architecture.typ lines 29-33 describe the same eager-loading behavior. This subsection adds the Global Query Scope detail, which is ORM-level implementation. Move the one-sentence architectural note to database-design.typ's User section; move the scope mechanics to implementation/database.typ. Remove from here.
- **Estimated savings: 4 lines**

**data-persistence.typ total savings: ~29 lines. Consider eliminating as standalone section entirely, redistributing unique content to database-design.typ, backend-architecture.typ, real-time-events.typ, and implementation/database.typ.**

---

### 4. media-storage.typ (16 lines)

#### Lines 3-5: Section heading and blob-storage reference

- **Verdict: MERGE into data-persistence.typ or database-design.typ**
- Justification: The intro sentence says media assets are external resources decoupled from the application runtime. This is one architectural decision expressible in a single sentence.

#### Lines 7-8: "Storage Abstraction Layer"

- **Verdict: ABRIDGE during merge**
- Justification: The DIP explanation for the Storage facade is generic ("high-level modules depend on abstractions"). Compress to one sentence: "File operations use Laravel's Storage facade, decoupling controllers from the concrete storage backend (S3/R2)."
- **Estimated savings: 2 lines**

#### Lines 10-16: "Architecture of the Image Entity"

- **Verdict: MERGE with database-design.typ "Images" section**
- Justification: database-design.typ lines 43-48 already describe the unified `images` table, `restaurant_id` FK, `menu_items.image_id` FK, path-based storage, and the `is_primary_for_restaurant` flag -- the same information as this section. The only unique content is "Dynamic URL Generation" (runtime URL via Accessor, 2 lines). Move that into the Images section of database-design.typ or into data-persistence "Virtual State and Accessors" as an example.
- **Estimated savings: 6 lines**

**media-storage.typ total savings: ~8 lines net content removal (16 lines eliminated as standalone; ~8 lines of unique content folded into database-design.typ). The file is too small (16 lines) to justify a standalone `==` section heading.**

---

### 5. backend-architecture.typ (155 lines)

#### Lines 3-5: Section heading and intro

- **Verdict: KEEP**
- Justification: Good framing paragraph.
- Savings: 0 lines

#### Lines 7-19: "Layered Architecture Overview"

- **Verdict: KEEP**
- Justification: Core architectural description defining four layers. Concise. After merging employee-customer.typ, add one sentence noting the customer/employee domain separation here.
- Savings: 0 lines

#### Lines 21-27: "Authentication Architecture / Sanctum Integration"

- **Verdict: ABRIDGE**
- Justification: Lines 24-27 describe standard Sanctum session-based authentication in 4 sentences. Compress to 2 sentences: "Authentication uses Laravel Sanctum with session-based cookies. Upon login, sessions are maintained through encrypted cookies validated against a database-backed session store."
- **Estimated savings: 3 lines**

#### Lines 29-33: "Dual User Type Architecture"

- **Verdict: ABRIDGE**
- Justification: Restates user/customer/employee schema from database-design.typ. Keep the architectural implication (unified login, divergent functionality via profile) but remove the schema description ("a shared `users` table with separate `customers` and `employees` profile tables") since it is already in database-design. Cross-reference instead.
- **Estimated savings: 2 lines**

#### Lines 35-56: "Request Validation Architecture" (22 lines)

- **Verdict: ABRIDGE**
- Justification: Spends 22 lines explaining a standard Laravel pattern (inline validation vs. Form Requests). The distinction is conventional and does not represent a novel architectural decision. Condense to one paragraph (~8 lines) stating the pragmatic two-tier strategy. The "Rate Limiting for Security" subsection (lines 50-56) describes a specific Form Request's throttle logic -- this is implementation detail rather than architecture. Either move to implementation or compress to 1 sentence.
- **Estimated savings: 12 lines**

#### Lines 58-85: "Authorization Architecture" (28 lines)

- **Verdict: ABRIDGE**
- Justification: "Policy-Based Access Control" (lines 60-65): Keep but condense slightly. "Admin Bypass Gate" (lines 67-70): Implementation detail (`Gate::before()` returning `true`/`null`). Reduce to one sentence noting the admin bypass exists. "Context-Aware Authorization" (lines 72-80): Lists specific order policy rules (view for owning customer, update only when InCart, etc.) -- these are implementation examples. Summarize the principle in 2-3 sentences without enumerating every policy rule. "Custom Gate Definitions" (lines 82-85): Keep as-is (already short).
- **Estimated savings: 6 lines**

#### Lines 86-105: "Controller Architecture" (20 lines)

- **Verdict: ABRIDGE**
- Justification: "Thin Controller Pattern" (lines 88-101): Clear but lines 99-101 re-elaborate when NOT to extract a service, repeating the delegation idea. Compress. "Domain-Organized Controllers" (lines 103-105): Keep, now also absorbing the employee-customer divide concept.
- **Estimated savings: 6 lines**

#### Lines 107-124: "Service Layer Architecture" (18 lines)

- **Verdict: ABRIDGE**
- Justification: "Domain Services" (lines 109-120): The ReviewService example lists 4 specific operations (image uploads, rating recalculation, etc.) -- implementation detail. Replace with a 2-sentence summary establishing the pattern and naming ReviewService as an example. "Cross-Cutting Utility Services" (lines 122-124): Describes GeoService, which is extensively covered in map-architecture.typ. Remove or reduce to a one-sentence forward reference.
- **Estimated savings: 8 lines**

#### Lines 126-142: "Middleware Architecture" (17 lines)

- **Verdict: ABRIDGE**
- Justification: "Role-Based Route Protection" (lines 128-132): Architecturally relevant but can be 2 lines instead of 4. "Inertia Request Handling" (lines 134-142): The 3-bullet list of shared data (auth state, flash messages, Mapbox key) is configuration-level detail. Condense to one sentence: "The HandleInertiaRequests middleware shares authentication state, flash messages, and environment configuration with every Inertia response."
- **Estimated savings: 5 lines**

#### Lines 145-155: "Summary" (11 lines)

- **Verdict: ABRIDGE**
- Justification: The summary restates the 5 patterns already described in the preceding subsections. In a thesis, per-section summaries add page count without adding information -- the chapter-level conclusion should suffice. However, a concise 5-point bullet list (no closing sentence) is still acceptable for orientation. Trim from 11 to 6 lines.
- **Estimated savings: 4 lines**

**backend-architecture.typ total savings: ~46 lines (from 155 to ~109)**

---

### 6. frontend-architecture.typ (48 lines)

#### Lines 3-5: Section heading and intro

- **Verdict: KEEP**
- Justification: Good framing sentence.
- Savings: 0 lines

#### Lines 7-19: "Component Hierarchy"

- **Verdict: KEEP**
- Justification: Well-structured, concise description of three-tier hierarchy with custom hooks. Appropriately architectural. The cross-reference to `@frontend-implementation` correctly defers concrete directory structure.
- Savings: 0 lines

#### Lines 21-33: "State & Data Flow"

- **Verdict: ABRIDGE**
- Justification: Four sub-paragraphs (Local State, Global State, Server State, Route Configuration) are each 2-4 sentences. "Route Configuration" about Ziggy could be trimmed to one sentence since it is a library choice, not a novel architectural pattern. Line 33 (component communication paragraph) partially restates component hierarchy concepts. Trim.
- **Estimated savings: 4 lines**

#### Lines 35-41: "Styling Architecture"

- **Verdict: KEEP**
- Justification: Concise at 7 lines. Covers SCSS organization and mobile-first responsive approach with citation.
- Savings: 0 lines

#### Lines 43-48: "Error Handling"

- **Verdict: KEEP**
- Justification: Brief at 6 lines. Covers both client-side Error Boundaries and server-side error flow through Inertia.
- Savings: 0 lines

**frontend-architecture.typ total savings: ~4 lines (from 48 to ~44)**

---

### 7. map-architecture.typ (307 lines) -- THE LARGEST FILE

This is the primary target for reduction. At 307 lines it is by far the longest architecture section and contains significant overlap with `implementation/map-functionality.typ`. The core question: how much is conceptual architecture vs. implementation detail? The answer: roughly 50/50.

#### Lines 3-5: Section heading and intro

- **Verdict: ABRIDGE**
- Justification: The intro sentence lists 7 things the section covers. Replace with a focused 1-sentence overview.
- **Estimated savings: 2 lines**

#### Lines 7-27: "Architectural Overview / Layer Topology" (21 lines)

- **Verdict: KEEP**
- Justification: Defines the six-layer topology. Genuinely architectural and provides the conceptual framework for the implementation chapter to reference. The prose at lines 7-9 is slightly redundant with the intro but acceptable.
- Savings: 0 lines

#### Lines 29-47: "Three-Phase Processing Pipeline" (19 lines)

- **Verdict: ABRIDGE**
- Justification: The motivation paragraph (lines 29-37) spends 9 lines on why a pipeline is needed ("metropolitan areas like Warsaw can contain thousands... conflicting requirements... geographic proximity... quality indicators"). This motivation should have been established already in the requirements chapter. Condense to 3 sentences. The three phases (A, B, C) description (lines 39-47) is repeated almost verbatim in implementation/map-functionality.typ (lines 37-39 forward-reference this section, then re-describe each phase with code). Keep the 3 phases as 1 line each.
- **Estimated savings: 8 lines**

#### Lines 49-58: "Service Layer Abstraction" (10 lines)

- **Verdict: MERGE with backend-architecture.typ "Cross-Cutting Utility Services"**
- Justification: backend-architecture.typ lines 122-124 already mention GeoService as a cross-cutting utility service. This subsection restates and expands (3 bullets: bounding box, distance formatting, session persistence). Consolidate into one place. Keep a 2-line reference in map-architecture saying "Geospatial logic is isolated in GeoService (see @backend-architecture)."
- **Estimated savings: 7 lines**

#### Lines 60-79: "Session-Based Location Persistence" (20 lines)

- **Verdict: ABRIDGE**
- Justification: The ASCII sequence diagram (lines 64-78) consumes 16 lines to show a simple read-through cache pattern: Controller calls Service, Service reads Session, returns coordinates or null, Controller uses default. The same flow is described with actual code in implementation/map-functionality.typ. Replace the diagram with a 2-3 sentence prose description.
- **Estimated savings: 12 lines**

#### Lines 81-112: "Component Hierarchy and Separation of Concerns" (32 lines)

- **Verdict: ABRIDGE**
- Justification: The ASCII component tree (lines 88-106) is 19 lines of diagram. This is useful for understanding structure but essentially duplicates the Layer Topology list from lines 13-26 in visual form, and also duplicates the source code link list in implementation/map-functionality.typ (lines 7-17). Compress the tree to show only the top 2 levels (5 lines). Remove lines 108-112 which explain "single responsibility principle" -- this is evident from the diagram.
- **Estimated savings: 14 lines**

#### Lines 114-131: "State Management Architecture" (18 lines)

- **Verdict: ABRIDGE / MERGE references**
- Justification: The three state layers (Server/Inertia, Page/Hook, Global/Context) are described here AND in frontend-architecture.typ "State & Data Flow" (lines 21-33), which already covers Local State, Global State, Server State, Context, and Inertia shared props. The map-specific application of these patterns is the only unique content. Compress to 6 lines focusing on map-specific state decisions, cross-referencing the general pattern described in frontend-architecture.
- **Estimated savings: 10 lines**

#### Lines 132-160: "Data Flow and Synchronization" (29 lines)

- **Verdict: ABRIDGE**
- Justification: Three flow descriptions (Server->Client: 6 numbered steps, Client->Server: 5 steps, Client-Only: 4 steps) total 29 lines. Each reads like implementation pseudocode. The Server->Client and Client->Server flows are the standard Inertia partial reload pattern already described in frontend-architecture.typ and repeated in the Inertia bridge section below. Compress each flow to 2-3 sentences of prose describing the pattern rather than enumerating every step. Keep the "hybrid approach" closing paragraph.
- **Estimated savings: 18 lines**

#### Lines 162-172: "Controlled Map Component Pattern" (11 lines)

- **Verdict: ABRIDGE**
- Justification: This is a standard React controlled component pattern. The 4-point "This architecture enables" list and the comparison to the uncontrolled alternative is didactic rather than architecturally novel. Compress to 3 lines stating the pattern and its primary benefit.
- **Estimated savings: 7 lines**

#### Lines 174-186: "Geolocation Integration Pattern" (13 lines)

- **Verdict: REMOVE**
- Justification: This describes a specific implementation workaround: how a hidden `GeolocateControl`'s trigger function is registered via a callback ref and invoked from custom overlay buttons. This is component-level wiring (which React pattern to use for bridging third-party controls), not architecture. The 6-step flow describes implementation mechanics. Move to implementation/map-functionality.typ if desired.
- **Estimated savings: 13 lines**

#### Lines 188-201: "Query Optimization Strategy" (14 lines)

- **Verdict: MERGE into implementation chapter**
- Justification: Describes specific SQL patterns: subquery reuse for distance, pre-aggregated counts via grouped subquery, derived table for composite score, ordering on derived columns. These are database query implementation decisions, not high-level architecture. The architectural principle ("compute once, use many times") can be stated in 2 lines within the three-phase pipeline section.
- **Estimated savings: 14 lines**

#### Lines 203-212: "Bounding Box Prefilter Pattern" (10 lines)

- **Verdict: MERGE into implementation chapter**
- Justification: Describes SQL WHERE/HAVING clauses and discusses R-tree vs B-tree index tradeoffs. This is an optimization implementation detail. The architectural principle ("coarse filter then exact filter") can be stated in 2 lines. The indexing discussion overlaps with database-design.typ "Spatial Data Representation" (lines 65-66) and "Indexing and Constraint Strategy" (lines 98-107).
- **Estimated savings: 8 lines**

#### Lines 214-223: "Payload Shaping and Lazy Loading" (10 lines)

- **Verdict: ABRIDGE**
- Justification: The principle (load only what is displayed, separate discovery data from detail data) is architecturally relevant. But 10 lines to say "the map endpoint loads minimal data; the detail page loads everything" is verbose. Compress to 4 lines.
- **Estimated savings: 6 lines**

#### Lines 225-249: "Architectural Guarantees and Invariants" (25 lines)

- **Verdict: ABRIDGE**
- Justification: Lists 5 invariants, each at 4-5 lines. "Radius Determinism" and "Session Isolation" are the genuinely architectural guarantees. "Score Stability" (scores computed once in SQL) is an implementation guarantee. "Center Point Uniqueness" (priority cascade is deterministic) merely restates Phase A. "UI State Preservation" restates Inertia partial reload behavior described in frontend-architecture. Keep the 2 key guarantees, compress each to 2 lines. Remove or fold the others.
- **Estimated savings: 12 lines**

#### Lines 251-259: "Integration Architecture / Inertia.js Bridge Pattern" (9 lines)

- **Verdict: REMOVE**
- Justification: This section says the map uses Inertia's partial reload capability -- already stated in "Data Flow and Synchronization" (line 149), in frontend-architecture.typ (line 13 on layout persistence, line 29 on shared props), and is a general framework feature, not map-specific architecture. Pure repetition.
- **Estimated savings: 9 lines**

#### Lines 261-270: "Integration Architecture / Mapbox Integration Architecture" (10 lines)

- **Verdict: ABRIDGE**
- Justification: The 4-layer description (Data, Clustering, Visual, Interaction) is useful as a quick structural overview. However, the commentary about declarative vs imperative rendering and GPU acceleration (line 270) is tangential -- these are Mapbox features, not the project's architecture. Compress to 5 lines.
- **Estimated savings: 5 lines**

#### Lines 272-293: "Scalability and Performance Architecture" (22 lines)

- **Verdict: ABRIDGE**
- Justification: Three subsections: "Hard Result Limit" (3 lines, already stated in three-phase pipeline section -- duplicate), "Database-Level Computation" (2 lines, already stated in query optimization section -- duplicate), "Strategic Indexing" (lines 285-292, 8 lines discussing MariaDB index merge, composite vs single-column indexes, spatial index tradeoffs). The indexing discussion overlaps with database-design.typ "Indexing and Constraint Strategy" (lines 98-107) and "Spatial Data Representation" (lines 65-66). Keep 2 sentences referencing database-design for indexing details. Remove the duplicated limit and computation points.
- **Estimated savings: 7 lines**

#### Lines 295-307: "Summary" (13 lines)

- **Verdict: ABRIDGE**
- Justification: 13-line summary restates all major patterns with 7 bullets plus a closing sentence. Given the section will be significantly shorter after other reductions, the summary should shrink proportionally. Compress to 5 bullets, remove closing sentence.
- **Estimated savings: 5 lines**

**map-architecture.typ total savings: ~155 lines (from 307 to ~152)**

**Breakdown of map-architecture.typ content:**

- Conceptual architecture (layer topology, three-phase motivation, state principles, key guarantees): ~152 lines -- KEEP
- Implementation detail masquerading as architecture (SQL patterns, component wiring, step-by-step flows, indexing strategies): ~155 lines -- MOVE/REMOVE

---

### 8. real-time-events.typ (18 lines)

#### "Event-Driven Real-Time Topology" (lines 1-18)

- **Verdict: KEEP**
- Justification: Concise at 18 lines. Covers event sources, message broker, channel distribution (public/private), client subscription, security, and integration with the layered architecture. No notable overlap except the minor one with data-persistence "Reactive Persistence" which is being merged here.
- Savings: 0 lines

---

### 9. database-design.typ (108 lines)

#### Lines 3-7: Chapter heading and intro (2 paragraphs)

- **Verdict: ABRIDGE**
- Justification: Two paragraphs of intro for one chapter. The second paragraph (line 7: "The design philosophy prioritizes normalization...") can be trimmed to one sentence.
- **Estimated savings: 2 lines**

#### Lines 9-25: "Schema Overview and Integrity" (includes ERD figure)

- **Verdict: ABRIDGE**
- Justification: ERD figure (lines 9-14) must stay. But lines 16-18 explain crow's foot notation and name the tool (Redgate Data Modeler) -- tangential. Move tool note to a footnote; remove crow's foot explanation (thesis readers should know standard notation). Lines 20-24 are meta-commentary ("The goal of this section is to provide an overview..."). Remove.
- **Estimated savings: 4 lines**

#### Lines 27-31: "User and Role Data"

- **Verdict: KEEP**
- Justification: Concise (5 lines). Describes the profile-based strategy and disjoint inheritance. After merging data-persistence "Unified Identity Composition" content here, add one sentence about the Global Query Scope eager-loading.
- Savings: 0 lines

#### Lines 33-41: "Restaurant and Menu"

- **Verdict: KEEP**
- Justification: Concise (9 lines). Covers aggregate root, hierarchical categorization, and 3NF normalization rationale. Appropriate for database design.
- Savings: 0 lines

#### Lines 43-48: "Images"

- **Verdict: ABRIDGE**
- Justification: After merging media-storage.typ content here (the URL generation accessor detail, ~2 lines absorbed), the current verbose explanation of why explicit FK was chosen over polymorphic associations (4 sentences, lines 43-44) can be compressed to 2 sentences. Net effect: absorb ~2 lines from media-storage, trim ~2 lines of verbosity.
- **Estimated savings: 2 lines** (net, after absorbing media-storage content)

#### Lines 50-55: "Reviews"

- **Verdict: ABRIDGE**
- Justification: The "Primary Key Strategy" paragraph (lines 53-55) spends 4 sentences explaining why a surrogate key was chosen over a composite key for reviews. This is common practice and over-justified. Compress to 1-2 sentences.
- **Estimated savings: 3 lines**

#### Lines 57-63: "Orders"

- **Verdict: KEEP**
- Justification: Concise. The "cart as an order with 'In Cart' status" is a genuinely notable design decision worth documenting fully.
- Savings: 0 lines

#### Lines 65-66: "Spatial Data Representation"

- **Verdict: KEEP**
- Justification: Brief (2 long lines). Justifies using double-precision columns over geometric types. This is the canonical location for this schema decision. After removing the duplicate discussion from map-architecture.typ, this section becomes the single source of truth.
- Savings: 0 lines

#### Lines 69-81: "System Columns and Infrastructure Tables" (first copy)

- **Verdict: KEEP**
- Justification: Covers audit timestamps and framework infrastructure tables. Useful for completeness. This is the copy to retain.
- Savings: 0 lines

#### Lines 83-96: "System Columns and Infrastructure Tables" (SECOND COPY -- DUPLICATE)

- **Verdict: REMOVE**
- Justification: Lines 83-96 are character-for-character identical to lines 69-81. Clear copy-paste error. Remove entirely.
- **Estimated savings: 14 lines**

#### Lines 98-108: "Indexing and Constraint Strategy"

- **Verdict: KEEP**
- Justification: Brief summary of indexing approach. After removing the detailed indexing discussion from map-architecture.typ, this becomes the canonical and sole location for the indexing strategy.
- Savings: 0 lines

**database-design.typ total savings: ~25 lines (from 108 to ~83). After absorbing content from data-persistence.typ and media-storage.typ, net result ~90 lines.**

---

## Cross-Cutting Overlap Summary

| #   | Overlap Pair                                                                                                                       | Nature                                                                         | Recommendation                                                                                     |
| --- | ---------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| 1   | data-persistence.typ "Schema Definition" vs. database-design.typ intro vs. implementation/database.typ "Migration Structure"       | Three places describe migrations as schema version control                     | Consolidate in database-design.typ; remove from data-persistence                                   |
| 2   | data-persistence.typ "Unified Identity" vs. database-design.typ "User and Role Data" vs. backend-architecture.typ "Dual User Type" | Three places describe User/Customer/Employee composition                       | Schema in database-design; auth implications in backend-architecture; remove from data-persistence |
| 3   | data-persistence.typ "Reactive Persistence" vs. real-time-events.typ                                                               | Both describe ORM events triggering the event bus                              | Merge into real-time-events.typ                                                                    |
| 4   | data-persistence.typ "Many-to-Many" vs. database-design.typ "Orders" and "Images"                                                  | Both describe relationship modeling strategies                                 | Move to database-design.typ                                                                        |
| 5   | media-storage.typ "Image Entity" vs. database-design.typ "Images"                                                                  | Both describe images table, path storage, FK design                            | Merge media-storage into database-design                                                           |
| 6   | employee-customer.typ vs. backend-architecture.typ "Dual User Type" + "Domain-Organized Controllers"                               | Both describe customer/employee separation                                     | Merge into backend-architecture                                                                    |
| 7   | map-architecture.typ "State Management" vs. frontend-architecture.typ "State & Data Flow"                                          | Both describe server/page/global state tiers                                   | Map section should reference frontend-architecture for the general pattern                         |
| 8   | map-architecture.typ "Three-Phase Pipeline" vs. implementation/map-functionality.typ "Backend implementation"                      | Architecture describes concept; implementation shows code at same detail level | Trim architecture to stay conceptual                                                               |
| 9   | map-architecture.typ "Query Optimization" + "Bounding Box" vs. implementation/map-functionality.typ                                | SQL patterns described in architecture belong in implementation                | Move to implementation chapter                                                                     |
| 10  | map-architecture.typ "Strategic Indexing" vs. database-design.typ "Spatial Data" + "Indexing Strategy"                             | Both discuss spatial indexing approach                                         | Consolidate in database-design                                                                     |
| 11  | map-architecture.typ "Inertia Bridge" vs. frontend-architecture.typ (Inertia partial reloads)                                      | Standard Inertia feature described redundantly                                 | Remove from map-architecture                                                                       |
| 12  | database-design.typ lines 69-81 vs. lines 83-96                                                                                    | Verbatim duplicate (copy-paste error)                                          | Remove second occurrence                                                                           |
| 13  | backend-architecture.typ "GeoService" vs. map-architecture.typ "Service Layer Abstraction"                                         | Both describe the same service                                                 | Consolidate into one location                                                                      |

---

## Savings Summary Table

| File                      | Section                                | Verdict                         | Lines Saved |
| ------------------------- | -------------------------------------- | ------------------------------- | ----------- |
| employee-customer.typ     | Entire file                            | MERGE into backend-architecture | 7           |
| data-persistence.typ      | Intro paragraph                        | ABRIDGE                         | 2           |
| data-persistence.typ      | Persistence Strategy (final paragraph) | ABRIDGE                         | 2           |
| data-persistence.typ      | Domain Modelling and Capabilities      | ABRIDGE                         | 8           |
| data-persistence.typ      | Schema Definition and Version Control  | MERGE with database-design      | 4           |
| data-persistence.typ      | Reactive Persistence                   | MERGE with real-time-events     | 3           |
| data-persistence.typ      | Many-to-Many Relationships             | MERGE with database-design      | 6           |
| data-persistence.typ      | Unified Identity Composition           | MERGE with database-design      | 4           |
| media-storage.typ         | Storage Abstraction Layer              | ABRIDGE during merge            | 2           |
| media-storage.typ         | Image Entity                           | MERGE with database-design      | 6           |
| backend-architecture.typ  | Sanctum Integration                    | ABRIDGE                         | 3           |
| backend-architecture.typ  | Dual User Type Architecture            | ABRIDGE                         | 2           |
| backend-architecture.typ  | Request Validation Architecture        | ABRIDGE                         | 12          |
| backend-architecture.typ  | Authorization Architecture             | ABRIDGE                         | 6           |
| backend-architecture.typ  | Controller Architecture                | ABRIDGE                         | 6           |
| backend-architecture.typ  | Service Layer Architecture             | ABRIDGE                         | 8           |
| backend-architecture.typ  | Middleware Architecture                | ABRIDGE                         | 5           |
| backend-architecture.typ  | Summary                                | ABRIDGE                         | 4           |
| frontend-architecture.typ | State & Data Flow                      | ABRIDGE                         | 4           |
| map-architecture.typ      | Section intro                          | ABRIDGE                         | 2           |
| map-architecture.typ      | Three-Phase Processing Pipeline        | ABRIDGE                         | 8           |
| map-architecture.typ      | Service Layer Abstraction              | MERGE with backend-architecture | 7           |
| map-architecture.typ      | Session-Based Location Persistence     | ABRIDGE                         | 12          |
| map-architecture.typ      | Component Hierarchy (ASCII tree)       | ABRIDGE                         | 14          |
| map-architecture.typ      | State Management Architecture          | ABRIDGE                         | 10          |
| map-architecture.typ      | Data Flow and Synchronization          | ABRIDGE                         | 18          |
| map-architecture.typ      | Controlled Map Component Pattern       | ABRIDGE                         | 7           |
| map-architecture.typ      | Geolocation Integration Pattern        | REMOVE                          | 13          |
| map-architecture.typ      | Query Optimization Strategy            | MERGE into implementation       | 14          |
| map-architecture.typ      | Bounding Box Prefilter Pattern         | MERGE into implementation       | 8           |
| map-architecture.typ      | Payload Shaping and Lazy Loading       | ABRIDGE                         | 6           |
| map-architecture.typ      | Architectural Guarantees               | ABRIDGE                         | 12          |
| map-architecture.typ      | Inertia.js Bridge Pattern              | REMOVE                          | 9           |
| map-architecture.typ      | Mapbox Integration Architecture        | ABRIDGE                         | 5           |
| map-architecture.typ      | Scalability and Performance            | ABRIDGE                         | 7           |
| map-architecture.typ      | Summary                                | ABRIDGE                         | 5           |
| database-design.typ       | Intro                                  | ABRIDGE                         | 2           |
| database-design.typ       | Schema Overview (meta-commentary)      | ABRIDGE                         | 4           |
| database-design.typ       | Images                                 | ABRIDGE                         | 2           |
| database-design.typ       | Reviews (surrogate key justification)  | ABRIDGE                         | 3           |
| database-design.typ       | System Columns (DUPLICATE)             | REMOVE                          | 14          |

---

## Total Estimated Line Savings

| File                      | Current Lines | Savings                                         | Resulting Lines                  |
| ------------------------- | ------------- | ----------------------------------------------- | -------------------------------- |
| system-architecture.typ   | 16            | 0 (update includes only)                        | 16                               |
| employee-customer.typ     | 7             | 7 (eliminated)                                  | 0                                |
| data-persistence.typ      | 59            | 29 (redistributed or eliminated)                | ~30 (or 0 if fully merged)       |
| media-storage.typ         | 16            | 8 net (eliminated; ~8 lines absorbed elsewhere) | 0                                |
| backend-architecture.typ  | 155           | 46                                              | ~109                             |
| frontend-architecture.typ | 48            | 4                                               | ~44                              |
| map-architecture.typ      | 307           | 155                                             | ~152                             |
| real-time-events.typ      | 18            | 0                                               | 18                               |
| database-design.typ       | 108           | 25                                              | ~83 (+absorbed content, net ~90) |
| **TOTAL**                 | **734**       | **~274**                                        | **~460**                         |

**Estimated total savings: ~274 lines across these architecture and database design sections.**

Note: Some savings are "redistributions" (content moving to implementation chapter or to another architecture section) rather than pure deletions. The net page-count reduction from genuine elimination of redundancy and verbosity is estimated at approximately **200-220 lines** of pure content removal, with the remaining ~55 lines being content relocated to more appropriate locations.

---

## Priority Actions (Highest Impact First)

1. **Fix the copy-paste duplicate in database-design.typ** (lines 83-96 identical to 69-81). Immediate 14-line saving, zero risk.

2. **Trim map-architecture.typ** from 307 to ~152 lines by:
   - Removing implementation detail (SQL patterns, component wiring, geolocation pattern): ~49 lines
   - Removing redundant sections (Inertia bridge, state management overlap): ~19 lines
   - Compressing verbose prose (data flow steps, ASCII diagrams, guarantees, summary): ~87 lines
   - Highest single-file impact: ~155 lines saved.

3. **Eliminate employee-customer.typ and media-storage.typ** as standalone sections. Merge their content (1 sentence and ~6 sentences respectively) into backend-architecture.typ and database-design.typ. Eliminates 2 shallow standalone sections.

4. **Merge or eliminate data-persistence.typ** by distributing unique architectural content to database-design.typ and implementation detail to implementation/database.typ. Saves ~29 lines and removes a section that substantially overlaps with database-design.

5. **Trim backend-architecture.typ** by condensing validation/authorization to architectural principles only, compressing implementation examples (ReviewService, order policies), and tightening the summary. Saves ~46 lines.
