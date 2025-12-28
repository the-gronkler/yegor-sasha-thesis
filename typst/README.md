# Typst Thesis Template

This project uses [Typst](https://typst.app/), a modern and fast alternative to LaTeX, to generate the thesis PDF.

## Setup & Requirements

1.  **VS Code**: Recommended editor.
2.  **Extension**: Install [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) (ID: `myriad-dreamin.tinymist`) for syntax highlighting and instant preview.

## 📂 Project Structure

- **`main.typ`**: The entry point. This file orchestrates the document order.
- **`template.typ`**: Defines the visual styling, title page, and layout rules.
- **`chapters/`**: Contains the actual content of your thesis.
- **`pre-content/`**: Contains the Abstract and Acknowledgements.
- **`resources/`**:
  - `images/`: Place your figures here.
  - `references.bib`: Your bibliography file (BibTeX format).

---

## ✍️ How to Add a New Chapter

1.  **Create a file**: Create a new `.typ` file in the `chapters/` folder (e.g., `chapters/03-methodology.typ`).
2.  **Start writing**: Begin the file with a Level 1 heading.

    ```typst
    = Methodology <methodology>

    In this chapter, we discuss...
    ```

3.  **Include it**: Open `main.typ` and add an include statement where you want the chapter to appear.
    ```typst
    #include "chapters/introduction.typ"
    #include "chapters/content.typ"
    #include "chapters/03-methodology.typ" // <-- Add this
    ```

---

## 🎨 Formatting Cheat Sheet

### Text Styles

- **Bold**: `*strong text*`
- _Italic_: `_emphasized text_`
- `Monospace`: `` `code` ``
- Paragraphs: Just leave a blank line between blocks of text.

### Headings

Headings automatically handle numbering and page breaks (for Level 1).

```typst
= Chapter Title (Level 1)
== Section Title (Level 2)
=== Subsection Title (Level 3)
```

### Lists

**Bullet Points:**

```typst
- First item
- Second item
  - Indented item
```

**Numbered Lists:**

```typst
+ First step
+ Second step
```

### Code Blocks

Use three backticks and specify the language.

````typst
```python
def main():
    print("Hello World")
```
````

### Figures & Images

1. Place image in `resources/images/`.
2. Use the `#figure` function:

```typst
#figure(
  image("../resources/images/diagram.png", width: 80%),
  caption: [Architecture Diagram],
) <fig:arch>
```

3. **Reference it**: "As seen in @fig:arch..."

### Citations & Bibliography

1. Add your BibTeX entry to `resources/references.bib`.
   ```bibtex
   @article{smith2023,
     author = {Smith, John},
     title = {Typst is Cool},
     year = {2023}
   }
   ```
2. **Cite it**: "According to Smith @smith2023..."

---

## 🚀 How to Preview/Compile

**VS Code (Recommended):**

1.  Install the **Tinymist Typst** extension.
2.  Open `main.typ`.
3.  Click the "Typst Preview" icon (usually top right) or run command `Typst: Open Preview`.

**Command Line:**

```bash
typst compile main.typ
```
