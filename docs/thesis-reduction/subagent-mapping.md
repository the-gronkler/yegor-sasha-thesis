# Master Plan Item to Subagent Mapping

This document provides a quick lookup from master plan action items to responsible subagents.

## Tier 1: High-Impact, Low-Risk Changes (749 lines)

### Quick Wins - File Deletions (62 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 1 | Delete placeholder files | 1.1: File Deletion Agent | 01-file-deletions.md |
| 2 | Remove include statements | 1.1: File Deletion Agent | 01-file-deletions.md |

### Remove Exact Duplicates (14 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 3 | database-design.typ lines 83-96 duplicate | 1.2: Exact Duplicate Removal Agent | 02-duplicate-removal.md |

### Remove Redundant Prose (61 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 4 | use-case-diagram prose | 2.5: Use Case Redundancy Removal Agent | 09-use-case-reduction.md |
| 5 | use-case-scenarios introductions | 2.5: Use Case Redundancy Removal Agent | 09-use-case-reduction.md |
| 6 | use-case-scenarios alternative flows | 2.5: Use Case Redundancy Removal Agent | 09-use-case-reduction.md |

### Move to Appendix (89 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 7 | frontend-types.typ TypeScript interfaces | 1.3: Appendix Move Agent | 03-appendix-moves.md |

### Reduce Code Repetition (285 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 8 | database.typ migrations | 2.1: Code-to-Prose Conversion Agent | 05-code-to-prose.md |
| 9 | database.typ relationships | 2.1: Code-to-Prose Conversion Agent | 05-code-to-prose.md |
| 10 | database.typ seeders | 2.1: Code-to-Prose Conversion Agent | 05-code-to-prose.md |
| 11 | mfs command | 2.2: Code Repetition Reduction Agent | 06-code-repetition.md |
| 12 | broadcasting.typ hooks | 2.2: Code Repetition Reduction Agent | 06-code-repetition.md |
| 13 | CartContext | 2.2: Code Repetition Reduction Agent | 06-code-repetition.md |
| 14 | Fuse.js configs | 2.2: Code Repetition Reduction Agent | 06-code-repetition.md |

### Remove Architecture-Implementation Overlap (91 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 15 | map-architecture.typ duplications | 1.4: Architecture-Implementation Overlap Removal Agent | 04-architecture-overlap.md |

### Remove Academic/Generic Content (57 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 16 | ORM comparative analysis | 1.5: Academic Content Removal Agent | 05-academic-removal.md |
| 17 | Map technologies summary | 1.5: Academic Content Removal Agent | 05-academic-removal.md |
| 18 | Version control PR process | 1.5: Academic Content Removal Agent | 05-academic-removal.md |
| 19 | Deployment container orchestration | 1.5: Academic Content Removal Agent | 05-academic-removal.md |
| 20 | Backend community resources | 1.5: Academic Content Removal Agent | 05-academic-removal.md |

### Convert to Tables (29 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 21 | React framework comparison | 1.6: Table Conversion Agent | 06-table-conversions.md |
| 22 | Database alternatives | 1.6: Table Conversion Agent | 06-table-conversions.md |
| 23 | Blob storage alternatives | 1.6: Table Conversion Agent | 06-table-conversions.md |

## Tier 2: Medium-Impact Changes (552 lines)

### Convert Code to Prose + References (195 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 24 | Map Phase C SQL | 2.1: Code-to-Prose Conversion Agent | 05-code-to-prose.md |
| 25 | Map JSX prop wiring | 2.1: Code-to-Prose Conversion Agent | 05-code-to-prose.md |
| 26 | Map component handlers | 2.1: Code-to-Prose Conversion Agent | 05-code-to-prose.md |
| 27 | Bottom sheet drag | 2.1: Code-to-Prose Conversion Agent | 05-code-to-prose.md |
| 28 | Map requirements section | 2.1: Code-to-Prose Conversion Agent | 05-code-to-prose.md |
| 29 | Frontend-search patterns | 2.1: Code-to-Prose Conversion Agent | 05-code-to-prose.md |
| 30 | Frontend-state patterns | 2.1: Code-to-Prose Conversion Agent | 05-code-to-prose.md |

### Condense Verbose Explanations (137 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 31 | Version control commit conventions | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 32 | AI use agent instructions | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 33 | Deployment service descriptions | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 34 | Thesis documentation sections | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 35 | Context business narrative | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 36 | Functional requirements | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 37 | Frontend forms | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 38 | Media uploads | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 39 | Frontend accessibility | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 40 | Frontend workflow/optimistic | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |

### Abridge Technology Justifications (55 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 41 | ORM Active Record vs Data Mapper | 2.4: Technology Justification Abridgment Agent | 08-tech-justifications.md |
| 42 | React TypeScript/Vite | 2.4: Technology Justification Abridgment Agent | 08-tech-justifications.md |
| 43 | React Fuse.js | 2.4: Technology Justification Abridgment Agent | 08-tech-justifications.md |
| 44 | Map Technologies React Integration | 2.4: Technology Justification Abridgment Agent | 08-tech-justifications.md |
| 45 | Database limitations/multi-master | 2.4: Technology Justification Abridgment Agent | 08-tech-justifications.md |
| 46 | Backend PHP maturity | 2.4: Technology Justification Abridgment Agent | 08-tech-justifications.md |
| 47 | Inertia comparisons | 2.4: Technology Justification Abridgment Agent | 08-tech-justifications.md |
| 48 | Blob storage introduction | 2.4: Technology Justification Abridgment Agent | 08-tech-justifications.md |
| 49 | ORM relationship explanation | 2.4: Technology Justification Abridgment Agent | 08-tech-justifications.md |
| 50 | Redundant Laravel integration | 2.4: Technology Justification Abridgment Agent | 08-tech-justifications.md |

### Compress Architecture Sections (123 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 51 | Backend-architecture implementation details | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 52 | Map-architecture remaining | 1.4: Architecture-Implementation Overlap Removal Agent | 04-architecture-overlap.md |
| 53 | Data-persistence overlaps | 1.4: Architecture-Implementation Overlap Removal Agent | 04-architecture-overlap.md |
| 54 | Minor architecture files | 1.4: Architecture-Implementation Overlap Removal Agent | 04-architecture-overlap.md |

### Abridge Frontend Files (42 lines)
| Item # | Description | Subagent | Output File |
|--------|-------------|----------|-------------|
| 55 | frontend-structure | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |
| 56 | Various frontend files | 2.3: Verbose Explanation Compression Agent | 07-compressions.md |

## Cross-Cutting Issues

| Issue | Description | Subagent | Output File |
|-------|-------------|----------|-------------|
| Inertia Integration | 3 locations → consolidate to 1 | 3.1: Inertia Integration Consolidation Agent | 08-inertia-consolidation.md |
| Employee/Customer Separation | 3 locations → keep 2, delete stub | 3.2: Employee-Customer Separation Consolidation Agent | 09-employee-customer.md |
| Rating Recalculation | 2 locations → keep 1 | 3.3: Other Redundancy Elimination Agent | 10-remaining-redundancy.md |
| Laravel Integration Claims | 3+ locations → state once | 3.3: Other Redundancy Elimination Agent | 10-remaining-redundancy.md |

## Review and Validation Agents

| Phase | Agent | Output File |
|-------|-------|-------------|
| Phase 1 | Phase 1 Review Agent | phase-1-review.md |
| Phase 2 | Phase 2 Review Agent | phase-2-review.md |
| Phase 3 | Phase 3 Review Agent | phase-3-review.md |
| Final | Final Validation Agent | final-validation.md |

## Quick Reference by File

### Most Impacted Files

**map-functionality.typ** (~393 lines reduction):
- Items: 24, 25, 26, 27, 28
- Subagents: 2.1

**database.typ** (~267 lines reduction):
- Items: 8, 9, 10
- Subagents: 2.1

**frontend-types.typ** (~129 lines reduction):
- Items: 7
- Subagents: 1.3

**map-architecture.typ** (~152 lines reduction):
- Items: 15, 52
- Subagents: 1.4

**use-case-scenarios.typ** (~41 lines reduction):
- Items: 5, 6
- Subagents: 2.5

**use-case-diagram.typ** (~20 lines reduction):
- Items: 4
- Subagents: 2.5

## Execution Order

### Phase 1 (Parallel Execution Possible)
1. Subagent 1.1: File Deletion Agent
2. Subagent 1.2: Exact Duplicate Removal Agent
3. Subagent 1.3: Appendix Move Agent
4. Subagent 1.4: Architecture-Implementation Overlap Removal Agent
5. Subagent 1.5: Academic Content Removal Agent
6. Subagent 1.6: Table Conversion Agent
7. **GATE**: Phase 1 Review Agent

### Phase 2 (Parallel Execution Possible)
1. Subagent 2.1: Code-to-Prose Conversion Agent
2. Subagent 2.2: Code Repetition Reduction Agent
3. Subagent 2.3: Verbose Explanation Compression Agent
4. Subagent 2.4: Technology Justification Abridgment Agent
5. Subagent 2.5: Use Case Redundancy Removal Agent
6. **GATE**: Phase 2 Review Agent

### Phase 3 (Sequential Execution Required)
1. Subagent 3.1: Inertia Integration Consolidation Agent (must complete first)
2. Subagent 3.2: Employee-Customer Separation Consolidation Agent
3. Subagent 3.3: Other Redundancy Elimination Agent
4. **GATE**: Phase 3 Review Agent

### Phase 4 (Final)
1. Final Validation Agent

## Total Subagents: 18
- Phase 1: 6 implementation + 1 review = 7
- Phase 2: 5 implementation + 1 review = 6
- Phase 3: 3 implementation + 1 review = 4
- Phase 4: 1 validation = 1

## Lookup by Subagent

| ID | Subagent Name | Master Plan Items | Lines Saved |
|----|---------------|-------------------|-------------|
| 1.1 | File Deletion Agent | 1, 2 | 62 |
| 1.2 | Exact Duplicate Removal Agent | 3 | 14 |
| 1.3 | Appendix Move Agent | 7 | 87 |
| 1.4 | Architecture-Implementation Overlap Removal Agent | 15, 52, 53, 54 | ~200 |
| 1.5 | Academic Content Removal Agent | 16, 17, 18, 19, 20 | 60 |
| 1.6 | Table Conversion Agent | 21, 22, 23 | 29 |
| **Phase 1 Total** | | | **~452** |
| 2.1 | Code-to-Prose Conversion Agent | 8, 9, 10, 24, 25, 26, 27, 28, 29, 30 | ~330 |
| 2.2 | Code Repetition Reduction Agent | 11, 12, 13, 14 | 142 |
| 2.3 | Verbose Explanation Compression Agent | 31-40, 51, 55, 56 | ~200 |
| 2.4 | Technology Justification Abridgment Agent | 41-50 | 55 |
| 2.5 | Use Case Redundancy Removal Agent | 4, 5, 6 | 54 |
| **Phase 2 Total** | | | **~781** |
| 3.1 | Inertia Integration Consolidation Agent | Inertia cross-cutting | ~20 |
| 3.2 | Employee-Customer Separation Agent | Employee/Customer cross-cutting | 0 (already handled) |
| 3.3 | Other Redundancy Elimination Agent | Rating, Laravel cross-cutting | ~30 |
| **Phase 3 Total** | | | **~50** |
| **Grand Total** | | | **~1,283** |

*Note: Estimated line counts; actual savings verified by review agents.*
