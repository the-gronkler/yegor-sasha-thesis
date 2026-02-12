= Division of Work

This section outlines the distribution of responsibilities between the two authors throughout the development of the restaurant management system and its accompanying documentation.

The project was developed collaboratively from its inception. While individual features were typically _led_ by one author, every change was subject to mandatory code review through pull requests before merging, ensuring that both authors maintained awareness of and influence over the entire codebase. Additionally, features led by one author were often adjusted by the other. The subsections below describe the primary areas of focus for each author.

== Application Development

*Yegor Burykin* established the frontend foundation, configuring the build tooling and single-page application framework, and created the initial route structure, controllers, and authentication pages.

A primary area of focus was the map-based restaurant discovery system, including geolocation services, a composite scoring algorithm, marker clustering, search-in-area functionality, and a density-based heatmap visualization for restaurant distribution and quality.

Additional features led by Yegor Burykin included the shopping cart system, the restaurant favorites system with drag-and-drop reordering, the authentication and registration flows, the menu item detail view, the toast notification component, the customer profile page, the restaurant index with search functionality, and the employee-side establishment management and menu category interfaces.

Database seeding infrastructure was also a primary responsibility, with extensive work on factories and seeders to provide realistic test data.

*Oleksandr Svirin* created the initial backend project scaffold, designed the database schema, and defined the data models with their relationships and authorization policies.

A primary area of focus was the real-time broadcasting system, enabling live order and menu updates via WebSocket channels.

Additional features led by Oleksandr Svirin included the checkout and order processing pipeline, the review system with image uploads and cloud-based media storage, the restaurant detail page, the reusable search component, and the customer layout.

TypeScript configuration and frontend architecture conventions were established and documented. Deployment and continuous integration infrastructure, including containerization, web server configuration, and automated deployment workflows, was primarily created. Developer tooling such as code formatting, pre-commit hooks, and editor configurations was also established.

*Shared Responsibilities*: Both authors contributed equally to the employee-side management interface, restaurant listing and detail pages, application styling, and the API routing structure.

== Thesis Manuscript

The thesis was jointly developed using Typst with Git-based version control.

The introduction, aims and objectives, context, functional requirements, non-functional requirements, and glossary chapters were developed through close collaboration between both authors, with neither taking a singular lead.

*Oleksandr Svirin* focused on sections covering the development process chapter, as well as complete coverage (technology choices, architecture, and implementation) for database and ORM, real-time broadcasting, and media storage. For the frontend, he authored the architecture and implementation sections. He also initialized the Typst project structure and performed cross-cutting editorial work including citations and length reduction.

*Yegor Burykin* focused on sections providing complete coverage (technology choices, architecture, and implementation) for the map-based discovery system. He also authored backend architecture and technology choices, the technology descriptions for Inertia.js and React, and the use case diagrams and scenarios. He performed a dedicated inconsistency review pass across the document.

Several additional sections, particularly within the Technologies and System Architecture chapters, received meaningful contributions from both authors.


== Summary

In summary, Oleksandr Svirin focused on backend architecture, real-time features, deployment infrastructure, and thesis sections on frontend implementation, the development process, and database design.

Yegor Burykin focused on the frontend scaffold, the map and geolocation subsystem, the shopping cart, authentication, data population, and thesis sections on map architecture, backend technologies, and use cases.

The collaboration was balanced, with each author taking ownership of distinct feature areas while contributing to overlapping domains.


The complete commit history of the project, demonstrating the detailed breakdown of individual contributions, is available in the project repository@SourceCodeRepo. It is important to note that commit history and authorship alone does not fully capture the collaborative nature of the project, as line count doesn't reflect the complexity or significance of contributions, and many changes were made collaboratively through code reviews and pair programming sessions.
