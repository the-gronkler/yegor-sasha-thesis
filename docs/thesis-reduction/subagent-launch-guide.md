# Subagent Launch Commands and Examples

This document provides practical examples of how to launch each subagent with precise instructions.

## Prerequisites

Before launching subagents:
1. Ensure repository is on correct branch
2. Compile thesis to establish baseline page count: `typst compile typst/main.typ`
3. Create execution tracking directories (already done)
4. Review master-reduction-plan.md to understand context

## Phase 1: Tier 1 Subagents

### Subagent 1.1: File Deletion Agent

**Launch Command Prompt**:
```
You are Subagent 1.1: File Deletion Agent. Your task is to delete empty placeholder files and update references.

TASK:
1. Locate and verify these files are empty/placeholder:
   - typst/chapters/development-process/automations.typ (expected: 27 lines)
   - typst/chapters/development-process/planning.typ (expected: 4 lines)
   - typst/chapters/development-process/documentation.typ (expected: 4 lines)
   - typst/chapters/system-architecture/employee-customer.typ (expected: 7 lines)

2. For each file:
   - Read the file and verify it is truly empty or placeholder content
   - Find all files that include/reference it (search for #include statements)
   - Record findings in output markdown

3. Delete the files using the appropriate tool

4. Update parent files to remove include statements:
   - Find and remove references from development-process-main.typ (expected: 3 lines)
   - Find and remove reference from system-architecture.typ (expected: 1 line)

5. Create detailed output file at: docs/thesis-reduction/execution/phase-1-tier1/01-file-deletions.md

OUTPUT FORMAT (follow exactly):
# Subagent 1.1: File Deletion Agent

## Task Summary
- Input: master-reduction-plan.md lines 26-28
- Goal: Delete empty placeholder files and update references
- Expected Lines Saved: 62

## Execution Log

### File 1: [filename]
**Location**: [path]
**Line Count**: [number]
**Content Analysis**: [summary of what's in the file]
**Includes Found In**: [list of files that include this]
**Action**: Deleted
**References Removed From**: [list of files where includes were removed]

[Repeat for each file]

## Summary
- ✓ Total files deleted: 4
- ✓ Total lines saved: [actual number]
- ✓ Include statements removed: [number]
- ✓ Files modified: [list]
- ✓ Git status: [output of git status]

## Issues/Notes
[Any unexpected findings]

IMPORTANT:
- Do NOT delete files until you have verified they are truly empty/placeholder
- Do NOT proceed if files contain substantial content - report back first
- Record every decision in the output file
- Commit changes with message: "refactor(thesis): delete empty placeholder files [Subagent 1.1]"
```

### Subagent 1.2: Exact Duplicate Removal Agent

**Launch Command Prompt**:
```
You are Subagent 1.2: Exact Duplicate Removal Agent. Your task is to identify and remove exact copy-paste duplicates.

TASK:
1. Open typst/chapters/database-design.typ

2. Locate lines 69-82 and lines 83-96

3. Verify they are EXACT duplicates (character-by-character identical)

4. Determine which section to keep (context: which section flows better)

5. Delete the duplicate section

6. Verify no broken references after deletion

7. Create detailed output file at: docs/thesis-reduction/execution/phase-1-tier1/02-duplicate-removal.md

OUTPUT FORMAT:
# Subagent 1.2: Exact Duplicate Removal Agent

## Task Summary
- Input: master-reduction-plan.md lines 30-31
- Goal: Remove exact copy-paste duplicates
- Expected Lines Saved: 14

## Execution Log

### Duplicate 1: database-design.typ
**Original Section**: Lines 69-82
**Content**: [paste exact text]
**Context**: [what heading/section is this under]

**Duplicate Section**: Lines 83-96
**Content**: [paste exact text]
**Context**: [what heading/section is this under]

**Verification**: [Are they identical? Yes/No]
**Decision**: Keep [original/duplicate], Remove [original/duplicate]
**Rationale**: [why this choice]

**Action Taken**: Deleted lines [X-Y]
**Lines Saved**: 14

## Summary
- ✓ Duplicates found: 1
- ✓ Total lines saved: 14
- ✓ Files modified: typst/chapters/database-design.typ
- ✓ Compilation test: [Success/Failure]
- ✓ Git status: [output]

IMPORTANT:
- Verify duplicates are EXACTLY identical before removing
- Choose which copy to keep based on context/flow
- Test compilation after change
- Commit: "refactor(thesis): remove exact duplicate in database-design [Subagent 1.2]"
```

### Subagent 1.3: Appendix Move Agent

**Launch Command Prompt**:
```
You are Subagent 1.3: Appendix Move Agent. Your task is to move reference material to appendices.

TASK:
1. Create new file: typst/appendices/typescript-types.typ

2. From typst/chapters/implementation/frontend-types.typ, extract:
   - MenuItem interface definition
   - Restaurant interface definition
   - OrderStatusEnum interface definition
   - PaginatedResponse interface definition
   - Total expected: ~89 lines

3. Structure new appendix file with:
   - Heading: = Appendix A: TypeScript Type Definitions
   - Brief introduction (2-3 lines explaining purpose)
   - The extracted interface definitions
   - Proper Typst formatting

4. In frontend-types.typ, replace extracted content with:
   - Brief 2-3 line statement referring to appendix
   - Reference label: @appendix-typescript-types

5. Update typst/main.typ to include the appendix

6. Test compilation

7. Create output file at: docs/thesis-reduction/execution/phase-1-tier1/03-appendix-moves.md

OUTPUT FORMAT:
# Subagent 1.3: Appendix Move Agent

## Task Summary
- Input: master-reduction-plan.md lines 38-39
- Goal: Move TypeScript interfaces to appendix
- Expected Lines Saved: ~87 (89 moved - 2 replacement)

## Execution Log

### Content Extraction
**Source File**: typst/chapters/implementation/frontend-types.typ
**Content Extracted**:
- MenuItem interface: lines [X-Y]
- Restaurant interface: lines [A-B]
- OrderStatusEnum interface: lines [C-D]
- PaginatedResponse interface: lines [E-F]
**Total Lines Extracted**: [number]

### Appendix Creation
**New File**: typst/appendices/typescript-types.typ
**Structure**:
- Heading added: Yes
- Introduction added: Yes
- Content formatted: Yes
**Label**: <appendix-typescript-types>

### Source File Update
**Replacement Text**: [paste the 2-3 line summary added]
**Reference Added**: Yes

### Integration
**main.typ Updated**: Yes
**Include Statement**: [show the line added]

## Summary
- ✓ Content moved to appendix: 89 lines
- ✓ Replacement text added: 2 lines
- ✓ Net lines saved: 87
- ✓ Files created: typst/appendices/typescript-types.typ
- ✓ Files modified: frontend-types.typ, main.typ
- ✓ Compilation test: [Success/Failure]
- ✓ Git status: [output]

IMPORTANT:
- Verify appendix integrates properly with main document
- Ensure reference label works (@appendix-typescript-types)
- Test that compilation succeeds
- Commit: "refactor(thesis): move TypeScript interfaces to appendix [Subagent 1.3]"
```

## Phase Transition: Review Agent Launch

**Between each phase, launch a review agent**:

```
You are Phase [X] Review Agent. Your task is to validate all changes from Phase [X].

TASK:
1. Review all subagent output files in phase-[X]-tier[Y]/

2. For each subagent:
   - Verify claimed line savings with: git diff --stat
   - Check for logical consistency in decisions
   - Identify any issues or concerns

3. Compile thesis: typst compile typst/main.typ

4. Compare page count to baseline

5. Test for broken references

6. Verify core contributions still present

7. Create comprehensive review at: docs/thesis-reduction/execution/phase-[X]-tier[Y]/phase-[X]-review.md

OUTPUT FORMAT:
# Phase [X] Review

## Review Summary
- Phase: Phase [X] - Tier [Y]
- Subagents Reviewed: [list]
- Expected Total Line Savings: [number]
- Actual Total Line Savings: [number]

## Individual Subagent Verification

### Subagent [ID]: [Name]
**Expected Savings**: [number] lines
**Actual Savings**: [number] lines (verified with git diff)
**Files Modified**: [list]
**Issues Found**: [None / list issues]
**Status**: ✓ Verified / ⚠ Warning / ✗ Failed

[Repeat for each subagent]

## Compilation Check
**Command**: typst compile typst/main.typ
**Result**: Success / Failure
**Errors**: [None / list errors]
**Page Count**: [number] pages
**Page Change**: [+/-X] pages from baseline
**Expected Page Change**: ~[Y] pages

## Content Preservation Verification
**Core Contributions Check**:
- AGENTS.md system: [Present/Missing]
- Map heatmap algorithm: [Present/Missing]
- Docs-as-Code philosophy: [Present/Missing]
- Three-phase pipeline: [Present/Missing]
- Broadcasting architecture: [Present/Missing]

**Assessment Criteria Check**:
- Aims and Objectives: [Intact/Modified/Missing]
- Functional Requirements: [Intact/Modified/Missing]
- Use Case Scenarios: [Intact/Modified/Missing]
- System Architecture: [Intact/Modified/Missing]
- Implementation: [Intact/Modified/Missing]

## Issues Summary
[List all issues found, categorized by severity: Critical/Warning/Note]

## Phase Gate Decision
**Proceed to Phase [X+1]**: Yes / No
**Rationale**: [Detailed explanation]

## Recommendations
[Any recommendations for next phase or corrections needed]

GATE CRITERIA:
- All subagents must be ✓ Verified (or ⚠ Warning with acceptable explanation)
- Compilation must succeed
- Page savings must be within 10% of expected
- Core contributions must all be Present
- No Critical issues
```

## Parallel Execution Pattern

For phases where subagents can run in parallel:

```
Launch 6 subagents simultaneously (within single conversation if orchestrator supports it):
1. Start Subagent 1.1
2. Start Subagent 1.2
3. Start Subagent 1.3
4. Start Subagent 1.4
5. Start Subagent 1.5
6. Start Subagent 1.6

Each completes independently and creates its output file.
When all complete, launch Phase Review Agent.
```

## Sequential Execution Pattern

For phases with dependencies:

```
Phase 3 requires sequential execution:
1. Launch Subagent 3.1 (Inertia consolidation)
2. Wait for completion
3. Launch Subagent 3.2 (Employee-Customer) - depends on 3.1 findings
4. Wait for completion
5. Launch Subagent 3.3 (Other redundancy)
6. Wait for completion
7. Launch Phase 3 Review Agent
```

## Error Handling Pattern

If a subagent encounters unexpected content:

```
STOP and create output file with:

# Subagent [ID]: [Name] - PAUSED

## Issue Encountered
**Expected**: [what instructions said]
**Found**: [what was actually found]
**Location**: [file and lines]
**Decision Required**: [what needs clarification]

## Recommendations
1. [Option 1 with rationale]
2. [Option 2 with rationale]
3. [Option 3 with rationale]

## Status
⏸ Paused pending orchestrator decision

DO NOT PROCEED - escalate to orchestrator
```

## Git Commit Patterns

Each subagent commits with this pattern:
```
[type](scope): [description] [Subagent ID]

[type] = refactor (most common), docs, chore
scope = thesis
description = what was changed
Subagent ID = [Subagent X.Y]

Examples:
- refactor(thesis): delete empty placeholder files [Subagent 1.1]
- refactor(thesis): remove exact duplicate in database-design [Subagent 1.2]
- refactor(thesis): move TypeScript interfaces to appendix [Subagent 1.3]
- refactor(thesis): remove architecture-implementation overlap [Subagent 1.4]
```

## Verification Commands

After each subagent completes, run:
```bash
# Check line changes
git diff --stat HEAD~1

# Check specific file
git diff HEAD~1 -- path/to/file.typ

# Compile thesis
typst compile typst/main.typ

# Get page count (if pdfinfo available)
pdfinfo typst/main.pdf | grep Pages

# Check for broken references (look for "error" or "warning" in output)
typst compile typst/main.typ 2>&1 | grep -i "error\|warning"
```

## Success Indicators

Each subagent output should include:
- ✓ All tasks completed
- ✓ Output file created
- ✓ Git commit made
- ✓ Line savings quantified
- ✓ Compilation successful (if applicable)

Each review should show:
- ✓ All subagents verified
- ✓ Page count tracking
- ✓ Content preservation confirmed
- ✓ Gate decision: Proceed to next phase

## Complete Execution Flow

```
1. Baseline: Compile thesis, record page count
2. Phase 1: Launch subagents 1.1-1.6 (parallel)
3. Phase 1 Review: Validate, check page count
4. If Phase 1 approved:
5. Phase 2: Launch subagents 2.1-2.5 (parallel)
6. Phase 2 Review: Validate, check page count
7. If Phase 2 approved:
8. Phase 3: Launch subagents 3.1-3.3 (sequential)
9. Phase 3 Review: Validate, check page count
10. Final Validation: Comprehensive check
11. Complete: Target achieved (110-130 pages)
```

## Monitoring Progress

Track progress with:
```bash
# Check execution directory
ls -la docs/thesis-reduction/execution/phase-*-tier*/*.md

# View latest output
tail -50 docs/thesis-reduction/execution/phase-1-tier1/01-file-deletions.md

# Check git log
git log --oneline | head -20

# Count commits by phase
git log --oneline --grep="Subagent 1\."
git log --oneline --grep="Subagent 2\."
git log --oneline --grep="Subagent 3\."
```

## Tips for Orchestrator

1. **Start Simple**: Begin with Phase 1 Subagent 1.1 to test the pattern
2. **Verify Each Step**: Don't move to next subagent until previous is verified
3. **Track Page Count**: Compile thesis after each phase to monitor progress
4. **Be Conservative**: If subagent finds unexpected content, pause and reassess
5. **Document Everything**: Every decision should be in an output file
6. **Use Git**: Each subagent should commit separately for easy rollback
7. **Test Compilation**: Compile after each subagent to catch broken references early
8. **Review Outputs**: Read subagent output files to verify quality of work
