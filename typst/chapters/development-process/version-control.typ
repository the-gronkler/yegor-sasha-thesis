#import "../../config.typ": *

== Version Control

Version control systems form the foundation of collaborative software development, enabling teams to track changes, manage concurrent work, and maintain code quality. The project employs Git as the distributed version control system, hosted on GitHub as the collaboration platform.

=== Git Workflow

The development follows a trunk-based development model, a source-control branching strategy where developers integrate small, frequent updates directly into a shared main branch (the "trunk"). Unlike long-lived feature branches common in Git Flow, trunk-based development emphasizes keeping branches short-lived—ideally merged within a few days—to reduce integration complexity and maintain a continuously releasable codebase.

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

Commits follow the Conventional Commits 1.0.0 specification to ensure consistent and meaningful commit messages. This standard provides a uniform format for commit messages across the project, facilitating automated tooling for version management, changelog generation, and semantic versioning.

The format is:

```go
type(scope): description
```

Alternatively, a strictly hierarchical slash-delimited format is accepted:

```go
type/scope/sub-scope/description
```

Where:
- *type* indicates the nature of the change:
  - `feat`: A new feature
  - `fix`: A bug fix
  - `chore`: Maintenance tasks (e.g., dependency updates)
  - `refactor`: Code restructuring without functional changes
  - `docs`: Documentation updates
  - `style`: Code style changes (formatting, etc.)
  - `test`: Adding or modifying tests
  - `perf`: Performance improvements
  - `ci`: Continuous integration changes
  - `build`: Build system modifications
  - `revert`: Reverting previous commits
- *scope* specifies the affected component:
  - `FE`: Frontend (React/TypeScript)
  - `BE`: Backend (Laravel/PHP)
  - `API`: API-related changes
  - `Auth`: Authentication and authorization
  - `devtools`: Development tooling
  - `thesis`: Typst documentation content
  - Specific feature names or subscopes (e.g., `FE/menu-card`, `BE/order-processing`)
- *description* provides a concise, imperative summary of the change

While the standard Conventional Commit format is preferred, the slash-delimited alternative (`type/scope/description`) is also accepted. This alternative format is accepted mainly because it aligns with *tooling defaults* - the branch name is often suggested by platforms like GitHub and VS Code as the default Pull Request title, ensuring that the suggestion is automatically a valid commit message. Additionally, this format improves *typing efficiency* by eliminating the need for shift-keyed characters and offers *hierarchical clarity* by representing feature contexts as paths (e.g., `feat/FE/auth/login`) that map logically to the modular directory structure.

Examples include:
- `feat(FE): implement restaurant menu card component`
- `fix/BE/orders/resolve-race-condition`
- `docs(thesis): add database design chapter`
- `refactor/API/responses/standardize-error-format`

This standardized format enables automated changelog generation, semantic versioning determination, and facilitates understanding of the project's evolution through its commit history.
