#import "../../config.typ": *

== Thesis Documentation

The documentation methodology for this thesis is grounded in the "Docs-as-Code" philosophy @GentleDocsLikeCode2017, whereby the manuscript is treated as a software artifact rather than a static document. The thesis is authored using *Typst* @TypstDocs, a modern, programmable typesetting system that offers significant advantages over traditional tools like LaTeX or Microsoft Word in the context of software engineering documentation.

=== Typst Integration

Typst was selected for its high performance, developer-centric syntax, and powerful scripting capabilities. A primary motivation for this choice is the capability to decouple manuscript content from formatting logic:
- *Document-wide styling* is exclusively defined in `template.typ` and applied via the `main.typ` entry point.
- *Helper functions and constants* used within chapters are centralized in `config.typ`.

Unlike LaTeX, which relies on complex macros, Typst uses a consistent, functional scripting language. This enables the creation of custom abstractions, such as the `code_example` and `source_code_link` functions used throughout this document, which dynamically generate links to the specific commit version of the codebase.

The thesis source code resides in the `typst/` directory within the main project repository. This co-location ensures that the documentation evolves in lockstep with the application. The structure mirrors a modular software architecture:
- *main.typ*: The entry point that orchestrates the compilation of chapters.
- *config.typ*: Centralized configuration for helper functions and shared constants.
- *template.typ*: Defines the visual styling, layout, and typography rules.
- #strong("chapters/"): Individual chapters are separated into distinct files to minimize merge conflicts and facilitate parallel writing.

=== Comparative Technology Analysis

The decision to utilize Typst was made after a careful evaluation against traditional alternatives.

While LaTeX remains the academic standard, Typst offers incremental compilation for instant rendering @TypstDocs, a markdown-like syntax familiar to developers, and clear error messages -- all without requiring multi-gigabyte distributions @TeXLiveGuide. Its native bibliography management supports BibTeX files and IEEE formatting directly, eliminating the multi-pass builds and external processors required by LaTeX workflows.
