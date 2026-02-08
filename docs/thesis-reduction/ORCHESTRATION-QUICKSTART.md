# Thesis Reduction Orchestration - Quick Start

## What This Is

A comprehensive multi-agent orchestration plan to reduce the thesis from ~155 pages to 110-130 pages by implementing the [master-reduction-plan.md](./master-reduction-plan.md).

## Key Documents

1. **[orchestration-plan.md](./orchestration-plan.md)** - Complete orchestration strategy with detailed subagent instructions
2. **[subagent-mapping.md](./subagent-mapping.md)** - Quick reference mapping master plan items to subagents
3. **[subagent-launch-guide.md](./subagent-launch-guide.md)** - Practical examples and launch commands
4. **[execution/README.md](./execution/README.md)** - Output tracking system documentation

## Quick Start

### Step 1: Establish Baseline
```bash
cd typst
typst compile main.typ
# Record current page count as baseline
```

### Step 2: Launch Phase 1
Execute Tier 1 quick wins (749 lines, ~24 pages saved):
- 6 implementation subagents (can run in parallel)
- 1 review agent (validates all Phase 1 work)

See [subagent-launch-guide.md](./subagent-launch-guide.md) for exact prompts.

### Step 3: Launch Phase 2
Execute Tier 2 medium-impact changes (552 lines, ~18 pages saved):
- 5 implementation subagents (can run in parallel)
- 1 review agent (validates all Phase 2 work)

### Step 4: Launch Phase 3
Execute cross-cutting consolidation:
- 3 implementation subagents (must run sequentially)
- 1 review agent (validates all Phase 3 work)

### Step 5: Final Validation
Run final validation agent to verify:
- Target page count achieved (110-130 pages)
- All core contributions preserved
- Thesis compiles without errors

## Architecture Overview

### 18 Total Agents
- **15 Implementation Agents**: Make specific changes
- **3 Review Agents**: Validate each phase
- **1 Validation Agent**: Final comprehensive check

### Output Tracking
All subagents record their work in markdown files at:
```
docs/thesis-reduction/execution/
├── phase-1-tier1/     # 6 implementation + 1 review
├── phase-2-tier2/     # 5 implementation + 1 review
└── phase-3-cross-cutting/  # 3 implementation + 1 review
```

### Key Features
✓ **Single Responsibility**: Each subagent has ONE focused task
✓ **Traceable**: Every decision documented in markdown
✓ **Reversible**: Separate git commits per subagent
✓ **Validated**: Review gates between phases
✓ **Conservative**: Preserves all core contributions

## Expected Outcomes

### Phase 1 (Tier 1)
- **Line Reduction**: ~749 lines
- **Page Savings**: ~24 pages
- **Risk Level**: Low
- **Duration**: 2-3 hours

### Phase 2 (Tier 2)
- **Line Reduction**: ~552 lines
- **Page Savings**: ~18 pages
- **Risk Level**: Medium
- **Duration**: 4-5 hours

### Phase 3 (Cross-Cutting)
- **Line Reduction**: ~50 lines
- **Page Savings**: ~2 pages
- **Risk Level**: Low
- **Duration**: 1-2 hours

### Total (Conservative Approach)
- **Line Reduction**: ~1,301 lines (27%)
- **Page Savings**: ~42 pages
- **Final Page Count**: ~113 pages ✓ (within 110-130 target)
- **Risk Level**: Low to Medium
- **Total Duration**: 8-11 hours

## What Gets Changed

### High-Impact Removals
- Empty placeholder files (62 lines)
- Exact duplicates (14 lines)
- Architecture-implementation overlap (91 lines)
- Generic academic content (60 lines)
- Repetitive code examples (285 lines)

### Conversions
- Code to prose + source_code_link (195 lines)
- Verbose prose to tables (29 lines)
- Full implementations to references (140 lines)

### Compressions
- Verbose explanations (154 lines)
- Technology justifications (55 lines)
- Use case redundancy (54 lines)

### Relocations
- TypeScript interfaces → Appendix A (87 net lines)
- mfs command → Appendix B (32 net lines)

## What Gets Preserved

### Core Contributions ✓
- AGENTS.md custom instructions system
- Map heatmap algorithm (unique technical contribution)
- Docs-as-Code philosophy (meta-contribution)
- Three-phase map pipeline (core architecture)
- Real-time broadcasting architecture

### Assessment Criteria ✓
- Aims and Objectives
- Functional/Non-Functional Requirements
- Use Case Scenarios
- System Architecture
- Implementation Details

## Success Criteria

- [ ] All 18 subagents completed successfully
- [ ] Final page count: 110-130 pages
- [ ] Thesis compiles without errors
- [ ] All core contributions preserved
- [ ] All assessment criteria intact
- [ ] All subagent outputs documented
- [ ] All changes committed to git
- [ ] Ready for advisor review

## Next Steps

1. Review [orchestration-plan.md](./orchestration-plan.md) to understand full strategy
2. Review [subagent-launch-guide.md](./subagent-launch-guide.md) for launch instructions
3. Compile thesis to establish baseline page count
4. Begin with Phase 1, Subagent 1.1 (File Deletion Agent)
5. Proceed systematically through phases
6. Monitor outputs in execution/ directory
7. Validate at each review gate
8. Complete final validation when all phases done

## Support Documents

- **master-reduction-plan.md**: The source plan being implemented
- **analysis-*.md**: Detailed analysis that informed the plan
- **README.md**: Overview of reduction project

## Questions?

Refer to the relevant document:
- **What to do?** → orchestration-plan.md
- **Which subagent handles what?** → subagent-mapping.md
- **How to launch subagents?** → subagent-launch-guide.md
- **Where do outputs go?** → execution/README.md
- **Why these changes?** → master-reduction-plan.md
