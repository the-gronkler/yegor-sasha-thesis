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
  supervisor: "Krzysztof Bajszczak, Mgr Inż.",
  aux_supervisor: "Name of your auxiliary supervisor",
  date: "Warsaw, February 2025",
  logo: "resources/logo.png",
  faculty: "Faculty of Information Technology",
  department: "Department of ??",
  specialization: "Software and Database Engineering",
  //   abstract: include "pre-content/abstract.typ",
  //   acknowledgements: include "pre-content/acknowledgements.typ",
  abstract: include "examples/abstract-example.typ",
  acknowledgements: include "examples/acknowledgements-example.typ",
  keywords: ("Keyword 1", "Keyword 2", "Keyword 3"),
)

// Main content of the thesis:
#include "examples/content-example.typ"

// Project overview:
#include "chapters/glossary.typ"
#include "chapters/introduction.typ"
#include "chapters/aims-and-objectives.typ"
#include "chapters/context.typ"
#include "chapters/functional-requirements.typ"
// Use Case Diagram
// Use Case Scenarios
#include "chapters/non-functional-requirements.typ"

// Technical chapters:
#include "chapters/technologies.typ"  //Technologies used (for the app, not in development process)
#include "chapters/system-architecture.typ"
#include "chapters/database-design.typ"
#include "chapters/implementation.typ"
#include "chapters/development-process/main.typ"
#include "chapters/testing-and-validation.typ"

// Final chapters:
#include "chapters/conclusions-and-future-work.typ"





#bibliography("resources/references.bib", style: "ieee")
