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

Each pull request requires at least one approving review before merging. The review process includes local pre-commit formatting checks (described below), supplemented by manual code review focusing on logic correctness, security implications, and adherence to project conventions.

This process is supported by GitHub branch protection policies, ensuring that the required reviews are completed before changes can be merged to the main branch.

=== Pre-Commit Hooks

The project uses *Husky* to run automated checks before each commit (#source_code_link(".husky/pre-commit")). The pre-commit hook invokes `lint-staged`, which runs code formatters (Prettier for frontend files, Laravel Pint for PHP) only on staged files. This encourages consistent code style across the codebase by automatically formatting staged files before each commit, reducing friction compared to requiring developers to manually run formatters. The hook is configured with a non-blocking fallback to avoid disrupting the development workflow when formatting issues are detected.

=== Commit Conventions

Commits follow the Conventional Commits 1.0.0 specification @ConventionalCommits to ensure consistent and meaningful commit messages. This standard provides a uniform format for commit messages across the project, facilitating automated tooling for version management, changelog generation, and semantic versioning.

The format is:

```go
type(scope): description
```

A slash-delimited alternative (`type/scope/description`) is also accepted, as it aligns with platform defaults where branch names are suggested as pull request titles. The *type* field indicates the nature of the change (e.g., `feat`, `fix`, `refactor`, `docs`), and the *scope* specifies the affected component:

#figure(
  table(
    columns: 2,
    [*Scope*], [*Area*],
    [`FE`], [Frontend (React/TypeScript)],
    [`BE`], [Backend (Laravel/PHP)],
    [`thesis`], [Typst documentation content],
    [Feature name], [Subscopes (e.g., `FE/menu-card`)],
  ),
  caption: [Commit scope conventions],
) <tab:commit-scopes>

Examples include:
- `feat(FE): implement restaurant menu card component`
- `fix/BE/orders/resolve-race-condition`
