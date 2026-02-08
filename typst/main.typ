#import "template.typ": *
#import "config.typ": *

// TODO: replace example content with our own thesis content

// Project settings, title page and other pre-content.
#show: project.with(
  title: "Your thesis title",
  authors: (
    (name: "Oleksandr Svirin", index: "s28259"),
    (name: "Yegor Burykin", index: "s26904"),
  ),
  supervisor: "Krzysztof Bajszczak, M. Eng.",
  aux_supervisor: "Piotr Gago, M. Eng.",
  date: "Warsaw, February 2025",
  logo: "resources/logo.png",
  faculty: "Faculty of Information Technology",
  department: "Department of Databases",
  specialization: "Software and Database Engineering",
  abstract: include "examples/abstract-example.typ",
  acknowledgements: include "examples/acknowledgements-example.typ",
  keywords: (
    "Restaurant Management System",
    "Online Food Ordering",
    "Real-time Order Tracking",
    "Geolocation Services",
    "Single Page Application (SPA)",
    "Laravel",
    "React",
    "Inertia.js",
    "Full-stack Development",
    "SME Digitalization",
  ),
)

// Main content of the thesis:
// #include "examples/content-example.typ"

// Project overview:
#include "chapters/glossary.typ"
#include "chapters/introduction.typ"
#include "chapters/aims-and-objectives.typ"
#include "chapters/context.typ"
#include "chapters/functional-requirements.typ"
#include "chapters/use-case-diagram.typ"
#include "chapters/use-case-scenarios.typ"
#include "chapters/non-functional-requirements.typ"
// Security
// Backlog issues left (very optional)

// Technical chapters:
#include "chapters/technologies/technologies.typ"  //Technologies used (for the app, not in development process)

#include "chapters/development-process/development-process-main.typ"
#include "chapters/database-design.typ"
#include "chapters/system-architecture/system-architecture.typ"

#include "chapters/implementation/implementation-main.typ"
#include "chapters/testing-and-validation.typ"

// Final chapters:
#include "chapters/conclusions-and-future-work.typ"





#bibliography("resources/references.bib", style: "ieee")
