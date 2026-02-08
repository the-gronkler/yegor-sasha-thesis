
#import "../../config.typ": source_code_link

== AI Use

=== AI in Research
AI assisted the initial research phase by accelerating the exploration of existing solutions, feature brainstorming, scope definition, and workload estimation. All findings were manually verified and appropriately cited.

=== AI in Development
During the development phase, AI tools were utilized to augment manual code reviews. The AI analyzed changes against the project's strict architecture and styling guidelines. It helped identify potential regressions, suggest optimizations, and ensure adherence to the defined coding standards before human review.

To facilitate this, a custom context configuration was established in #source_code_link("/AGENTS.md"), enabling the AI to act as a specialized reviewer aware of the project's specific constraints.

==== Agent Instructions (AGENTS.md)
The #source_code_link("/AGENTS.md") file serves as a centralized repository of project-specific rules following the `AGENTS.md` open format @AgentsMDFormat, which provides a dedicated location for project context and coding agent instructions. This approach aligns with GitHub Copilot's system, where the closest instruction file in the directory structure takes priority @GitHubCopilotRepoInstructions, and ensures that AI-generated suggestions follow the same rigorous standards as human code reviews.

=== Ethical Considerations
The integration of AI into research and development requires strict ethical boundaries to maintain integrity. In the context of research, findings derived from AI-assisted exploration were manually corroborated with primary sources to prevent reliance on hallucinations or biased data. For software development, AI suggestions were treated as preliminary, requiring human validation to ensure no vulnerabilities or unintended biases were introduced into the codebase. Transparency is maintained by properly citing the methodologies and tools used, aligning with emerging academic standards for AI usage.

=== Impact and Limitations

The integration of AI enhanced development efficiency by automating syntax and style verification, allowing human reviewers to focus on architectural logic and business requirements. However, AI tools demonstrated limitations in understanding complex multi-file dependencies and domain-specific nuances, with occasional contextual hallucinations during research tasks. These limitations were mitigated by the strict human-in-the-loop policy and the `AGENTS.md` context file, which provided necessary boundaries and project-specific knowledge.
