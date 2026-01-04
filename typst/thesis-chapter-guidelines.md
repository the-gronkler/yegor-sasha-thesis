# Thesis Chapter Structure Guidelines

## Separation of Technologies Used, System Architecture, and Implementation Chapters

Based on standard engineering thesis conventions and the project's AGENTS.md guidelines, these three chapters serve distinct, non-overlapping purposes. They build progressively without duplication by focusing on different levels of abstraction.

### 1. Technologies Used (`chapters/technologies.typ`)

- **Purpose**: High-level, strategic overview of technology choices. Explains _why_ specific tools, frameworks, and platforms were selected.
- **Focus**: Justification, alternatives considered, and benefits. Decision-making and requirements alignment.
- **Content Examples** (for restaurant ordering app):
  - Why Laravel 11 + Inertia.js + React 19 (vs. Django or Vue.js).
  - Why SCSS Modules for styling (semantic class names, no Tailwind).
  - Why Zustand for state management.
  - Why Pest for testing.
  - Why Vite for builds.
  - Brief mentions of Docker, PostgreSQL, Reverb.
- **Depth**: Conceptual and comparative. No code, diagrams, or implementation details.
- **Avoids Duplication**: Sets foundation with "what and why" of tech choices.

### 2. System Architecture (`chapters/system-architecture.typ`)

- **Purpose**: High-level design and structure of the system. How components fit together to meet requirements.
- **Focus**: Architecture patterns, component interactions, data flow, topology.
- **Content Examples**:
  - System divided into customer-facing (ordering, tracking) and employee-facing (management) modules.
  - Layered architecture: presentation (React/Inertia), business logic (Laravel), data (Eloquent).
  - Real-time updates via WebSockets/Reverb.
  - Database schema overview (Customer, Order, MenuItem entities).
  - Security architecture, scalability.
- **Depth**: Design-focused. Includes diagrams but no code.
- **Avoids Duplication**: Shows how chosen tech is organized.

### 3. Implementation (`chapters/implementation.typ`)

- **Purpose**: Actual development and coding of the system. How architecture was realized in practice.
- **Focus**: Code-level details, development workflow, execution.
- **Content Examples**:
  - Code structure: Laravel controllers, React components, SCSS modules.
  - Key implementations: Order tracking (backend events, frontend subscriptions).
  - Database migrations/seeders with code snippets.
  - Integration: Inertia links, Zustand stores.
  - Development process: Vite builds, Pest tests, Docker deployment.
  - Challenges overcome.
- **Depth**: Practical and detailed. Includes code snippets, structures, screenshots.
- **Avoids Duplication**: Implements architecture using technologies.

### Key Principles

- **Progressive Depth**: Technologies (why) → Architecture (what/how high-level) → Implementation (how detailed).
- **Cross-Referencing**: Use "As discussed in Technologies..." or "Building on Architecture...".
- **Focus on Purpose**: Strategic decisions → Design → Execution.
- **Thesis Guidelines**: Technologies for app tech (not dev process), Architecture for design, Implementation for building.
