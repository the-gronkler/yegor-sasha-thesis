#import "template.typ": *

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
  
// Main content of the thesis.
#include "examples/content-example.typ"

// #include "chapters/glossary.typ"
// #include "chapters/introduction.typ"
// #include "chapters/context.typ"
// #include "chapters/functional-requirements.typ"
// #include "chapters/non-functional-requirements.typ"

#bibliography("resources/references.bib", style: "ieee")
