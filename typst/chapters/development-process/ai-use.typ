
#import "../../config.typ": source_code_link

== AI Use

=== AI in Research
AI was used in the initial research phase to assist with exploring existing solutions and competitors, brainstorming potential features, defining the project scope, and estimating workloads during the pre-planning stage.

This process helped identify key market trends, potential gaps in existing solutions, and specific project requirements essential for guiding the development phase. All findings were manually verified and appropriately cited.

=== AI in Development
During the development phase, AI tools were utilized to augment manual code reviews. The AI analyzed changes against the project's strict architecture and styling guidelines. It helped identify potential regressions, suggest optimizations, and ensure adherence to the defined coding standards before human review.

To facilitate this, a custom context configuration was established in #source_code_link("/AGENTS.md"), enabling the AI to act as a specialized reviewer aware of the project's specific constraints.

==== Agent Instructions (AGENTS.md)
The #source_code_link("/AGENTS.md") file serves as a centralized repository of project-specific rules, ensuring consistent adherence to the technology stack, frontend architecture, styling conventions, testing requirements, and security protocols. This approach ensures that AI-generated suggestions follow the same rigorous standards as human code reviews.

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
Since the exact same processes are used for both code and thesis writing, AI was utilized in a similar manner for thesis documentation. Within the existing agent configuration, a dedicated academic writing context switch was incorporated to focus on academic writing style and proper citations. It was used to *suggest improvements* to phrasing, grammar, and structure of the thesis content, as well as to identify potential inconsistencies.

Additionally, AI was employed to generate initial drafts of certain sections, help with brainstorming, and aid in choosing relevant code examples from the project's codebase.

=== Ethical Considerations
The integration of AI into research, development, and academic writing requires strict ethical boundaries to maintain integrity. As a tool, AI was applied under the principle of mandatory human oversight, ensuring that all machine-generated outputs were verified, critiqued, and approved by the authors.

*Research Integrity:* In the context of research, findings derived from AI-assisted exploration were manually corroborated with primary sources to prevent reliance on hallucinations or biased data. AI served strictly as an accelerator for discovery, not a substitute for verification.

*Development Security:* For software development, use of the AI code review agent was governed by explicit guidelines prioritizing security and maintainability. Suggestions were treated as preliminary, requiring human validation to ensure no vulnerabilities or unintended biases were introduced into the codebase.

*Academic Authorship:* Regarding thesis writing, AI functioned solely as an assistive drafting aid. The responsibility for the document's structure, argumentation, and final prose remains entirely with the human authors.

Overall, these principles ensure that AI applications maintain essential human oversight, preventing over-reliance on automated systems and preserving the integrity of critical thinking and originality in both academic research and professional development.

Transparency is maintained by properly citing the methodologies and tools used, aligning with emerging academic standards for AI usage.

=== Impact and Limitations

*Impact Assessment:*
The integration of AI significantly enhanced the efficiency of the development cycle. Automated code reviews reduced the time spent on syntax and style verification, allowing human reviewers to focus on architectural logic and business requirements. In thesis writing, AI assistance accelerated the drafting of technical descriptions and improved the linguistic quality of the text, ensuring a consistent formal tone throughout the document.

*Limitations:*
Despite these benefits, AI tools demonstrated limitations, particularly in understanding complex, multi-file dependencies and specific business domain nuances. Contextual hallucinations were occasionally observed during research tasks. These limitations were mitigated by the strict human-in-the-loop policy and the use of the `AGENTS.md` context file, which provided the AI with necessary boundaries and project-specific knowledge.
