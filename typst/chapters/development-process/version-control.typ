#import "../../config.typ": *

== Version Control

Version control systems form the foundation of collaborative software development, enabling teams to track changes, manage concurrent work, and maintain code quality. The project employs Git as the distributed version control system, hosted on GitHub as the collaboration platform.

=== Git Workflow

The development follows a trunk-based development model @TrunkBasedDev, a source-control branching strategy where developers integrate small, frequent updates directly into a shared main branch (the "trunk"). Unlike long-lived feature branches common in Git Flow @DriessenGitFlow2010, trunk-based development emphasizes keeping branches short-lived - ideally merged within a few days - to reduce integration complexity and maintain a continuously releasable codebase.

Feature branches are created for each discrete unit of work, typically corresponding to a single feature, bug fix, or documentation update. Branch names follow the pattern `feat/feature-name`, `fix/bug-description`, or `docs/update-section`, providing clear semantic meaning. Once complete, these branches are merged back to the trunk via pull requests and promptly deleted.

=== Pull Request Process

All changes must be submitted via pull requests (PRs) on GitHub. This mandatory review process ensures that:

- Code quality standards are maintained
- Architectural decisions are validated
- Potential regressions are identified
- Knowledge sharing occurs across team members

Each pull request requires at least one approving review before merging. The review process includes automated checks for code formatting and linting, supplemented by manual code review focusing on logic correctness, security implications, and adherence to project conventions.

This mandatory process is enforced by GitHub branch protection policies, ensuring that all automated checks pass and the required reviews are completed before changes can be merged to the main branch.

=== Commit Conventions

Commits follow the Conventional Commits 1.0.0 specification @ConventionalCommits to ensure consistent and meaningful commit messages. This standard provides a uniform format for commit messages across the project, facilitating automated tooling for version management, changelog generation, and semantic versioning.

The format is:

```go
type(scope): description
```

Alternatively, a strictly hierarchical slash-delimited format is accepted:

```go
type/scope/sub-scope/description
```

Where:
- *type* indicates the nature of the change (e.g., `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `perf`, `ci`)
- *scope* specifies the affected component (e.g., `FE` for frontend, `BE` for backend, `API`, `Auth`, or specific feature names)
- *description* provides a concise, imperative summary of the change

While the standard Conventional Commit format is preferred, the slash-delimited alternative (`type/scope/description`) is also accepted because it aligns with tooling defaults (GitHub and VS Code suggest branch names as PR titles), improves typing efficiency by eliminating shift-keyed characters, and provides hierarchical clarity by representing feature contexts as paths.

Examples: `feat(FE): implement restaurant menu card`, `fix/BE/orders/resolve-race-condition`, `docs(thesis): add database design chapter`.
