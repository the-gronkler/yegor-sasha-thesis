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

== AI Usage

=== AI in Research
AI was utilized for initial research into the solution, with all findings confirmed manually and properly cited.

=== AI in Development
During development, AI was employed primarily for code review, as it can identify common mistakes and suggest improvements.

To this end, a custom AI code review agent was developed, with guidelines detailed in the project's agent configuration file, #source_code_link("/AGENTS.md").

// What is AGENTS.md? cite sources, how it works, best practices, etc...

=== AI in Thesis Writing
Since the exact same processes are used for both code and thesis writing, AI was utilized in a similar manner for thesis documentation. An additional academic writing agent was created to assist with this, incorporating a context switch to focus on academic writing style and proper citations. It was used to *suggest improvements* to phrasing, grammar, and structure of the thesis content, as well as to identify potential inconsistencies.

AI was also employed for initial drafts of some sections, brainstorming, and code snippets.

=== Ethical Considerations
The use of AI in research, development, and academic writing raises several ethical considerations that must be addressed to maintain integrity and transparency. As AI is a tool, its application was guided by principles of academic honesty, ensuring that any and all AI-generated content was reviewed, verified, and augmented by human expertise. Findings from AI-assisted research were manually confirmed to avoid reliance on potentially biased or inaccurate outputs. In development, the custom AI code review agent was designed with ethical guidelines in mind, focusing on error detection without compromising code quality or introducing unintended biases. For thesis writing, AI was employed solely as an assistive tool for drafting and improvement suggestions, with all final content authored and approved by human contributors. Proper citation of AI tools and methodologies was maintained throughout, adhering to emerging standards for AI transparency in academia. This approach underscores the importance of human oversight in AI applications, preventing over-reliance and ensuring that AI _enhances_ rather than replaces critical thinking and originality.
\



