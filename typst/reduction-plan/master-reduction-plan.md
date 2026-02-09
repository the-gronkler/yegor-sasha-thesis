# Master Reduction Plan — Thesis (155 → 110-130 pages)

## Executive Summary

| Metric                                 | Value                                            |
| -------------------------------------- | ------------------------------------------------ |
| Total source lines across all chapters | ~4,275                                           |
| Total proposed savings (all tiers)     | ~1,727 lines                                     |
| Target reduction                       | 625–1,125 lines (~25–45 pages at ~25 lines/page) |
| Tier 1 savings alone                   | ~820 lines                                       |
| Tier 1 + Tier 2 savings                | ~1,440 lines                                     |
| Prediction                             | Target achievable with Tier 1 + partial Tier 2   |

The analyses identified ~1,727 lines of saveable content. Even executing only Tier 1 (high-impact, low-risk) changes achieves the minimum target. Tier 2 provides comfortable margin. Tier 3 is optional and should only be pursued if further reduction is desired.

---

## Tier Classification Overview

### Tier 1 — High-Impact, Low-Risk (~820 lines)

Zero content loss or only removing duplicates/restated material:

- Copy-paste duplicate removal (database-design.typ)
- Empty stub file removal (planning.typ, documentation.typ, automations.typ)
- Replacing migration/model code blocks with summary table + `source_code_link()`
- Removing architecture re-explanations from implementation chapter
- Moving TypeScript interfaces to `source_code_link()` references
- Removing per-section summaries that restate preceding content
- Eliminating unimplemented requirements

### Tier 2 — Medium-Impact (~620 lines)

Condensing verbose content:

- Converting prose technology comparisons to tables
- Removing textbook explanations
- Condensing generic DevOps/process descriptions
- Trimming UC prose that duplicates structured tables
- Compressing verbose code blocks to essential patterns
- Removing trivial code examples (standard framework patterns)

### Tier 3 — Requires Judgment (~287 lines)

Structural changes and boundary decisions:

- Eliminating standalone architecture files (data-persistence, employee-customer, media-storage)
- Merging orm.typ with backend-technologies.typ
- Major restructuring of map-functionality.typ
- Significant condensation of thesis-documentation.typ and ai-use.typ

---

## Chapter 1: Requirements & Context

**Current total: ~412 lines | Proposed savings: ~98 lines | Target: ~314 lines**

### Tier 1 Actions

| #   | File                          | Section / Lines                                    | Action                                                                                        | Savings | Cumulative |
| --- | ----------------------------- | -------------------------------------------------- | --------------------------------------------------------------------------------------------- | ------- | ---------- |
| R1  | `functional-requirements.typ` | "Order Sharing" (lines 45-47)                      | **REMOVE** — no UC, no UCD, not implemented                                                   | 3       | 3          |
| R2  | `functional-requirements.typ` | "Dynamic Pricing and Promotions" (lines 68-70)     | **REMOVE** — no UC, no UCD, not implemented                                                   | 3       | 6          |
| R3  | `use-case-diagram.typ`        | "System Actions" rating recalc (lines 62-63)       | **MERGE** with FR "Ratings and Reviews" — verbatim duplicate                                  | 3       | 9          |
| R4  | `aims-and-objectives.typ`     | "Technical Robustness" (lines 23-24)               | **REMOVE** — one-line summary of entire NFR chapter                                           | 2       | 11         |
| R5  | `context.typ`                 | "Industry Standards and Regulations" (lines 56-60) | **MERGE** with "External Factors > Regulatory Factors" (line 25) — same GDPR content restated | 5       | 16         |

**Risk:** R1/R2 remove unimplemented requirements. If evaluator expects all requirements to be aspirational, move to "Future Work" instead of deleting. Low risk.

### Tier 2 Actions

| #   | File                              | Section / Lines                                                          | Action                                                                                                      | Savings | Cumulative |
| --- | --------------------------------- | ------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| R6  | `use-case-scenarios.typ`          | UC1 prose before figure (lines 10-20)                                    | **ABRIDGE** to 2-3 sentences — duplicates the scenario table below                                          | 8       | 24         |
| R7  | `use-case-scenarios.typ`          | UC2 prose before figure (lines 59-72)                                    | **ABRIDGE** to 2-3 sentences — duplicates the scenario table below. Fix typo line 63.                       | 8       | 32         |
| R8  | `use-case-scenarios.typ`          | UC3 prose before figure (lines 119-128)                                  | **ABRIDGE** to 1-2 sentences                                                                                | 5       | 37         |
| R9  | `use-case-scenarios.typ`          | UC1 table nested sub-alternatives (lines 46-49)                          | **ABRIDGE** — compress "Browsing restaurants using map filters" to one line                                 | 4       | 41         |
| R10 | `use-case-scenarios.typ`          | UC2 table "item becomes unavailable" (lines 105-108)                     | **ABRIDGE** — compress to 2 lines                                                                           | 3       | 44         |
| R11 | `use-case-diagram.typ`            | "Customer-Centric Functionality" (lines 23-41)                           | **ABRIDGE** — replace prose paragraphs with 1-sentence summaries per module referencing FR chapter          | 8       | 52         |
| R12 | `use-case-diagram.typ`            | "Restaurant Management Functionality" (lines 44-57)                      | **ABRIDGE** — same treatment as R11                                                                         | 5       | 57         |
| R13 | `use-case-diagram.typ`            | Introduction paragraph (lines 3-5)                                       | **ABRIDGE** — remove boilerplate, keep 1 sentence                                                           | 2       | 59         |
| R14 | `use-case-diagram.typ`            | "Actors and Roles" Payment System + System Actions entries (lines 20-21) | **ABRIDGE** — trim to one clause each                                                                       | 3       | 62         |
| R15 | `context.typ`                     | Opening paragraph + Business Context (lines 1-13)                        | **MERGE/ABRIDGE** — collapse into single paragraph, eliminate restated motivation                           | 9       | 71         |
| R16 | `context.typ`                     | "External Factors" (lines 15-25)                                         | **ABRIDGE** — cut Market Trends first sentence, trim Competition, remove or trim Technological Advancements | 6       | 77         |
| R17 | `context.typ`                     | "Stakeholders" expectation lists (lines 27-47)                           | **ABRIDGE** — remove expectation sub-lists, replace with cross-references to FR chapter                     | 6       | 83         |
| R18 | `context.typ`                     | "Other Systems and Integrations" (lines 49-54)                           | **ABRIDGE** to single sentence                                                                              | 4       | 87         |
| R19 | `functional-requirements.typ`     | "Ratings and Reviews" (lines 42-43)                                      | **ABRIDGE** — remove implementation detail                                                                  | 2       | 89         |
| R20 | `functional-requirements.typ`     | "Customization Options" (line 61)                                        | **ABRIDGE** — remove UI detail                                                                              | 2       | 91         |
| R21 | `non-functional-requirements.typ` | Security 2FA line (line 9)                                               | **ABRIDGE** — add "future consideration" qualifier or remove if unimplemented                               | 1       | 92         |
| R22 | `non-functional-requirements.typ` | Scalability (line 12)                                                    | **ABRIDGE** — remove repeated example list                                                                  | 1       | 93         |
| R23 | `non-functional-requirements.typ` | Portability (line 29)                                                    | **ABRIDGE** — move misplaced usability requirement                                                          | 1       | 94         |
| R24 | `aims-and-objectives.typ`         | Aim paragraph (lines 1-3)                                                | **ABRIDGE** — shorten since context chapter frames problem                                                  | 2       | 96         |
| R25 | `aims-and-objectives.typ`         | "Customization and Scalability" (line 18)                                | **ABRIDGE** — remove repeated example list                                                                  | 1       | 97         |
| R26 | `functional-requirements.typ`     | "Analytics and Reporting" (lines 72-73)                                  | **ABRIDGE** — add specifics or remove if unimplemented                                                      | 1       | 98         |

**Chapter 1 total: 98 lines saved | Running grand total: 98**

---

## Chapter 2: Technologies

**Current total: ~390 lines | Proposed savings: ~177 lines | Target: ~213 lines**

### Tier 1 Actions

| #   | File                       | Section / Lines                                                    | Action                                                                                                                   | Savings | Cumulative |
| --- | -------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ | ------- | ---------- |
| T1  | `database.typ`             | "JSON Compatibility" (lines 18-20)                                 | **REMOVE** — explicitly stated as unused in schema                                                                       | 3       | 101        |
| T2  | `database.typ`             | "Multi-Master Replication" (lines 22-26)                           | **REMOVE** — speculative future scaling for a single-instance academic project                                           | 5       | 106        |
| T3  | `blob-storage.typ`         | "Edge Integration" (lines 20-21)                                   | **REMOVE** — hedges with "not strictly a storage feature," CDN not demonstrated                                          | 2       | 108        |
| T4  | `map-technologies.typ`     | "Summary" (lines 52-63)                                            | **REMOVE** — 12-line summary restating what was just said                                                                | 10      | 118        |
| T5  | `backend-technologies.typ` | "PHP Language Maturity and Framework Ecosystem" (lines 21-31)      | **REMOVE** — 11-line defensive essay about PHP's reputation. Evaluator doesn't need convincing. Replace with 1 sentence. | 11      | 129        |
| T6  | `orm.typ`                  | "Comparative Analysis: Eloquent vs. Enterprise ORMs" (lines 39-61) | **REMOVE** or heavily ABRIDGE to ~4 lines — 23-line standalone essay on ORM philosophy; Eloquent is a given with Laravel | 16      | 145        |

### Tier 2 Actions

| #   | File                       | Section / Lines                                                 | Action                                                                                                                                                       | Savings | Cumulative |
| --- | -------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- | ---------- |
| T7  | `react-frontend.typ`       | "Framework Selection Rationale" all 7 bullets (lines 9-23)      | **REPLACE** prose with 3-column comparison table (Framework \| Ecosystem \| Inertia Support \| Key Tradeoff) + 2-3 sentences                                 | 12      | 157        |
| T8  | `database.typ`             | "Comparison with Alternatives" (lines 43-51)                    | **REPLACE** prose with compact comparison table                                                                                                              | 5       | 162        |
| T9  | `blob-storage.typ`         | "Comparison with Alternatives" (lines 23-29)                    | **REPLACE** prose with compact comparison table                                                                                                              | 4       | 166        |
| T10 | `orm.typ`                  | "Active Record vs. Data Mapper" (lines 27-37)                   | **ABRIDGE** 11 lines to ~4-line concise paragraph                                                                                                            | 6       | 172        |
| T11 | `orm.typ`                  | "Key Technical Advantages" subsections (lines 10-24)            | **ABRIDGE** each to 1 sentence: Relationship Definitions (-2), Attribute Casting (-2), Query Scopes (-2), Computed Attributes (-2), Enumeration Support (-4) | 12      | 184        |
| T12 | `orm.typ`                  | Opening paragraph (lines 3-5)                                   | **ABRIDGE** — remove trailing promise                                                                                                                        | 1       | 185        |
| T13 | `database.typ`             | Opening paragraph (lines 3-5)                                   | **ABRIDGE** — remove laundry list                                                                                                                            | 2       | 187        |
| T14 | `database.typ`             | "Native Geospatial Support" (lines 10-12)                       | **MERGE** with map-technologies.typ — replace with 1-sentence forward reference                                                                              | 2       | 189        |
| T15 | `database.typ`             | "Performance Characteristics" (lines 14-16)                     | **ABRIDGE** to 1 sentence                                                                                                                                    | 2       | 191        |
| T16 | `database.typ`             | "Licensing and Ecosystem" (lines 28-30)                         | **ABRIDGE** to 1 sentence                                                                                                                                    | 2       | 193        |
| T17 | `database.typ`             | "Limitations" (lines 32-41)                                     | **ABRIDGE** — combine 4 paragraphs into 1 paragraph + brief bullet list                                                                                      | 4       | 197        |
| T18 | `inertia.typ`              | Opening paragraph (lines 3-5)                                   | **ABRIDGE** — cut textbook SPA vs server-rendered framing                                                                                                    | 2       | 199        |
| T19 | `inertia.typ`              | REST API description (lines 9-11)                               | **ABRIDGE** to 1 sentence                                                                                                                                    | 2       | 201        |
| T20 | `inertia.typ`              | "Single Source of Truth" + "Reduced Duplication" (lines 21, 23) | **MERGE** into single bullet                                                                                                                                 | 3       | 204        |
| T21 | `inertia.typ`              | "Laravel Ecosystem Integration" (line 27)                       | **MERGE** — overlaps with backend-technologies.typ line 15                                                                                                   | 2       | 206        |
| T22 | `inertia.typ`              | "Partial Reloads" (line 29)                                     | **ABRIDGE** — move implementation detail to Implementation chapter                                                                                           | 4       | 210        |
| T23 | `react-frontend.typ`       | "TypeScript: Type Safety" (lines 25-27)                         | **ABRIDGE** — remove textbook definition                                                                                                                     | 2       | 212        |
| T24 | `react-frontend.typ`       | "Build Tooling with Vite" (lines 35-45)                         | **ABRIDGE** — remove generic Vite features, keep Laravel Integration only                                                                                    | 5       | 217        |
| T25 | `react-frontend.typ`       | "Client-Side Search with Fuse.js" (lines 47-65)                 | **ABRIDGE** — remove API documentation bullets, keep project rationale                                                                                       | 8       | 225        |
| T26 | `map-technologies.typ`     | "Map Visualization" alternatives (lines 28-30)                  | **ABRIDGE** to 2 sentences or table rows                                                                                                                     | 3       | 228        |
| T27 | `map-technologies.typ`     | "React Integration" alternative paragraph (lines 37-38)         | **REMOVE** — unnecessary negative justification                                                                                                              | 2       | 230        |
| T28 | `map-technologies.typ`     | "Location Persistence" (lines 40-49)                            | **ABRIDGE** from 10 to 4 lines                                                                                                                               | 5       | 235        |
| T29 | `map-technologies.typ`     | "Geospatial Computation" PostGIS overlap (lines 13-14)          | **ABRIDGE** slightly after consolidation with database.typ                                                                                                   | 2       | 237        |
| T30 | `backend-technologies.typ` | "Framework Selection Rationale" (lines 7-19)                    | **ABRIDGE** — compress Ecosystem Alignment to forward ref, remove Team Familiarity, trim Deployment Simplicity                                               | 4       | 241        |
| T31 | `backend-technologies.typ` | "Queue System Selection" (lines 33-43)                          | **ABRIDGE** to 2-3 sentences                                                                                                                                 | 5       | 246        |
| T32 | `blob-storage.typ`         | "Cost Efficiency and Free Tier" (lines 11-12)                   | **ABRIDGE** — remove duplicate sentence                                                                                                                      | 1       | 247        |

### Tier 3 Actions

| #   | File                                                    | Section / Lines           | Action                                                                                                                     | Savings                                                | Cumulative |
| --- | ------------------------------------------------------- | ------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ | ---------- |
| T33 | `technologies.typ`                                      | Chapter intro (lines 3-5) | **ADD** paragraph about Laravel ecosystem alignment to reduce boilerplate in individual sections                           | -2 (adds 2 lines but enables ~5 lines saved elsewhere) | 247        |
| T34 | Consider merging `orm.typ` + `backend-technologies.typ` | Entire files              | **MERGE** into "Backend Framework and ORM" section — Eloquent is inseparable from Laravel                                  | ~8                                                     | 255        |
| T35 | Cross-cutting "integrates with Laravel" dedup           | Multiple files            | After T33, trim individual "Laravel integration" claims to forward references                                              | ~5                                                     | 260        |
| T36 | Consolidated comparison table at chapter start          | `technologies.typ`        | **ADD** summary table (Category \| Technology \| Rationale \| Alternatives) reducing need for per-section comparison prose | ~15                                                    | 275        |

**Chapter 2 total: 177 lines saved | Running grand total: 275**

---

## Chapter 3: Development Process

**Current total: ~295 lines | Proposed savings: ~152 lines | Target: ~143 lines**

### Tier 1 Actions

| #   | File                       | Section / Lines                           | Action                                                                                                        | Savings | Cumulative |
| --- | -------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| D1  | `planning.typ`             | Entire file (5 lines)                     | **REMOVE** — stub with only heading + `...` placeholder. Remove from `development-process-main.typ` includes. | 6       | 281        |
| D2  | `documentation.typ`        | Entire file (5 lines)                     | **REMOVE** — identical stub situation. Remove from includes.                                                  | 6       | 287        |
| D3  | `automations.typ`          | Entire file (27 lines)                    | **REMOVE** — all commented-out code, renders as empty section. Remove from includes.                          | 28      | 315        |
| D4  | `overview.typ`             | Bulleted chapter outline (lines 9-16)     | **REMOVE** — table-of-contents preview filler; reader has actual TOC                                          | 7       | 322        |
| D5  | `thesis-documentation.typ` | "Typst vs. WYSIWYG Editors" (lines 30-34) | **REMOVE** — comparing Typst to Word is not meaningful                                                        | 5       | 327        |
| D6  | `thesis-documentation.typ` | "Workflow and Versioning" (lines 44-47)   | **REMOVE** — explicitly says "as detailed in Version Control section" then restates it                        | 3       | 330        |

### Tier 2 Actions

| #   | File                       | Section / Lines                                             | Action                                                                                                                                                                                                     | Savings | Cumulative |
| --- | -------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| D7  | `version-control.typ`      | "Commit Conventions" (lines 26-73)                          | **ABRIDGE** heavily — 48 lines enumerating every commit type/scope. Keep 1 sentence citing Conventional Commits spec, 1 format example, 2 commit examples. Move full tables to appendix or reference spec. | 30      | 360        |
| D8  | `version-control.typ`      | "Pull Request Process" (lines 13-24)                        | **ABRIDGE** to 2-3 sentences — generic DevOps textbook content                                                                                                                                             | 7       | 367        |
| D9  | `version-control.typ`      | Intro paragraph (lines 3-5)                                 | **ABRIDGE** — textbook definition of version control                                                                                                                                                       | 2       | 369        |
| D10 | `thesis-documentation.typ` | "Typst vs. LaTeX" (lines 17-28)                             | **ABRIDGE** from 12 lines to 2-3 sentences — tool marketing pitch                                                                                                                                          | 8       | 377        |
| D11 | `thesis-documentation.typ` | "Typst Integration" (lines 7-15)                            | **ABRIDGE** — remove hedging about Typst mixing styling                                                                                                                                                    | 4       | 381        |
| D12 | `thesis-documentation.typ` | "Repository Structure" (lines 36-43)                        | **MERGE** with "Typst Integration" — self-evident structure                                                                                                                                                | 5       | 386        |
| D13 | `ai-use.typ`               | "Agent Instructions (AGENTS.md)" (lines 16-35)              | **ABRIDGE** heavily — 3 paragraphs making same point with 3 citations + 8-item bulleted techniques list. Replace entire list with 1 sentence. Keep 1 citation, 1 explanation.                              | 13      | 399        |
| D14 | `ai-use.typ`               | "Ethical Considerations" (lines 38-47)                      | **ABRIDGE** — merge Research Integrity and Development Security sub-paragraphs into one. Remove boilerplate closing.                                                                                       | 6       | 405        |
| D15 | `ai-use.typ`               | "Impact and Limitations" (lines 49-55)                      | **ABRIDGE** — trim Limitations paragraph                                                                                                                                                                   | 3       | 408        |
| D16 | `ai-use.typ`               | "AI in Research" (lines 6-9)                                | **ABRIDGE** to 2 sentences                                                                                                                                                                                 | 2       | 410        |
| D17 | `deployment.typ`           | "Container Orchestration" general description (lines 14-20) | **ABRIDGE** — collapse 3-bullet textbook comparison to 1 paragraph                                                                                                                                         | 8       | 418        |
| D18 | `deployment.typ`           | "Application Service" rationale bullets (lines 26-37)       | **ABRIDGE** — each bullet reduce to 1 sentence                                                                                                                                                             | 4       | 422        |
| D19 | `deployment.typ`           | "Database Service" Docker volume explanation (lines 46-48)  | **ABRIDGE** — remove basic Docker knowledge                                                                                                                                                                | 2       | 424        |
| D20 | `overview.typ`             | Opening paragraph (lines 3-8)                               | **ABRIDGE** — tighten to 3 sentences                                                                                                                                                                       | 3       | 427        |

**Chapter 3 total: 152 lines saved | Running grand total: 427**

**Note:** If deployment service descriptions overlap with system architecture chapter, an additional ~15-20 lines could be saved via cross-referencing (see Cross-Chapter Operations).

---

## Chapter 4: System Architecture & Database Design

**Current total: ~734 lines | Proposed savings: ~274 lines | Target: ~460 lines**

### Tier 1 Actions

| #   | File                   | Section / Lines                                                    | Action                                                                                                                                 | Savings | Cumulative |
| --- | ---------------------- | ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| A1  | `database-design.typ`  | Lines 83-96 (second copy of "System Columns")                      | **REMOVE** — character-for-character copy-paste duplicate of lines 69-81                                                               | 14      | 441        |
| A2  | `map-architecture.typ` | "Inertia.js Bridge Pattern" (lines 251-259)                        | **REMOVE** — restates standard Inertia partial reload, already in frontend-architecture.typ and Data Flow section                      | 9       | 450        |
| A3  | `map-architecture.typ` | "Geolocation Integration Pattern" (lines 174-186)                  | **REMOVE** — component-level wiring detail, not architecture. Move to implementation if desired.                                       | 13      | 463        |
| A4  | `map-architecture.typ` | "Query Optimization Strategy" (lines 188-201)                      | **MOVE** to implementation chapter — SQL patterns are implementation, not architecture. Keep 2-line principle in Three-Phase Pipeline. | 14      | 477        |
| A5  | `map-architecture.typ` | "Bounding Box Prefilter Pattern" (lines 203-212)                   | **MOVE** to implementation chapter — SQL WHERE/HAVING clauses are implementation                                                       | 8       | 485        |
| A6  | `map-architecture.typ` | "Summary" restated bullets (lines 295-307)                         | **ABRIDGE** from 13 to 5 lines                                                                                                         | 5       | 490        |
| A7  | `map-architecture.typ` | "Data Flow and Synchronization" step-by-step flows (lines 132-160) | **ABRIDGE** — compress 29 lines of numbered steps to prose paragraphs (~11 lines)                                                      | 18      | 508        |

### Tier 2 Actions

| #   | File                        | Section / Lines                                                             | Action                                                                                                            | Savings | Cumulative |
| --- | --------------------------- | --------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| A8  | `map-architecture.typ`      | "Session-Based Location Persistence" ASCII diagram (lines 64-78)            | **ABRIDGE** — replace 16-line ASCII diagram with 2-3 sentence prose                                               | 12      | 520        |
| A9  | `map-architecture.typ`      | "Component Hierarchy" ASCII tree (lines 88-106) + SRP explanation (108-112) | **ABRIDGE** — compress tree to top 2 levels (5 lines), remove SRP explanation                                     | 14      | 534        |
| A10 | `map-architecture.typ`      | "State Management Architecture" (lines 114-131)                             | **ABRIDGE** — compress to 6 lines with cross-ref to frontend-architecture.typ                                     | 10      | 544        |
| A11 | `map-architecture.typ`      | "Three-Phase Processing Pipeline" motivation (lines 29-37)                  | **ABRIDGE** — 9-line motivation to 3 sentences                                                                    | 8       | 552        |
| A12 | `map-architecture.typ`      | "Controlled Map Component Pattern" (lines 162-172)                          | **ABRIDGE** to 3 lines — standard React controlled component                                                      | 7       | 559        |
| A13 | `map-architecture.typ`      | "Architectural Guarantees" (lines 225-249)                                  | **ABRIDGE** — keep Radius Determinism + Session Isolation (2 lines each), fold/remove others                      | 12      | 571        |
| A14 | `map-architecture.typ`      | "Service Layer Abstraction" (lines 49-58)                                   | **MERGE** with backend-architecture.typ GeoService reference — keep 2-line reference here                         | 7       | 578        |
| A15 | `map-architecture.typ`      | "Payload Shaping and Lazy Loading" (lines 214-223)                          | **ABRIDGE** from 10 to 4 lines                                                                                    | 6       | 584        |
| A16 | `map-architecture.typ`      | "Scalability and Performance" (lines 272-293)                               | **ABRIDGE** — remove duplicate limit/computation points, reference database-design for indexing                   | 7       | 591        |
| A17 | `map-architecture.typ`      | "Mapbox Integration Architecture" (lines 261-270)                           | **ABRIDGE** — remove tangential GPU/declarative rendering commentary                                              | 5       | 596        |
| A18 | `map-architecture.typ`      | Section intro (lines 3-5)                                                   | **ABRIDGE** to 1-sentence overview                                                                                | 2       | 598        |
| A19 | `backend-architecture.typ`  | "Request Validation Architecture" (lines 35-56)                             | **ABRIDGE** from 22 to ~10 lines — standard Laravel pattern over-explained. Move rate limiting to implementation. | 12      | 610        |
| A20 | `backend-architecture.typ`  | "Service Layer Architecture" (lines 107-124)                                | **ABRIDGE** — compress ReviewService example, remove GeoService (covered in map-architecture)                     | 8       | 618        |
| A21 | `backend-architecture.typ`  | "Controller Architecture" (lines 86-105)                                    | **ABRIDGE** — compress thin controller pattern explanation                                                        | 6       | 624        |
| A22 | `backend-architecture.typ`  | "Authorization Architecture" (lines 58-85)                                  | **ABRIDGE** — compress policy rules enumeration, reduce admin bypass to 1 sentence                                | 6       | 630        |
| A23 | `backend-architecture.typ`  | "Middleware Architecture" (lines 126-142)                                   | **ABRIDGE** — compress shared data 3-bullet list to 1 sentence                                                    | 5       | 635        |
| A24 | `backend-architecture.typ`  | "Summary" (lines 145-155)                                                   | **ABRIDGE** from 11 to 6 lines                                                                                    | 4       | 639        |
| A25 | `backend-architecture.typ`  | "Sanctum Integration" (lines 21-27)                                         | **ABRIDGE** to 2 sentences                                                                                        | 3       | 642        |
| A26 | `backend-architecture.typ`  | "Dual User Type Architecture" (lines 29-33)                                 | **ABRIDGE** — remove schema description (already in database-design), keep architectural implication              | 2       | 644        |
| A27 | `frontend-architecture.typ` | "State & Data Flow" Route Configuration (lines 21-33)                       | **ABRIDGE** — trim Ziggy mention and component communication restatement                                          | 4       | 648        |
| A28 | `database-design.typ`       | Intro second paragraph (line 7)                                             | **ABRIDGE** to 1 sentence                                                                                         | 2       | 650        |
| A29 | `database-design.typ`       | "Schema Overview" meta-commentary + tool note (lines 16-24)                 | **ABRIDGE** — remove crow's foot explanation, remove meta-commentary                                              | 4       | 654        |
| A30 | `database-design.typ`       | "Reviews" surrogate key justification (lines 53-55)                         | **ABRIDGE** to 1-2 sentences — common practice, over-justified                                                    | 3       | 657        |
| A31 | `database-design.typ`       | "Images" FK explanation verbosity (lines 43-44)                             | **ABRIDGE** to 2 sentences                                                                                        | 2       | 659        |
| A32 | `data-persistence.typ`      | "Domain Modelling and Capabilities" bullet list (lines 14-31)               | **ABRIDGE** — collapse 7-item generic ORM capability list to 2-3 sentences                                        | 8       | 667        |
| A33 | `data-persistence.typ`      | "Schema Definition and Version Control" (lines 33-34)                       | **MERGE** with database-design.typ — replace with 1-sentence cross-reference                                      | 4       | 671        |
| A34 | `data-persistence.typ`      | "Reactive Persistence" (lines 43-44)                                        | **MERGE** with real-time-events.typ                                                                               | 3       | 674        |
| A35 | `data-persistence.typ`      | "Handling Many-to-Many Relationships" (lines 46-53)                         | **MERGE** with database-design.typ "Orders" section — compress from 8 to 4 lines                                  | 6       | 680        |
| A36 | `data-persistence.typ`      | "Unified Identity Composition" (lines 55-57)                                | **MERGE** with database-design.typ "User and Role Data"                                                           | 4       | 684        |
| A37 | `data-persistence.typ`      | Intro paragraph + Persistence Strategy trailing sentence (lines 3-12)       | **ABRIDGE**                                                                                                       | 4       | 688        |

### Tier 3 Actions

| #   | File                                                 | Section / Lines                                                                                                                                                                                                             | Action                                                                                                                                        | Savings | Cumulative |
| --- | ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| A38 | `employee-customer.typ`                              | Entire file (7 lines)                                                                                                                                                                                                       | **ELIMINATE** as standalone section — merge 1 sentence into backend-architecture.typ "Layered Architecture Overview"                          | 7       | 695        |
| A39 | `media-storage.typ`                                  | Entire file (16 lines)                                                                                                                                                                                                      | **ELIMINATE** as standalone section — merge ~8 lines of unique content into database-design.typ "Images" and data-persistence "Virtual State" | 8       | 703        |
| A40 | Consider eliminating `data-persistence.typ` entirely | After A32-A37 applied, ~30 lines remain. Unique content redistributed to database-design.typ, real-time-events.typ, and backend-architecture.typ. Keep only if residual architectural content justifies standalone section. | ~0 (savings already counted above)                                                                                                            | 703     |

**Chapter 4 total: 276 lines saved | Running grand total: 703**

---

## Chapter 5: Implementation

**Current total: ~2,444 lines | Proposed savings: ~1,026 lines | Target: ~1,418 lines**

### Tier 1 Actions

| #   | File                    | Section / Lines                                                         | Action                                                                                                                            | Savings | Cumulative |
| --- | ----------------------- | ----------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| I1  | `database.typ`          | "Migration Structure" users migration code block (lines 13-39)          | **REPLACE** code with 2-line prose summary + `source_code_link("database/migrations")`                                            | 28      | 731        |
| I2  | `database.typ`          | "Role-Specific Profile Tables" both code blocks (lines 44-81)           | **ABRIDGE** — show ONE example (employees) + prose for other. Replace with summary + source_code_link.                            | 25      | 756        |
| I3  | `database.typ`          | "Menu Hierarchy Implementation" both code blocks (lines 83-119)         | **REPLACE** with prose paragraph + source_code_links                                                                              | 28      | 784        |
| I4  | `database.typ`          | "Many-to-Many Pivots" (lines 121-164)                                   | **ABRIDGE** — show only order_items (stateful pivot), describe allergen in prose                                                  | 20      | 804        |
| I5  | `database.typ`          | "Geospatial Column Definition" restaurant migration (lines 166-188)     | **REPLACE** code with brief reference to ERD + source_code_link                                                                   | 18      | 822        |
| I6  | `database.typ`          | "Model Relationship Definitions" 3 code blocks (lines 190-276)          | **ABRIDGE** — show only MenuItem model (most non-trivial), replace User + Restaurant with prose + source_code_links               | 50      | 872        |
| I7  | `database.typ`          | "Database Seeding Strategy" (lines 355-454)                             | **ABRIDGE** — keep OrderStatusSeeder, summarize DatabaseSeeder + RestaurantSeeder in prose + source_code_links                    | 45      | 917        |
| I8  | `database.typ`          | "Artisan Command for Database Reset" (lines 462-495)                    | **ABRIDGE** — replace 22-line code block with 3-4 line prose paragraph + source_code_link                                         | 28      | 945        |
| I9  | `map-functionality.typ` | "Requirements translated into implementation constraints" (lines 19-36) | **REMOVE** — entire section restates architecture chapter goals. Line 35-36 confirms this.                                        | 18      | 963        |
| I10 | `map-functionality.typ` | "Database indexing strategy for geospatial queries" (lines 300-308)     | **REMOVE** — directly restates map-architecture "Strategic Indexing"                                                              | 9       | 972        |
| I11 | `map-functionality.typ` | "Summary" (lines 714-734)                                               | **REMOVE** — 21 lines of bullets referencing @labels from architecture chapter. Architecture already has summary.                 | 21      | 993        |
| I12 | `map-functionality.typ` | "MapLayout: preventing body scroll conflicts" (lines 412-436)           | **REMOVE** — 25 lines about CSS overflow:hidden. Standard full-screen UI pattern. Replace with 1 sentence in composition section. | 22      | 1015       |
| I13 | `map-functionality.typ` | "Phase B to Phase C boundary" (lines 226-229)                           | **REMOVE** — internal code organization detail, not thesis-worthy                                                                 | 4       | 1019       |
| I14 | `frontend-types.typ`    | "Centralized Model Definitions" code block (lines 8-51)                 | **ABRIDGE** — replace 35-line full interfaces with 1 short example + `source_code_link("resources/js/types/models.ts")`           | 25      | 1044       |
| I15 | `frontend-types.typ`    | "Enumerations for Finite States" code block (lines 52-73)               | **ABRIDGE** — replace code with 1 sentence + source_code_link                                                                     | 13      | 1057       |
| I16 | `frontend-types.typ`    | "Generic Pagination Interface" code block (lines 75-101)                | **ABRIDGE** — standard Laravel pagination shape. Replace with 2-line description.                                                 | 18      | 1075       |
| I17 | `frontend-types.typ`    | "Custom Hook Type Exports" code block (lines 153-175)                   | **REMOVE** — direct duplication of code shown in frontend-search.typ                                                              | 18      | 1093       |
| I18 | `frontend-forms.typ`    | "Optional Field Reset on Success" (lines 143-157)                       | **REMOVE** — duplicates content from "Basic useForm Pattern" within same file                                                     | 14      | 1107       |
| I19 | `broadcasting.typ`      | "Backend Event Broadcasting" OrderUpdated code block (lines ~20-38)     | **REPLACE** standard event class with prose + source_code_link. Keep booted() pattern.                                            | 15      | 1122       |
| I20 | `broadcasting.typ`      | "Channel Security" channel auth code block (lines ~155-169)             | **REPLACE** standard channel auth with prose + source_code_link                                                                   | 15      | 1137       |

### Tier 2 Actions

| #   | File                          | Section / Lines                                                                           | Action                                                                                                                                                                                  | Savings | Cumulative |
| --- | ----------------------------- | ----------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| I21 | `database.typ`                | "Query Scopes for Geospatial Filtering" (lines 278-321)                                   | **ABRIDGE** — show only `scopeWithinRadiusKm` (most complex), describe others in prose. This becomes canonical location for geospatial pattern (dedups with map-functionality Phase B). | 15      | 1152       |
| I22 | `map-functionality.typ`       | Phase A intro (lines 76-84) + closing sentence (121-122)                                  | **ABRIDGE** — cut restated priority cascade to 1-sentence cross-ref, cut closing                                                                                                        | 10      | 1162       |
| I23 | `map-functionality.typ`       | "Session-based geolocation persistence" constants list (lines 153-159)                    | **REMOVE** — internal constants not thesis-worthy                                                                                                                                       | 7       | 1169       |
| I24 | `map-functionality.typ`       | "Session-based geolocation persistence" prose overlap (lines 123-141)                     | **ABRIDGE** — reference architecture for pattern, keep code block only                                                                                                                  | 8       | 1177       |
| I25 | `map-functionality.typ`       | Phase B (lines 163-224)                                                                   | **ABRIDGE** — remove getBoundingBox code block (already shown in database.typ scopes), trim intro restating architecture                                                                | 30      | 1207       |
| I26 | `map-functionality.typ`       | Phase C (lines 231-298)                                                                   | **ABRIDGE** — merge 2 code blocks into 1, cut restated prose                                                                                                                            | 20      | 1227       |
| I27 | `map-functionality.typ`       | "Authorization, validation" restated explanation (lines 68-74)                            | **ABRIDGE** to 1-sentence cross-ref                                                                                                                                                     | 8       | 1235       |
| I28 | `map-functionality.typ`       | "Distance formatting and payload optimization" (lines 336-357)                            | **ABRIDGE** — remove trivial formatDistance code, keep 2-3 lines referencing architecture                                                                                               | 16      | 1251       |
| I29 | `map-functionality.typ`       | "Frontend implementation" intro (lines 359-365)                                           | **ABRIDGE** — remove restated component hierarchy + duplicate source_code_links                                                                                                         | 5       | 1256       |
| I30 | `map-functionality.typ`       | "Entry composition" TSX code block (lines 367-410)                                        | **ABRIDGE** from 35 to ~15 lines — show key composition, not all props                                                                                                                  | 18      | 1274       |
| I31 | `map-functionality.typ`       | "useMapPage" bullet list (lines 441-445)                                                  | **ABRIDGE** — cut restated architecture bullets to 1 sentence, keep code                                                                                                                | 8       | 1282       |
| I32 | `map-functionality.typ`       | "'Search here'" (lines 469-500)                                                           | **ABRIDGE** — replace code block with prose + source_code_link, keep threshold note                                                                                                     | 18      | 1300       |
| I33 | `map-functionality.typ`       | "Geolocation integration" error handler code (lines 530-553)                              | **ABRIDGE** — replace standard error switch with 2-line prose + source_code_link                                                                                                        | 22      | 1322       |
| I34 | `map-functionality.typ`       | "Map component" flyTo + token validation code (lines 615-653)                             | **ABRIDGE** — remove standard Mapbox API call and defensive boilerplate                                                                                                                 | 25      | 1347       |
| I35 | `map-functionality.typ`       | "Bottom sheet" code blocks (lines 670-712)                                                | **ABRIDGE** — keep prose techniques, replace code with source_code_links                                                                                                                | 25      | 1372       |
| I36 | `map-functionality.typ`       | "Main implementation artifacts" list (lines 7-17)                                         | **ABRIDGE** to 4-5 primary files                                                                                                                                                        | 5       | 1377       |
| I37 | `broadcasting.typ`            | "Backend Event Broadcasting" SoC/OCP intro (lines 10-15)                                  | **ABRIDGE** to 1 sentence                                                                                                                                                               | 5       | 1382       |
| I38 | `broadcasting.typ`            | "Frontend Abstraction" parameter documentation (lines 85-89)                              | **ABRIDGE** — replace API docs with brief prose                                                                                                                                         | 5       | 1387       |
| I39 | `broadcasting.typ`            | "Frontend Abstraction" trivial usage examples (lines ~130-140)                            | **REMOVE** — one-liner examples add nothing beyond the wrapper                                                                                                                          | 10      | 1397       |
| I40 | `broadcasting.typ`            | "Frontend Abstraction" intro paragraph (lines 76-84)                                      | **ABRIDGE**                                                                                                                                                                             | 5       | 1402       |
| I41 | `media-uploads.typ`           | "Filesystem Configuration" code block (lines 9-27)                                        | **REPLACE** standard config array with 2-line prose + source_code_link                                                                                                                  | 12      | 1414       |
| I42 | `media-uploads.typ`           | "Input Validation and Security" code block (lines 49-64)                                  | **ABRIDGE** — replace standard validation array with 2-line prose                                                                                                                       | 8       | 1422       |
| I43 | `media-uploads.typ`           | "Image Deletion Workflow" code block (lines ~104-122)                                     | **REPLACE** with source_code_link — keep the excellent rationale paragraph about why NOT to use transaction                                                                             | 15      | 1437       |
| I44 | `frontend-types.typ`          | "Global PageProps Interface" ShowPageProps code (lines ~135-151)                          | **ABRIDGE** — describe extension pattern in prose                                                                                                                                       | 18      | 1455       |
| I45 | `frontend-types.typ`          | "Strict Type Configuration" (lines 177-188)                                               | **ABRIDGE** to 1 sentence                                                                                                                                                               | 8       | 1463       |
| I46 | `frontend-state.typ`          | "Context Provider Pattern" code block (lines 7-64)                                        | **ABRIDGE** — show trimmed version (~15 lines: interface + useCart hook), not full 37-line code                                                                                         | 15      | 1478       |
| I47 | `frontend-state.typ`          | "Synchronization with Inertia Navigation" code block (lines 91-123)                       | **ABRIDGE** — mirrors initialization code. Brief prose noting it mirrors init instead.                                                                                                  | 15      | 1493       |
| I48 | `frontend-state.typ`          | "Type-Safe Context Consumption" code block (lines 125-150)                                | **ABRIDGE** — standard React pattern, describe in 2-line prose                                                                                                                          | 15      | 1508       |
| I49 | `frontend-search.typ`         | "Fuse.js Configuration" options code block (lines 29-48)                                  | **ABRIDGE** — replace Fuse.js options with 2-sentence description                                                                                                                       | 12      | 1520       |
| I50 | `frontend-search.typ`         | "Context-Specific Configurations" menu search code (lines ~117-129)                       | **ABRIDGE** — show only restaurant search (has nested key), describe menu in prose                                                                                                      | 15      | 1535       |
| I51 | `frontend-forms.typ`          | "Basic useForm Pattern" API description (lines 33-39) + input binding code (lines ~42-54) | **ABRIDGE** — condense API docs, remove standard controlled component code                                                                                                              | 18      | 1553       |
| I52 | `frontend-forms.typ`          | "TypeScript Generics" code block (lines 59-93)                                            | **ABRIDGE** — reference frontend-types.typ for generics pattern                                                                                                                         | 18      | 1571       |
| I53 | `frontend-forms.typ`          | "Processing State" code block (lines 124-141)                                             | **ABRIDGE** — trivial pattern, describe in 1-2 lines                                                                                                                                    | 12      | 1583       |
| I54 | `frontend-forms.typ`          | "Validation Error Display" (lines 95-122)                                                 | **MERGE** with frontend-accessibility.typ "Form Label Association" — show ONE complete accessible form field pattern in ONE location                                                    | 12      | 1595       |
| I55 | `frontend-accessibility.typ`  | "Semantic HTML Structure" code block (lines 7-31)                                         | **ABRIDGE** — textbook "use button not div" example. Replace with 2-line prose.                                                                                                         | 10      | 1605       |
| I56 | `frontend-accessibility.typ`  | "Form Label Association" (lines 54-96)                                                    | **MERGE** with I54 above — deduplicate with frontend-forms.typ                                                                                                                          | 15      | 1620       |
| I57 | `frontend-accessibility.typ`  | "Focus Management" SCSS code block (lines 98-122)                                         | **ABRIDGE** — standard focus-visible approach. 2-line prose.                                                                                                                            | 10      | 1630       |
| I58 | `frontend-structure.typ`      | "Directory Structure" prose descriptions (lines 3-41)                                     | **ABRIDGE** — condense to compact list without per-directory explanations                                                                                                               | 15      | 1645       |
| I59 | `frontend-structure.typ`      | "Convention in Practice" code block (lines 42-72)                                         | **ABRIDGE** — reduce 22-line import example to 5-line import list + 2-line explanation                                                                                                  | 15      | 1660       |
| I60 | `frontend-implementation.typ` | Introductory paragraph (lines 3-19)                                                       | **ABRIDGE** — 17-line preview of subsections to 3-4 lines                                                                                                                               | 10      | 1670       |
| I61 | `frontend-workflow.typ`       | "Vite Hot Module Replacement" code block (lines 14-35)                                    | **REPLACE** standard Vite config with 2-line prose + source_code_link                                                                                                                   | 12      | 1682       |
| I62 | `frontend-workflow.typ`       | "SCSS Compilation Pipeline" file names (lines 37-46)                                      | **ABRIDGE** — remove specific filenames, keep top-level structure                                                                                                                       | 5       | 1687       |
| I63 | `frontend-workflow.typ`       | "Bundle Optimization Strategies" (lines 63-72)                                            | **ABRIDGE** — replace 4 standard Vite optimization bullets with 1 sentence                                                                                                              | 7       | 1694       |
| I64 | `database.typ`                | "Migration Structure" explanation of standard Laravel API (line 42)                       | **ABRIDGE**                                                                                                                                                                             | 2       | 1696       |

### Tier 3 Actions (map-functionality restructuring)

| #   | File                    | Section / Lines                  | Action                                                                                                                                                                                  | Savings                             | Cumulative |
| --- | ----------------------- | -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- | ---------- |
| I65 | `map-functionality.typ` | Consider wholesale restructuring | Assume reader has read map-architecture.typ. Every section opens with "Implementing the pattern from @section" and jumps to code. Remove all re-explanations of architectural concepts. | (savings already counted in I9-I36) | 1696       |

**Chapter 5 total: 993 lines saved | Running grand total: 1,696**

---

## Cross-Chapter Operations

These changes touch files in multiple chapters and must be coordinated:

| #   | Source                                                                  | Target                                                                             | Operation                                                                                                          | Notes                                                   |
| --- | ----------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| X1  | `map-architecture.typ` "Query Optimization Strategy" (lines 188-201)    | `map-functionality.typ` Phase C section                                            | Move 2-line principle to Three-Phase Pipeline in architecture; move SQL detail to implementation Phase C.          | Net: content moves, ~14 lines of duplication eliminated |
| X2  | `map-architecture.typ` "Bounding Box Prefilter Pattern" (lines 203-212) | `database.typ` "Query Scopes" section                                              | Architecture keeps 2-line principle; implementation scopes section is canonical location for bounding box pattern. | Net: ~8 lines eliminated                                |
| X3  | `data-persistence.typ` "Reactive Persistence" (lines 43-44)             | `real-time-events.typ`                                                             | Add 1 sentence to real-time-events noting ORM lifecycle hooks as trigger. Remove from data-persistence.            | Net: ~2 lines saved                                     |
| X4  | `data-persistence.typ` various sections                                 | `database-design.typ` + `backend-architecture.typ` + implementation `database.typ` | Redistribute unique content from data-persistence to canonical locations. See A32-A37.                             | Net: ~29 lines saved                                    |
| X5  | `media-storage.typ` "Image Entity"                                      | `database-design.typ` "Images" section                                             | Absorb dynamic URL generation detail.                                                                              | Net: ~6 lines saved                                     |
| X6  | `employee-customer.typ`                                                 | `backend-architecture.typ` "Layered Architecture Overview"                         | Absorb 1-sentence divide statement.                                                                                | Net: ~6 lines saved                                     |
| X7  | `frontend-forms.typ` "Validation Error Display"                         | `frontend-accessibility.typ` "Form Label Association"                              | Merge into single "Accessible Form Field" example in ONE location.                                                 | Net: ~27 lines saved                                    |
| X8  | `frontend-types.typ` "Custom Hook Type Exports" useSearch code          | `frontend-search.typ` "Reusable useSearch Hook"                                    | Remove duplicate from types, keep in search section.                                                               | Net: ~18 lines saved                                    |
| X9  | `database.typ` geospatial scopes                                        | `map-functionality.typ` Phase B                                                    | Make scopes section canonical for bounding box pattern. Phase B references scopes instead of re-showing.           | Net: ~30 lines saved                                    |
| X10 | `deployment.typ` service descriptions                                   | System Architecture chapter                                                        | If architecture already covers container topology, cross-reference from deployment.                                | Conditional: ~15-20 lines                               |

---

## Assessment Risk Flags

| Risk                            | Affected Actions                                        | Mitigation                                                                                                                                                                                                       |
| ------------------------------- | ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Aims/Objectives coverage**    | R1, R2 (removing Order Sharing + Dynamic Pricing FRs)   | Move to Future Work section rather than deleting outright. Ensures all aims remain addressed.                                                                                                                    |
| **Methodology justification**   | T5 (removing PHP defense), T6 (removing ORM comparison) | Technology choices must STILL be justified. The replacement 1-line summaries must state the rationale. Don't leave technology choices unjustified.                                                               |
| **NFR traceability**            | R21 (2FA qualifier)                                     | If 2FA is listed as a requirement but not implemented, evaluator may penalize. Add explicit "future consideration" wording.                                                                                      |
| **Implementation completeness** | I1-I8 (replacing database code with source_code_links)  | Evaluator must still see that the work was done. Ensure each replaced code block has a clear source_code_link and a prose sentence describing what it does. Don't just delete — replace with meaningful summary. |
| **Map feature depth**           | I9-I36 (heavy map-functionality reduction)              | Map is the thesis's differentiating feature. Ensure the THREE-PHASE PIPELINE code remains visible (Phase A, B, C core code blocks). Only trim surrounding explanation and trivial helper code.                   |
| **Accessibility compliance**    | I55-I57 (trimming accessibility section)                | If thesis claims WCAG 2.1 compliance (NFR line 19), accessibility section must retain substance. Keep ARIA label + focus management prose; only remove textbook code examples.                                   |

---

## Final Summary

### Per-Chapter Savings

| Chapter                  | Current Lines | Tier 1 Savings | Tier 2 Savings | Tier 3 Savings | Total Savings | Resulting Lines | % Reduction |
| ------------------------ | ------------- | -------------- | -------------- | -------------- | ------------- | --------------- | ----------- |
| Requirements & Context   | 412           | 16             | 82             | 0              | 98            | 314             | 24%         |
| Technologies             | 390           | 47             | 102            | 28             | 177           | 213             | 45%         |
| Development Process      | 295           | 55             | 97             | 0              | 152           | 143             | 52%         |
| Architecture & DB Design | 734           | 81             | 178            | 15             | 274           | 460             | 37%         |
| Implementation           | 2,444         | 393            | 600            | 0              | 993           | 1,451           | 41%         |
| **TOTAL**                | **4,275**     | **592**        | **1,059**      | **43**         | **~1,694**    | **~2,581**      | **~40%**    |

### Progress Toward Target

| Scenario         | Lines Saved   | Pages Saved (~25 lines/page) | Resulting Pages (from ~155) |
| ---------------- | ------------- | ---------------------------- | --------------------------- |
| Tier 1 only      | ~592          | ~24 pages                    | ~131 pages                  |
| Tier 1 + Tier 2  | ~1,651        | ~66 pages                    | ~89 pages                   |
| All tiers        | ~1,694        | ~68 pages                    | ~87 pages                   |
| **Target range** | **625–1,125** | **25–45 pages**              | **110–130 pages**           |

**Recommendation:** Execute all Tier 1 actions and approximately 50-60% of Tier 2 actions to land in the 110-130 page target range. This gives ~900-1,100 lines of reduction (~36-44 pages), producing a thesis of approximately 111-119 pages.

### Execution Order Recommendation

1. **First pass — Tier 1 deletions** (no rewriting needed): D1-D3, A1, R1-R5, I9-I13, I17-I20, A2-A6, T1-T6, D4-D6
2. **Second pass — Code block replacements** (replace with source_code_link): I1-I8, I14-I16, I41-I43, I61
3. **Third pass — Prose abridgements** (rewriting required): All Tier 2 items, starting with highest-savings chapters (Implementation, then Architecture, then Technologies)
4. **Fourth pass — Cross-chapter merges** (coordination required): X1-X10
5. **Final pass — Tier 3 structural changes** (if needed): A38-A40, T33-T36
6. **Validation** — Recompile thesis, check page count, verify no orphaned references or broken @labels
