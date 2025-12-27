# LaTeX Development Setup for Yegor-Sasha Thesis

This folder contains LaTeX files and documentation for the thesis project.

## Recommended Setup: Dev Containers (Docker)

This is the **easiest and most reliable** way to work on the thesis. It runs LaTeX inside a container with all dependencies pre-installed, so you don't need to install anything on your Windows machine except Docker.

### Prerequisites

1.  **Docker Desktop**: [Download and install](https://www.docker.com/products/docker-desktop/).
2.  **VS Code Extension**: Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.

### How to Start

1.  Open this project in VS Code.
2.  Press F1 (or Ctrl+Shift+P) and run: **Dev Containers: Reopen in Container**.
3.  Wait for the container to build (this may take a long time the first time as it downloads the full TeX Live distribution).
4.  Once ready, you are in a fully configured LaTeX environment!

> **Note**: The Dev Container mounts your local folder. Any files created or edited inside the container (like the built PDF) are instantly available in your local folder on your host machine.

### Usage

You can use VS Code Tasks to build the project. Press `Ctrl+Shift+P`, type "Run Task", and select one of the following:

- **LaTeX: Build**: Compiles the project once. (Shortcut: `Ctrl+Shift+B`)
- **LaTeX: Watch Mode**: Compiles the project and watches for changes. The PDF will automatically update when you save a file.

Alternatively, you can use the terminal:

- **Build**: `cd latex && latexmk -lualatex main.tex`
- **Watch**: `cd latex && latexmk -pvc -lualatex main.tex`

To view the PDF, open `latex/main.pdf` in VS Code.

---

## 📚 Documentation & Guidelines

When writing or editing the thesis, please refer to the following files:

1.  **`latex/AGENTS.md`**: Instructions for AI agents (and humans!) on writing style, citations, and project structure. **Read this if you are using Copilot.**
2.  **`latex/gago-thesis-guidelines.md`**: The official university guidelines for the thesis, including formatting rules and content requirements.

---

## Template Information

- **Main File**: `latex/main.tex`
- **Engine**: LuaLaTeX (Required)
- **Structure**:
  - `contents/`: Contains the actual content of the thesis.
    - `pre-content/`: Title page, abstracts, acknowledgements.
    - `Introduction.tex`: Introduction chapter.
    - `Content.tex`: Main content chapters.
  - `resources/`: Configuration and assets.
    - `pjconfig.sty`: Custom package/style configuration.
    - `references.bib`: Bibliography database.
    - `fonts/`: Custom fonts.
    - `logo/`: University/Project logos.
