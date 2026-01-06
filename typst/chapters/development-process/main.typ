//  I want to write this one (ㅅ´ ˘ `) pls
#import "../../config.typ": *

= Development Process

== Overview
This chapter outlines the development process for the...

== Planning
...

== Version Control
GIt
Github
Trunk based
required pull requests and code review

== Documentation
...

== deployment
Azure vm
ssh, docker compose

== Automations
husky formatting
deployment github action

== Thesis Documentation
Typst - allows us to manage the thesis with the same approach as the codebase.

== AI Use

=== AI in Research
AI was used in the initial research phase to assist with exploring existing solutions and competitors, brainstorming potential features, and defining the project scope and estimating workloads during the early pre-planning stage.

This process helped identify key market trends, potential gaps in existing solutions, and specific project requirements essential for guiding the development phase. All findings were manually verified and appropriately cited.

=== AI in Development
During development, AI was employed primarily for code review, as it can identify common mistakes and suggest improvements.

To this end, a custom AI code review agent was developed, and added to the project's agent configuration file, #source_code_link("/AGENTS.md").

==== Agent Instructions (AGENTS.md)
The file #source_code_link("/AGENTS.md") contains project-specific instructions for AI agents. It ensures AI follows the same conventions as human code reviews.

In this project, this file lists key rules that stay consistent, such as the technology stack, frontend structure, styling rules, testing requirements, and security guidelines.

This follows GitHub Copilot's system, where `AGENTS.md` files provide agent instructions. The closest file in the directory structure takes priority @GitHubCopilotRepoInstructions.

The AGENTS.md open format describes `AGENTS.md` as a dedicated and predictable place to provide project context and instructions for coding agents, typically including practical environment tips, testing guidance, and pull request expectations @AgentsMDFormat.

Guidance on writing effective instruction files emphasizes clear, natural-language rules in Markdown, avoiding conflicting instructions, and documenting build and validation steps (including working command sequences and prerequisites) to reduce trial-and-error when an agent executes changes @GitHubCopilotRepoInstructions.

The following techniques were utilized in this file:

- Defining the agent as an expert in the specific technology stack and architecture.
- Instructing it to make no assumptions and rely only on known facts.
- Referencing external documentation for detailed rules.
- Using structured lists for clarity.
- Specifying prohibited actions explicitly (e.g., "NO TAILWIND").
- Providing concrete examples.
- Enforcing strict adherence with warnings.
- Incorporating context switches for different modes (e.g., academic writing).

This method aims to ensure the agent follows instructions, leading to higher-quality contributions and improved consistency across the codebase. These techniques align with Copilot's Markdown-based customization for directing AI in development @VSCodeCopilotCustomizeChat.

=== AI in Thesis Writing
Since the exact same processes are used for both code and thesis writing, AI was utilized in a similar manner for thesis documentation. An additional academic writing agent was created to assist with this, incorporating a context switch to focus on academic writing style and proper citations. It was used to *suggest improvements* to phrasing, grammar, and structure of the thesis content, as well as to identify potential inconsistencies.

Additionally, AI was employed to generate initial drafts of _some_ sections, help with brainstorming, and aid in choosing relevant code examples from the project's codebase.

=== Ethical Considerations
The use of AI in research, development, and academic writing raises several ethical considerations that must be addressed to maintain integrity and transparency. As AI is a tool, its application was guided by principles of academic honesty, ensuring that any and all AI-generated content was reviewed, verified, and augmented by human expertise.

For thesis writing, AI was employed *solely* as an assistive tool for drafting and improvement suggestions, with *all* final content authored, curated, and approved by both authors.

The responsibility for structure, argumentation, and academic rigor remains with the authors, ensuring that AI did not supplant original thought or scholarly judgment.

Overall, these principles ensure that AI applications maintain essential human oversight, preventing over-reliance on automated systems and preserving the integrity of critical thinking and originality in both academic research and professional development.



