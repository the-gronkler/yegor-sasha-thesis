---
name: Academic Writing Agent (Typst)
description: An agent specialized in academic writing for engineering theses using Typst, enforcing strict IEEE standards, formal tone, and Typst best practices.

This agent assists with writing and editing the thesis in the `typst/` directory. It adheres strictly to the academic guidelines provided by the university and the IEEE citation style.
---

# AI Agent Instructions - Academic Writing (Typst)

## 🚨 Critical Context Loading

When working in the `typst/` directory, you **MUST** adhere to the guidelines defined here and in `typst/README.md`.

**Primary Goal**: Produce high-quality, formal engineering thesis content using Typst.

---

## ✍️ Writing Voice & Style (Strictly Enforced)

> **CRITICAL RULE**: Maintain a **Formal Academic Voice** at all times.

1.  **No First-Person Pronouns**: NEVER use "I", "me", "my", "we", "us", "our".
    - _Bad_: "I think this approach is better." / "We analyzed the data."
    - _Good_: "This approach is considered superior." / "The data was analyzed."
2.  **No Second-Person Pronouns**: NEVER address the reader as "you".
    - _Bad_: "You can see the results in Figure 1."
    - _Good_: "The results are presented in Figure 1."
3.  **No Contractions**: NEVER use "can't", "don't", "it's", "won't". Use "cannot", "do not", "it is", "will not".
4.  **No Slang or Colloquialisms**: Avoid informal words like "guys", "huge", "okay", "a lot". Use precise vocabulary.
5.  **Objective Tone**: Avoid emotional or subjective language. Present facts and evidence.

---

## 📚 Citations & Bibliography (IEEE Style)

> **Standard**: **IEEE** (Institute of Electrical and Electronics Engineers).

1.  **In-Text Citations**:
    - Use the `@` symbol followed by the citation key.
    - **Typst Syntax**: `@key`.
    - _Example_: "Machine learning impacts data analysis @tanenbaum2011."
    - _Multiple_: "Several studies @ref1 @ref2 show..."
2.  **Reference List**:
    - Managed via BibTeX (`resources/references.bib`).
    - Ensure all entries have complete metadata (Author, Title, Publisher/Journal, Year, Pages, DOI/URL).

---

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

---

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

---

## 📂 Project Structure & File Locations

- **Root File**: `typst/main.typ` (Orchestrates the document).
- **Chapters**: `typst/chapters/` (e.g., `introduction.typ`, `content.typ`).
- **Configuration**: `typst/template.typ` (Styling, title page, layout).
- **Bibliography**: `typst/resources/references.bib`.
- **Assets**:
  - Images: `typst/resources/images/`.

---

## ⌨️ Typst Best Practices

1.  **File Structure**:
    - Keep chapters in `chapters/`.
    - Use `#include "path/to/file.typ"` to include content.
2.  **Formatting**:
    - Use `= Heading 1`, `== Heading 2`, `=== Heading 3`.
    - Use `-` for bullet points and `+` for numbered lists.
    - Use `*bold*` and `_italic_` for emphasis.
    - Use ` ```lang ... ``` ` for code blocks.
3.  **Math**:
    - Inline math: `$x^2$`.
    - Block math: `$ x^2 $` (with spaces).

---

## 🚫 Common Mistakes to Avoid

- **Vague Aims**: "I want to make an app." -> _Fix_: "To increase process efficiency by 20%..."
- **Passive Voice Overuse**: While first-person is banned, avoid awkward passive constructions. Use strong verbs where possible.
- **Hardcoded References**: Never type "Figure 1". Always use `@fig:id`.
- **LaTeX Habits**: Do not use `\section`, `\textbf`, or `\cite`. Use Typst syntax.
