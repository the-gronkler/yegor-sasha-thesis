# Thesis Reduction Implementation Orchestration Plan

## Executive Summary

This document defines a multi-agent orchestration strategy to implement the recommendations from the [master-reduction-plan.md](./master-reduction-plan.md). The plan follows the Conservative Approach (Tier 1 + Tier 2) targeting 1,301 lines of reduction to achieve ~113 pages.

## Orchestration Architecture

### Design Principles

1. **Single Responsibility**: Each subagent has ONE clear, focused task
2. **Sequential Dependencies**: Agents execute in phases with clear handoff points
3. **Traceable Outputs**: All intermediate results recorded in markdown files
4. **Validation Gates**: Review agents verify work before proceeding to next phase
5. **Reversibility**: Changes tracked in git with clear commit messages per phase

### Output Tracking System

All intermediate outputs stored in: `docs/thesis-reduction/execution/`

Structure:
```
docs/thesis-reduction/execution/
├── phase-1-tier1/
│   ├── 01-file-deletions.md
│   ├── 02-duplicate-removal.md
│   ├── 03-appendix-moves.md
│   ├── 04-architecture-overlap.md
│   └── phase-1-review.md
├── phase-2-tier2/
│   ├── 05-code-to-prose.md
│   ├── 06-table-conversions.md
│   ├── 07-compressions.md
│   └── phase-2-review.md
├── phase-3-cross-cutting/
│   ├── 08-inertia-consolidation.md
│   ├── 09-redundancy-elimination.md
│   └── phase-3-review.md
└── final-validation.md
```

## Phase 1: Tier 1 Quick Wins (749 lines, ~24 pages)

**Goal**: High-impact, low-risk changes with clear, objective criteria.

### Subagent 1.1: File Deletion Agent
**Task**: Delete empty placeholder files and update references

**Input**: master-reduction-plan.md lines 26-28
**Output**: `docs/thesis-reduction/execution/phase-1-tier1/01-file-deletions.md`

**Instructions**:
1. Locate and verify these files are empty/placeholder:
   - `typst/chapters/development-process/automations.typ` (27 lines)
   - `typst/chapters/development-process/planning.typ` (4 lines)
   - `typst/chapters/development-process/documentation.typ` (4 lines)
   - `typst/chapters/system-architecture/employee-customer.typ` (7 lines)

2. For each file, record in output MD:
   - File path
   - Current line count
   - Content summary (verify it's truly empty/placeholder)
   - Files that include/reference it

3. Delete the files

4. Update parent files to remove include statements:
   - Remove 3 lines from `development-process-main.typ`
   - Remove 1 line from `system-architecture.typ`

5. In output MD, document:
   - ✓ Files deleted (list paths)
   - ✓ References removed (list locations)
   - ✓ Lines saved: 62 total
   - ✓ Git status after changes

### Subagent 1.2: Exact Duplicate Removal Agent
**Task**: Remove exact copy-paste duplicates

**Input**: master-reduction-plan.md lines 30-31
**Output**: `docs/thesis-reduction/execution/phase-1-tier1/02-duplicate-removal.md`

**Instructions**:
1. Open `typst/chapters/database-design.typ`

2. Locate and verify exact duplicate:
   - Lines 83-96 should be identical to lines 69-82

3. In output MD, record:
   - Exact text of lines 69-82
   - Exact text of lines 83-96
   - Confirmation they are identical
   - Context (what section/heading they're under)

4. Delete lines 83-96

5. In output MD, document:
   - ✓ Duplicate removed (lines 83-96 from database-design.typ)
   - ✓ Original preserved (lines 69-82)
   - ✓ Lines saved: 14
   - ✓ Git status after changes

### Subagent 1.3: Appendix Move Agent
**Task**: Move reference material to appendix

**Input**: master-reduction-plan.md lines 38-39
**Output**: `docs/thesis-reduction/execution/phase-1-tier1/03-appendix-moves.md`

**Instructions**:
1. Create new file: `typst/appendices/typescript-types.typ`

2. From `typst/chapters/implementation/frontend-types.typ`, extract TypeScript interfaces:
   - MenuItem interface
   - Restaurant interface
   - OrderStatusEnum interface
   - PaginatedResponse interface
   - Total: 89 lines

3. In new appendix file, add:
   - Heading: `= Appendix A: TypeScript Type Definitions`
   - Brief introduction (2-3 lines)
   - The extracted interfaces

4. In `frontend-types.typ`, replace extracted content with:
   - Brief statement (2-3 lines): "The application uses strongly-typed TypeScript interfaces for data models. Complete type definitions are provided in Appendix A."
   - Reference: `@appendix-typescript-types`

5. Update `typst/main.typ` to include new appendix file

6. In output MD, document:
   - ✓ Content extracted (list interfaces)
   - ✓ Appendix created: appendices/typescript-types.typ
   - ✓ Reference added to frontend-types.typ
   - ✓ Main.typ updated
   - ✓ Lines moved: 89 (net reduction: ~87 accounting for replacement text)
   - ✓ Git status after changes

### Subagent 1.4: Architecture-Implementation Overlap Removal Agent
**Task**: Remove implementation details duplicated in architecture chapter

**Input**: master-reduction-plan.md lines 50-57
**Output**: `docs/thesis-reduction/execution/phase-1-tier1/04-architecture-overlap.md`

**Instructions**:
1. Open `typst/chapters/system-architecture/map-architecture.typ`

2. Locate and analyze these sections that duplicate implementation:
   - Session persistence explanation (~20 lines)
   - Component hierarchy tree (~24 lines)
   - Step-by-step data flow (~17 lines)
   - Geolocation flow details (~10 lines)
   - Query optimization SQL example (~10 lines)
   - Inertia bridge pattern code (~10 lines)

3. For each section, in output MD record:
   - Exact location (line numbers)
   - Content summary
   - Where it's duplicated in implementation chapter
   - Verification it can be safely removed (implementation chapter has same/better coverage)

4. Remove the duplicated sections from map-architecture.typ

5. Add brief transitional sentences where needed to maintain flow

6. In output MD, document:
   - ✓ Overlaps identified (list 6 items with line numbers)
   - ✓ Implementation coverage verified
   - ✓ Content removed from architecture
   - ✓ Transitions added (if any)
   - ✓ Lines saved: 91
   - ✓ Git status after changes

### Subagent 1.5: Academic Content Removal Agent
**Task**: Remove generic academic comparisons without project rationale

**Input**: master-reduction-plan.md lines 59-64
**Output**: `docs/thesis-reduction/execution/phase-1-tier1/05-academic-removal.md`

**Instructions**:
1. Identify and remove these generic/academic sections:
   - ORM comparative analysis (18 lines) - generic Active Record vs Data Mapper theory
   - Map technologies summary (12 lines) - redundant recap
   - Version control PR process (12 lines) - standard GitHub practices
   - Deployment container orchestration (14 lines) - generic DevOps theory
   - Backend community resources (4 lines) - Laracasts mention

2. For each section, in output MD record:
   - File path and line numbers
   - Content summary
   - Reason for removal (generic/academic/redundant)
   - Verification it doesn't contain project-specific insights

3. Remove the content

4. In output MD, document:
   - ✓ Academic sections removed (list 5 items)
   - ✓ Project-specific content preserved
   - ✓ Lines saved: 60
   - ✓ Git status after changes

### Subagent 1.6: Table Conversion Agent
**Task**: Convert verbose prose to structured tables

**Input**: master-reduction-plan.md lines 66-69
**Output**: `docs/thesis-reduction/execution/phase-1-tier1/06-table-conversions.md`

**Instructions**:
1. Convert these prose sections to tables:
   - React framework comparison (20 lines) → comparison table
   - Database alternatives (5 lines) → comparison table
   - Blob storage alternatives (4 lines) → comparison table

2. For each conversion, in output MD record:
   - Original prose location and content
   - Table design (columns, rows)
   - New table in Typst format
   - Verification all information preserved

3. Replace prose with tables in source files

4. In output MD, document:
   - ✓ Tables created (list 3 items)
   - ✓ Information preserved
   - ✓ Lines saved: 29
   - ✓ Git status after changes

### Phase 1 Review Agent
**Task**: Validate all Tier 1 changes

**Input**: All phase-1-tier1/*.md files
**Output**: `docs/thesis-reduction/execution/phase-1-tier1/phase-1-review.md`

**Instructions**:
1. For each subagent output:
   - Verify claimed line savings match actual git diff
   - Check no broken references (compile thesis and check for errors)
   - Confirm content preservation (spot-check that core contributions intact)

2. Compile thesis: `typst compile typst/main.typ`
   - Record page count before Phase 1 (baseline)
   - Record page count after Phase 1
   - Calculate actual pages saved

3. In output MD, document:
   - ✓ Line savings verified: Expected 749, Actual: [number]
   - ✓ Page savings: Expected ~24, Actual: [number]
   - ✓ Compilation successful: Yes/No (with errors if any)
   - ✓ Broken references: None / [list if any]
   - ✓ Core contributions intact: [verification]
   - ✓ Ready for Phase 2: Yes/No

**Gate**: Phase 2 only proceeds if Phase 1 Review confirms success.

## Phase 2: Tier 2 Medium-Impact Changes (552 lines, ~18 pages)

**Goal**: Compressions and conversions requiring editorial judgment but maintaining clarity.

### Subagent 2.1: Code-to-Prose Conversion Agent
**Task**: Replace repetitive code examples with prose + source_code_link

**Input**: master-reduction-plan.md lines 75-82
**Output**: `docs/thesis-reduction/execution/phase-2-tier2/05-code-to-prose.md`

**Instructions**:
1. For each code section identified for conversion:

   **database.typ - Migrations (80 lines):**
   - Keep ONE representative migration (users table)
   - Replace other 7+ migrations with prose paragraph
   - Add source_code_link to each migration file
   - Example prose: "Additional tables follow identical migration patterns, including orders #source_code_link("database/migrations/2024_01_15_create_orders_table.php"), reviews #source_code_link("..."), and menu_items #source_code_link("...")."

   **database.typ - Eloquent Relationships (50 lines):**
   - Replace relationship code examples with prose description
   - Add source_code_link to model files
   - Example: "The User model defines relationships to orders and reviews #source_code_link("app/Models/User.php")."

   **database.typ - Seeders (35 lines):**
   - Keep ONE representative seeder
   - Replace others with prose + links

   **map-functionality.typ - Phase C SQL (45 lines):**
   - Replace SQL query with prose description of algorithm
   - Add source_code_link to actual query file

   **map-functionality.typ - JSX prop wiring (25 lines):**
   - Condense multiple examples to one

   **map-functionality.typ - Component handlers (50 lines):**
   - Merge similar handler patterns

   **map-functionality.typ - Bottom sheet drag (35 lines):**
   - Simplify implementation details

2. For each conversion, in output MD record:
   - File and line numbers
   - Original code (or summary if long)
   - Replacement prose
   - source_code_link references added
   - Lines saved

3. In output MD, document:
   - ✓ Code sections converted (list all)
   - ✓ source_code_link references added
   - ✓ Technical accuracy maintained
   - ✓ Lines saved: 195
   - ✓ Git status after changes

### Subagent 2.2: Code Repetition Reduction Agent
**Task**: Reduce repetitive code examples in implementation chapters

**Input**: master-reduction-plan.md lines 41-48
**Output**: `docs/thesis-reduction/execution/phase-2-tier2/06-code-repetition.md`

**Instructions**:
1. Reduce these repetitive sections:

   **broadcasting.typ - Hooks (45 lines):**
   - Currently shows 3 separate hook examples (useOrderUpdates, useReviewUpdates, useRestaurantUpdates)
   - Merge into ONE comprehensive example
   - Add note: "Similar patterns used for reviews and restaurant updates"

   **frontend-state.typ - CartContext (40 lines):**
   - Replace full implementation with reference
   - Brief summary (5 lines) + source_code_link

   **frontend-search.typ - Fuse.js configs (25 lines):**
   - Show ONE config example
   - Mention variations in prose

   **mfs command (32 lines):**
   - Move to Appendix B
   - Brief reference in main text

2. For each reduction, in output MD record:
   - File and line numbers
   - Consolidation strategy
   - Content preserved in merged example
   - Lines saved

3. In output MD, document:
   - ✓ Repetitions consolidated (list all)
   - ✓ Patterns preserved
   - ✓ Lines saved: 142
   - ✓ Git status after changes

### Subagent 2.3: Verbose Explanation Compression Agent
**Task**: Condense verbose explanations while preserving meaning

**Input**: master-reduction-plan.md lines 84-94
**Output**: `docs/thesis-reduction/execution/phase-2-tier2/07-compressions.md`

**Instructions**:
1. Identify verbose sections needing compression:
   - Version control commit conventions (22 lines)
   - AI use agent instructions (10 lines)
   - Deployment service descriptions (10 lines)
   - Thesis documentation sections (9 lines)
   - Context business narrative (6 lines)
   - Functional requirements impl details (5 lines)
   - Frontend forms examples (20 lines)
   - Media uploads details (30 lines)
   - Frontend accessibility (25 lines)
   - Frontend workflow/optimistic (17 lines)

2. For each section, in output MD record:
   - Original line count and location
   - Original text summary
   - Compressed version (actual rewritten text)
   - Verification all key information preserved
   - Lines saved

3. Apply compressions to files

4. In output MD, document:
   - ✓ Sections compressed (list all 10)
   - ✓ Key information preserved
   - ✓ Lines saved: 154
   - ✓ Git status after changes

### Subagent 2.4: Technology Justification Abridgment Agent
**Task**: Tighten technology justification sections

**Input**: master-reduction-plan.md lines 96-106
**Output**: `docs/thesis-reduction/execution/phase-2-tier2/08-tech-justifications.md`

**Instructions**:
1. Abridge these technology discussion sections:
   - ORM Active Record vs Data Mapper (7 lines)
   - React TypeScript/Vite benefits (7 lines)
   - React Fuse.js rationale (8 lines)
   - Map Technologies React Integration (2 lines)
   - Database limitations/multi-master (8 lines)
   - Backend PHP maturity defensive tone (8 lines)
   - Inertia comparisons REST drawbacks (7 lines)
   - Blob storage introduction (2 lines)
   - ORM relationship explanation (3 lines)
   - Redundant Laravel integration (3 lines)

2. For each section, in output MD record:
   - Location and current text
   - Abridged version
   - Verification project-specific rationale preserved
   - Generic claims removed
   - Lines saved

3. Apply abridgments

4. In output MD, document:
   - ✓ Justifications abridged (list all 10)
   - ✓ Project rationale preserved
   - ✓ Generic claims removed
   - ✓ Lines saved: 55
   - ✓ Git status after changes

### Subagent 2.5: Use Case Redundancy Removal Agent
**Task**: Remove redundant prose in use case sections

**Input**: master-reduction-plan.md lines 33-36
**Output**: `docs/thesis-reduction/execution/phase-2-tier2/09-use-case-reduction.md`

**Instructions**:
1. Remove redundant use case prose:
   - use-case-diagram.typ: Customer-centric prose (10 lines) - diagram is self-explanatory
   - use-case-diagram.typ: Restaurant management prose (10 lines) - diagram is self-explanatory
   - use-case-scenarios.typ: UC1 introduction (8 lines) - verbose intro
   - use-case-scenarios.typ: UC2 introduction (10 lines) - verbose intro
   - use-case-scenarios.typ: UC3 introduction (3 lines) - verbose intro
   - use-case-scenarios.typ: Nested slider alternatives (5 lines) - excessive detail
   - use-case-scenarios.typ: Item detail viewing (8 lines) - excessive detail

2. For each removal, in output MD record:
   - Location and content
   - Reason for removal (diagram self-explanatory / excessive detail)
   - Essential information (if any) to preserve
   - Lines saved

3. Apply removals, preserving essential information in concise form

4. In output MD, document:
   - ✓ Redundant prose removed (list all 7 items)
   - ✓ Essential use case info preserved
   - ✓ Lines saved: 54
   - ✓ Git status after changes

### Phase 2 Review Agent
**Task**: Validate all Tier 2 changes

**Input**: All phase-2-tier2/*.md files
**Output**: `docs/thesis-reduction/execution/phase-2-tier2/phase-2-review.md`

**Instructions**:
1. For each subagent output:
   - Verify claimed line savings match actual git diff
   - Verify prose replacements maintain technical accuracy
   - Check source_code_link references work
   - Verify compressions don't lose essential information

2. Compile thesis: `typst compile typst/main.typ`
   - Record page count after Phase 2
   - Calculate pages saved in Phase 2
   - Calculate cumulative pages saved (Phase 1 + 2)

3. In output MD, document:
   - ✓ Line savings verified: Expected 552, Actual: [number]
   - ✓ Cumulative line savings: Expected 1,301, Actual: [number]
   - ✓ Page savings Phase 2: Expected ~18, Actual: [number]
   - ✓ Cumulative page savings: Expected ~42, Actual: [number]
   - ✓ Current page count: [number] (Target: 110-130)
   - ✓ Compilation successful: Yes/No
   - ✓ Broken references: None / [list]
   - ✓ Technical accuracy: Maintained
   - ✓ Ready for Phase 3: Yes/No

**Gate**: Phase 3 only proceeds if Phase 2 Review confirms success.

## Phase 3: Cross-Cutting Consolidation

**Goal**: Handle content duplicated across multiple files.

### Subagent 3.1: Inertia Integration Consolidation Agent
**Task**: Consolidate Inertia discussion to one location

**Input**: master-reduction-plan.md line 143
**Output**: `docs/thesis-reduction/execution/phase-3-cross-cutting/08-inertia-consolidation.md`

**Instructions**:
1. Locate all mentions of Inertia integration:
   - frontend-architecture.typ (keep this one - most appropriate)
   - backend-architecture.typ (remove)
   - map-architecture.typ (remove)

2. For each location, in output MD record:
   - File path and line numbers
   - Content of Inertia discussion
   - Decision (keep/remove/consolidate)

3. Ensure frontend-architecture.typ has comprehensive Inertia coverage

4. Remove redundant mentions from backend and map architecture

5. In output MD, document:
   - ✓ Locations identified (3 total)
   - ✓ Primary location chosen: frontend-architecture.typ
   - ✓ Redundant mentions removed (2 locations)
   - ✓ Coverage complete in primary location
   - ✓ Lines saved: [number]
   - ✓ Git status after changes

### Subagent 3.2: Employee-Customer Separation Consolidation Agent
**Task**: Consolidate employee/customer discussion

**Input**: master-reduction-plan.md line 144
**Output**: `docs/thesis-reduction/execution/phase-3-cross-cutting/09-employee-customer.md`

**Instructions**:
1. Locate all mentions of employee/customer separation:
   - employee-customer.typ stub file (ALREADY DELETED in Phase 1)
   - backend-architecture.typ (keep)
   - database-design.typ (keep)

2. Verify stub was deleted in Phase 1

3. Ensure backend-architecture and database-design have non-redundant coverage

4. In output MD, document:
   - ✓ Stub file already removed in Phase 1
   - ✓ Backend architecture coverage: [summary]
   - ✓ Database design coverage: [summary]
   - ✓ No additional changes needed
   - ✓ Git status after changes

### Subagent 3.3: Other Redundancy Elimination Agent
**Task**: Handle remaining cross-file redundancies

**Input**: master-reduction-plan.md lines 145-147
**Output**: `docs/thesis-reduction/execution/phase-3-cross-cutting/10-remaining-redundancy.md`

**Instructions**:
1. Rating Recalculation (2 locations):
   - Keep in functional-requirements only
   - Remove from other locations

2. Laravel Integration Claims (3+ locations):
   - State once comprehensively in backend-technologies
   - Remove redundant mentions elsewhere

3. For each redundancy, in output MD record:
   - All locations found
   - Primary location chosen
   - Redundant locations removed
   - Lines saved

4. In output MD, document:
   - ✓ Rating recalculation consolidated
   - ✓ Laravel integration claims consolidated
   - ✓ Lines saved: [number]
   - ✓ Git status after changes

### Phase 3 Review Agent
**Task**: Final cross-cutting validation

**Input**: All phase-3-cross-cutting/*.md files
**Output**: `docs/thesis-reduction/execution/phase-3-cross-cutting/phase-3-review.md`

**Instructions**:
1. Verify no content duplication across files

2. Check all cross-references work correctly

3. Compile thesis: `typst compile typst/main.typ`

4. In output MD, document:
   - ✓ Cross-cutting issues resolved
   - ✓ No content duplication remaining
   - ✓ All references working
   - ✓ Final page count: [number]
   - ✓ Target achieved (110-130 pages): Yes/No
   - ✓ Ready for final validation: Yes/No

## Phase 4: Final Validation

### Final Validation Agent
**Task**: Comprehensive validation of all changes

**Input**: All execution/*.md files, compiled thesis
**Output**: `docs/thesis-reduction/execution/final-validation.md`

**Instructions**:
1. Compile thesis and generate final PDF

2. Verify page count:
   - Current pages: [number]
   - Target range: 110-130 pages
   - Target met: Yes/No

3. Verify all core contributions preserved:
   - AGENTS.md custom instructions system: Present
   - Map heatmap algorithm: Present
   - Docs-as-Code philosophy: Present
   - Three-phase map pipeline: Present
   - Real-time broadcasting architecture: Present

4. Verify assessment criteria intact:
   - Aims and Objectives: Present
   - Functional Requirements: Present (with minor reductions)
   - Non-Functional Requirements: Present
   - Use Case Scenarios: Present (verbose intros removed)
   - System Architecture: Present (impl overlap removed)
   - Implementation Details: Present (repetition reduced)

5. Check thesis compiles without errors:
   - No broken references
   - All figures render
   - All code examples display correctly
   - All citations work

6. Calculate total changes:
   - Total lines removed: [number]
   - Total pages saved: [number]
   - Percentage reduction: [number]%

7. Review all subagent outputs for consistency

8. In output MD, document:
   - ✓ Final page count: [number]
   - ✓ Target achieved: Yes/No
   - ✓ Core contributions preserved: [checklist]
   - ✓ Assessment criteria intact: [checklist]
   - ✓ Compilation successful: Yes/No
   - ✓ Total lines removed: [number]
   - ✓ Total pages saved: [number]
   - ✓ All subagent outputs consistent: Yes/No
   - ✓ Ready for advisor review: Yes/No

## Execution Dependencies

### Sequential Dependencies
```
Phase 1 Subagents (1.1-1.6) → Phase 1 Review →
Phase 2 Subagents (2.1-2.5) → Phase 2 Review →
Phase 3 Subagents (3.1-3.3) → Phase 3 Review →
Final Validation
```

### Within-Phase Parallelization

**Phase 1**: Subagents 1.1-1.6 can run in parallel (no dependencies)
**Phase 2**: Subagents 2.1-2.5 can run in parallel (no dependencies)
**Phase 3**: Subagent 3.1 must complete before 3.2-3.3 (3.1 affects what 3.2 checks)

## Risk Mitigation

1. **Git Commits**: Each subagent commits changes separately
   - Easy to revert individual changes
   - Clear attribution of line savings

2. **Review Gates**: No phase proceeds without review approval
   - Catches errors early
   - Validates assumptions before compounding changes

3. **Traceable Outputs**: Every decision documented in MD files
   - Audit trail for all changes
   - Easy to understand rationale later

4. **Compilation Checks**: Thesis compiled after each phase
   - Broken references caught immediately
   - Page count tracked continuously

5. **Content Preservation Checks**: Core contributions verified at each review
   - Ensures no accidental deletion of key content
   - Maintains thesis quality

## Success Criteria

- [ ] All 63 action items from master plan addressed
- [ ] Final page count: 110-130 pages
- [ ] Thesis compiles without errors
- [ ] All core contributions preserved
- [ ] All assessment criteria intact
- [ ] All subagent outputs documented in MD files
- [ ] All changes committed to git with clear messages
- [ ] Ready for advisor review

## Estimated Timeline

- **Phase 1**: 2-3 hours (6 subagents + review)
- **Phase 2**: 4-5 hours (5 subagents + review)
- **Phase 3**: 1-2 hours (3 subagents + review)
- **Final Validation**: 1 hour
- **Total**: 8-11 hours of agent execution time

## Notes for Orchestrator

1. **Monitor Progress**: Check subagent outputs in real-time
2. **Handle Failures**: If subagent fails, document issue and retry with clarified instructions
3. **Validate Assumptions**: If subagent finds unexpected content, pause and reassess
4. **Communicate**: Report progress after each phase completion
5. **Be Conservative**: When in doubt, preserve content rather than delete
