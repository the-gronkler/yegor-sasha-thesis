#import "template.typ": *

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
  abstract: include "pre-content/abstract.typ",
  acknowledgements: include "pre-content/acknowledgements.typ",
)

#bibliography("resources/references.bib", style: "ieee")

#include "chapters/introduction.typ"
#include "chapters/content.typ"
