#import "../../config.typ": *

== Thesis Documentation

The documentation methodology for this thesis adheres to the "Docs-as-Code" philosophy, treating the manuscript as a software artifact rather than a static document. The thesis is authored using *Typst*, a modern, programmable typesetting system that offers significant advantages over traditional tools like LaTeX or Microsoft Word in the context of software engineering documentation.

=== Typst Integration

Typst was selected for its high performance, developer-centric syntax, and powerful scripting capabilities. A primary motivation for this choice, alongside robust version control, is the capability to decouple manuscript content from formatting logic.

While Typst simplifies this separation, it technically allows users to mix styling concerns with content more freely than LaTeX, which typically enforces a stricter boundary. To mitigate this architectural flexibility, the thesis adheres to a rigorous structural convention:
- *Document-wide styling* is exclusively defined in `template.typ` and applied via the `main.typ` entry point.
- *Helper functions and constants* used within chapters are centralized in `config.typ`.

Unlike LaTeX, which relies on complex macros, Typst uses a consistent, functional scripting language. This allows for the creation of custom abstractions, such as the `code_example` and `source_code_link` functions used throughout this document, which dynamically generate links to the specific commit version of the codebase.

=== Comparative Technology Analysis

The decision to utilize Typst was made after a careful evaluation against traditional alternatives, specifically LaTeX and WYSIWYG editors (Microsoft Word, Google Docs).

==== Typst vs. LaTeX
While LaTeX is the academic standard, Typst was chosen for its modern architecture:
- *Performance*: Typst offers incremental compilation, rendering changes instantly, whereas LaTeX compilation is often slow and resource-intensive.
- *Syntax*: Typst employs a markdown-like syntax familiar to developers, reducing the cognitive load compared to LaTeX's verbose macro system.
- *Scripting*: The functional scripting language of Typst is more accessible to software engineers than TeX macros, enabling the rapid development of custom document automation.
- *Error Reporting*: Typst provides clear, descriptive error messages, significantly streamlining the debugging process compared to LaTeX's often cryptic logs.
- *Toolchain Simplicity*: Unlike LaTeX, which typically requires multi-gigabyte distributions (e.g., TeX Live) and complex package management, Typst operates as a single, lightweight binary with built-in package management, eliminating setup friction.
- *Bibliography Management*: Typst natively integrates citation management, supporting standard BibTeX files and IEEE formatting directly within the compilation process. This removes the need for multi-pass builds and external bibliography processors (like Biber) required by traditional LaTeX workflows.

==== Typst vs. WYSIWYG Editors
Compared to visual editors like Microsoft Word or Google Docs, Typst aligns with the "Docs-as-Code" methodology:
- *Version Control*: Typst files are plain text, enabling semantic versioning, diffing, and merging via Git. Binary formats (.docx) or cloud-native documents are opaque to standard developer tools.
- *Consistency*: Formatting is defined programmatically (e.g., in `template.typ`), ensuring strict adherence to thesis guidelines across all chapters. WYSIWYG tools often suffer from "style drift" due to manual formatting adjustments.
- *Automation*: Typst integrates seamlessly into CI/CD pipelines (e.g., verifying formatting or broken links), a capability that is difficult to implement with GUI-based editors.

=== Repository Structure

The thesis source code resides in the `typst/` directory within the main project repository. This co-location ensures that the documentation evolves in lockstep with the application. The structure mirrors a modular software architecture:
- *main.typ*: The entry point that orchestrates the compilation of chapters.
- *config.typ*: Centralized configuration for macros and accepted constants.
- *template.typ*: Defines the visual styling, layout, and typography rules.
- #strong("chapters/"): Individual chapters are separated into distinct files to minimize merge conflicts and facilitate parallel writing.

=== Workflow and Versioning

Strictly adhering to the protocols outlined in the Version Control section, the thesis manuscript is managed with the same rigorous Git workflow as the application codebase. All textual modifications are isolated in feature branches (e.g., #raw("docs/chapter-name")) and submitted via Pull Requests. This ensures that the academic content is subject to mandatory quality assurance - including automated formatting checks and most importantly  *peer review* - prior to integration. This discipline guarantees a transparent history of the document's evolution and facilitates structured collaboration between authors.
