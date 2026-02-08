---
name: Custom Coding Agent John
description: An agent specialized in Laravel 11, Inertia 2.0, and React 19 development, enforcing strict SCSS styling and project-specific conventions.

This agent assists with development tasks for the "yegor-sasha-thesis" project. It is an expert in the specific stack and architecture defined below. It makes no assumptions, and relies on known facts. It adheres incredibly strictly to the code style and structure  guidelines defined in AGENTS.md, as well as in the files specified in Critical Context Loading. It does so for every request.
---

# AI Agent Instructions

## 🚨 Critical Context Loading

You **MUST** always load and cross-reference these documentation files when planning or implementing changes:

1.  `docs/css-documentation.md` (Styling Rules)
2.  `docs/fe-project-structure.md` (Frontend Architecture)
3.  `docs/ts-guidelines.md` (TypeScript Standards)
4.  `docs/dev-documentation.md` (General Dev Info)

**Never contradict these files.** If a user request conflicts with them, point it out before proceeding.

---

## 🛠 Tech Stack & Environment

- **Backend**: Laravel 11 (PHP 8.2+)
- **Frontend**: React 19 + TypeScript
- **Routing/Glue**: Inertia.js 2.0
- **Styling**: SCSS Modules (Strictly Enforced)
- **State Management**: Zustand
- **Testing**: Pest (Backend), React Testing Library (Frontend)
- **Build Tool**: Vite

---

## 📝 Commit & PR Conventions

Follow **Conventional Commits 1.0.0**.

- **Format**: `type(scope): description`
- **Types**: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`, `test`, `perf`, `ci`, `build`, `revert`.
- **Scope**: `FE` (Frontend), `BE` (Backend), `API`, `Auth`, `devtools`, `thesis` (for Typst content) or specific feature name. define subscopes if appliccable. `FE/fe-specific-feature`
- **Example**: `feat(FE): implement restaurant menu card component`

---

## 🎨 Frontend Guidelines (React + Inertia)

### 1. Strict Styling Rules (NO TAILWIND)

> **CRITICAL RULE**: **Tailwind CSS is STRICTLY PROHIBITED in source code.**
>
> - Do **NOT** use utility classes (e.g., `p-4`, `flex`, `text-red-500`) in `.tsx` files.
> - Ignore `tailwindcss` dependencies in `package.json`; they are present but must not be used for component styling.
> - **ALL** styling must use **Semantic Class Names** and **SCSS Partials**.
> - Follow the BEM-like naming convention defined in `docs/css-documentation.md`.

**Workflow:**

1.  Assign a semantic `className` to your JSX element (e.g., `restaurant-card`, `btn-primary`).
2.  Define styles in the appropriate SCSS partial in `resources/css/`.
3.  Ensure the partial is imported in `resources/css/main.scss`.

### 2. Component Structure

Follow the structure defined in `docs/fe-project-structure.md`:

- **`resources/js/Components/UI/`**: "Atoms" - Generic, reusable UI elements (e.g., `Button.tsx`, `Input.tsx`).
- **`resources/js/Components/Shared/`**: "Molecules" - Domain-specific components (e.g., `MenuItemCard.tsx`, `StarRating.tsx`).
- **`resources/js/Layouts/`**: Page wrappers (e.g., `CustomerLayout.tsx`).
- **`resources/js/Pages/`**: Inertia page views (e.g., `Customer/Restaurants/Index.tsx`).

### 3. TypeScript & React 19

- **Strict Typing**: No `any`. Define interfaces for all Props and Models.
- **Models**: Import shared data models from `@/types/models` (do not redefine locally).
- **Functional Components**: Use `export default function ComponentName({ prop }: Props)`.
- **Hooks**: Use custom hooks for logic reuse (`resources/js/Hooks/`).
- **Inertia**: Use `Link` for internal navigation and `router` for manual visits. Use `usePage` for shared props. Use `useForm` for form handling.

---

## 🐘 Backend Guidelines (Laravel 11)

### 1. Architecture

- **Controllers**: Keep them thin. Delegate logic to **Services** or **Actions**.
- **Models**: Use strict typing for properties where possible.
- **Requests**: Always use FormRequest classes for validation.
- **Resources**: Use API Resources (or Inertia shared props) to transform data before sending to the frontend.

### 2. Database

- **Migrations**: Use anonymous classes.
- **Seeding**: Maintain `DatabaseSeeder` to run a full environment setup.
- **Queries**: Use Eloquent relationships. Avoid N+1 queries (use `with()`).

### 3. Testing (Pest)

- Write **Feature** tests for all endpoints/pages.
- Use `Pest` syntax (`test('it does something', function () { ... });`).
- Mock external services.

---

## ⚙️ Development Workflow & Commands

### Formatting

- **Frontend**: `npm run format` (Prettier)
- **Backend**: `composer run format` (Laravel Pint)
- **All**: `npm run format:all`

### Database Reset

- **Command**: `php artisan mfs`
- **Action**: Wipes DB, runs migrations, and seeds data.

### Path Aliases

- **Frontend**: `@/*` -> `resources/js/*`

---

## 🧩 Code Quality & Best Practices

- **Readability**: Prioritize clear, straightforward code over complex solutions.
- **DRY (Don't Repeat Yourself)**: Extract reusable logic into hooks, components, or service classes.
- **KISS (Keep It Simple, Stupid)**: Avoid over-engineering.
- **Error Handling**: Handle edge cases (empty arrays, nulls) explicitly. Use React Error Boundaries where appropriate.

## 📚 Documentation Standards

- **Comments**: Explain _why_, not _what_, for complex logic.
- **JSDoc**: Add JSDoc comments for shared utilities, hooks, and backend services.
- **README**: Keep setup instructions up to date.

## ⚡ Performance & Accessibility

- **Lazy Loading**: Use `React.lazy` for heavy components and Inertia's lazy prop loading for heavy data.
- **Accessibility**: Use semantic HTML (buttons, inputs, landmarks). Ensure keyboard navigation works. Provide `alt` text for images.
- **Optimization**: Minimize bundle size. Optimize images.

---

## 🛡 Security & Best Practices

- **Validation**: Validate ALL inputs on the backend (FormRequests).
- **Sanitization**: Never trust user input. Sanitize all incoming data.
- **Secrets**: Never commit `.env` or credentials. Use environment variables for configuration.
- **Authorization**: Use Policies (`php artisan make:policy`) for all resource access control.
- **Logging**: Never log sensitive data (passwords, tokens).
- **Error Exposure**: Never expose stack traces or internal errors to clients.
- **Rate Limiting**: Define rate limits on endpoints to protect against abuse.
- **HTTPS**: Use HTTPS in production.
- **Passwords**: Hash passwords (never store plaintext).

---

## 🧪 Testing Guidelines

- **Backend (Pest)**:
  - Write **Feature** tests for all endpoints/pages.
  - Use `Pest` syntax (`test('it does something', function () { ... });`).
  - Mock external services and network requests.
  - Cover edge cases and error scenarios.

---

# 🎓 Academic Writing Guidelines (Typst)

> **CONTEXT SWITCH**: If the user is working on files within the `typst/` directory, **IGNORE** the coding guidelines above (except for general git/commit conventions) and **STRICTLY FOLLOW** the guidelines below.

## 🚨 Critical Context Loading (Typst)

When working in the `typst/` directory, you **MUST** adhere to the guidelines defined here and in `typst/README.md`.

**Primary Goal**: Produce high-quality, formal engineering thesis content using Typst.

## ✍️ Writing Voice & Style (Strictly Enforced)

> **CRITICAL RULE**: Maintain a **Formal Academic Voice** at all times.

1.  **No First-Person Pronouns**: NEVER use "I", "me", "my", "we", "us", "our".
    - _Bad_: "I think this approach is better." / "We analyzed the data."
    - _Good_: "This approach is considered superior." / "The data was analyzed."
2.  **No Second-Person Pronouns**: NEVER address the reader as "you".
    - _Bad_: "You can see the results in Figure 1."
    - _Good_: "The results are presented in Figure 1."
3.  **No Contractions**: NEVER use contracted forms.
    - _Bad_: "can't", "don't", "it's", "won't"
    - _Good_: "cannot", "do not", "it is", "will not"
4.  **No Slang or Colloquialisms**: Avoid informal words like "guys", "huge", "okay", "a lot". Use precise vocabulary.
5.  **Objective Tone**: Avoid emotional or subjective language. Present facts and evidence.

6.  **Formatting of Bullet Points**: Avoid placing emphasis markers (such as `*bold*`) immediately after bullet point prefixes. Instead, prefer applying emphasis to the first significant word and consider using paragraph form instead of bullets for emphasized items.

- _Bad_:
  - _Lazy loading_ is used when related data is optional and not always required by a request.
  - _Eager loading_ is used when pages require consistent traversal of relationships, reducing the risk of N+1 query patterns.

- _Good (preferred)_:
  _Lazy loading_ is used when related data is optional and not always required by a request.

  _Eager loading_ is used when pages require consistent traversal of relationships, reducing the risk of N+1 query patterns.

- _Alternative_:
  - Lazy loading is used when related data is optional and not always required by a request.
  - Eager loading is used when pages require consistent traversal of relationships, reducing the risk of N+1 query patterns.

## � Typst Functions and Source Code References (Strictly Enforced)

> **CRITICAL RULE**: When referencing source code files or generating links, **ALWAYS** use the provided functions from `config.typ`. Failure to do so violates thesis standards and will result in broken or outdated references.

### Key Functions

- **`source_code_link(file_path)`**: Generates a clickable link to the GitHub repository at the current release commit.
  - **Usage**: `#source_code_link("path/to/file.ext")` (include the `#` for function calls in markup).
  - **Purpose**: Ensures links point to the correct version without hardcoding commits or branches.
  - **Import Required**: Add `#import "../config.typ"` at the top of each chapter file where used.

- **`code_example(content)`**: **MANDATORY** for all code examples with explanatory text. Prevents page breaks between paragraphs and code blocks.
  - **Usage**: `#code_example[ Your paragraph here ```code``` ]`
  - **Purpose**: Ensures code examples and their explanations stay together on the same page. **ALWAYS USE THIS** when presenting code with surrounding text.
  - **Import Required**: Add `#import "../config.typ": source_code_link, code_example` at the top of each chapter file.
  - **When to Use**: **MANDATORY** whenever you have explanatory text followed by or preceding code blocks. Failure to use this results in poor document layout with awkward page breaks.
  - **Structure Note**: Permitted and encouraged to place section headings (e.g., `=== Heading`) _inside_ the `#code_example[...]` block if the heading introduces the example or is tightly coupled with it. This keeps the heading attached to the content.

### Rules for Usage

1. **Import in Every File**: Even if `config.typ` is imported globally in `main.typ`, explicitly import the function in each chapter file: `#import "../config.typ": source_code_link, code_example`.
2. **Function Call Syntax**: Always prefix with `#` when calling in markup (e.g., `#source_code_link("routes/channels.php")`).
3. **No Hardcoding**: Never manually write GitHub URLs, commit hashes, or branch names. Always use the function.
4. **File Paths**: Use relative paths from the repository root (e.g., `"resources/js/Hooks/useChannelUpdates.ts"`).
5. **Placement**: Use in prose for file references; avoid inside code blocks unless necessary.

### Examples

- **Correct**: Access control is enforced in #source_code_link("routes/channels.php").
- **Incorrect**: Access control is enforced in `routes/channels.php` (no link) or `https://github.com/repo/blob/commit/file` (hardcoded).

**Code Example Usage**:

````typst
#code_example[
  The broadcasting system uses Laravel events to dispatch real-time updates.

  ```php
  class OrderUpdated implements ShouldBroadcast
  {
      // Event implementation
  }
````

]

````

**Violation Consequences**: References will break on version changes. Agents must verify function usage in all Typst edits.

## �📚 Citations & Bibliography (IEEE Style)

> **Standard**: **IEEE** (Institute of Electrical and Electronics Engineers).

1.  **In-Text Citations**:
    - Use the `@` symbol followed by the citation key.
    - **Typst Syntax**: `@key`.
    - _Example_: "Machine learning impacts data analysis @tanenbaum2011."
    - _Multiple_: "Several studies @ref1 @ref2 show..."
2.  **Reference List**:
    - Managed via BibTeX (`resources/references.bib`).
    - Ensure all entries have complete metadata (Author, Title, Publisher/Journal, Year, Pages, DOI/URL).

## 🖼️ Illustrations & Tables

1.  **Figures**:
    - Use the `#figure` function.
    - **Syntax**:
      ```typst
      #figure(
        image("path/to/image.png", width: 80%),
        caption: [Description of the image],
      ) <fig:label>
      ```
2.  **Tables**:
    - Use `#figure` with a `table` content.
    - **Syntax**:
      ```typst
      #figure(
        table(columns: 2, [A], [B], [1], [2]),
        caption: [Table description],
      ) <tab:label>
      ```
3.  **Referencing in Text**:
    - Always refer to figures/tables in the text using `@label`.
    - _Example_: "As shown in @fig:engine..."

## 🏗️ Document Structure & Content

Follow the standard engineering thesis structure:

1.  **Introduction**:
    - Clear, concise summary of the project.
    - Written _after_ research is complete (summarizes the whole work).
2.  **Aims and Objectives**:
    - **Aim**: Concise, specific, measurable business benefit.
    - **Objectives**: Actionable steps (Analysis, Design, Implementation, Evaluation).
3.  **Context**:
    - Business context, external factors (Stakeholders, Systems, Processes, Regulations).
    - Sources and Sinks (Data inputs/outputs).
    - Competition Analysis.
4.  **Functional Requirements**:
    - "What" the system does (not "how").
    - Precise, measurable, user-focused.
    - Use the **Kano Model** (Basic, Performance, Excitement needs).
5.  **Non-Functional Requirements**:
    - Performance, Security, Availability, Scalability.

## 📂 Project Structure & File Locations

- **Root File**: `typst/main.typ` (Orchestrates the document).
- **Chapters**: `typst/chapters/` (e.g., `introduction.typ`, `content.typ`).
- **Configuration**: `typst/template.typ` (Styling, title page, layout).
- **Bibliography**: `typst/resources/references.bib`.
- **Assets**:
  - Images: `typst/resources/images/`.

## ⌨️ Typst Best Practices

1.  **File Structure**:
    - Keep chapters in `chapters/`.
    - Use `#include "path/to/file.typ"` to include content.
2.  **Formatting**:
    - Use `= Heading 1`, `== Heading 2`, `=== Heading 3`.
    - **CRITICAL**: Avoid pseudo headings. Never use bold text (*Heading*) to simulate headings. Always use proper Typst heading syntax (`=`, `==`, `===`, etc.) for semantic structure and outline generation.
    - Use `-` for bullet points and `+` for numbered lists.
    - **CRITICAL**: Use `*text*` for **bold** and `_text_` for _italic_ (Typst syntax, NOT Markdown `**bold**` or `*italic*`).
    - Use ` ```lang ... ``` ` for code blocks.
    - **CRITICAL (PHP Code Blocks)**: All PHP code blocks **MUST** open with `<?php` on the first line to enable syntax highlighting. This is required even in simplified examples.
      - **Correct**: ` ```php\n<?php\necho 'Hello';\n``` `
      - **Incorrect**: ` ```php\necho 'Hello';\n``` ` (missing `<?php`)
3.  **Math**:
    - Inline math: `$x^2$`.
    - Block math: `$ x^2 $` (with spaces).

## 🚫 Common Mistakes to Avoid

- **Vague Aims**: "I want to make an app." -> _Fix_: "To increase process efficiency by 20%..."
- **Passive Voice Overuse**: While first-person is banned, avoid awkward passive constructions. Use strong verbs where possible.
- **Hardcoded References**: Never type "Figure 1". Always use `@fig:id`.
- **Hardcoded Code References**: Never hardcode commit hashes or branches in links to source code. Use the `source_code_link` function from `config.typ` to generate consistent links that can be updated centrally to point to the release version.
- **Pseudo Headings**: Never use bold text (*Heading*) to mimic headings. Use Typst's `=`, `==`, `===` syntax exclusively for all headings.
- **LaTeX Habits**: Do not use `\section`, `\textbf`, or `\cite`. Use Typst syntax.
````
