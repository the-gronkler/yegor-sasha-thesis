
/// The main project template for the thesis.
///
/// - title: The title of the thesis.
/// - authors: An array of author dictionaries (name, index).
/// - supervisor: The name of the supervisor.
/// - aux_supervisor: The name of the auxiliary supervisor (optional).
/// - date: The submission date and location. like "Warsaw, February 2025".
/// - logo: The path to the university logo
/// - faculty: The faculty name.
/// - department: The department name.
/// - specialization: The specialization/major.
/// - abstract: The content of the abstract.
/// - acknowledgements: Here include your thanks to people who helped you in the journey of implementing and preparing this thesis.
/// - keywords: Keywords can be both single- or multiple-word phrases. At least 3 keywords are necessary. Treat them as tags. Your thesis must be searchable using them.
/// - body: The main content of the thesis.
#let project(
  title: "",
  authors: (),
  supervisor: "",
  aux_supervisor: "",
  date: "",
  logo: none,
  faculty: "",
  department: "",
  specialization: "",
  abstract: [],
  acknowledgements: [],
  keywords: (),
  body,
) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set page(
    paper: "a4",
    margin: 2cm,
    numbering: "1",
    number-align: right,
  )
  // Use a modern, professional sans-serif font for the whole document
  set text(font: ("Segoe UI", "Arial", "Calibri"), lang: "en", size: 12pt)

  // Title page.
  page(
    margin: (top: 2.54cm, bottom: 2.54cm, x: 4.445cm),
    numbering: none,
  )[
    #set align(center)

    #if logo != none {
      image(logo, width: 100%)
    } else {
      v(2cm)
      text(size: 2em, weight: "bold")[PJAIT]
    }

    #v(2cm)

    #text(weight: "bold")[#faculty]

    #v(1cm)

    #text(weight: "bold")[#department] \
    #specialization

    #v(1cm)

    #text(size: 1.2em)[Authors]
    #v(0.5em)
    #authors.map(a => a.name + ", " + a.index).join("\n")

    #v(1cm)

    #text(size: 2em, weight: "bold")[#title]

    #v(1fr)

    #align(right)[
      #block(width: 60%)[
        #set align(left)
        Bachelor's degree thesis written under the supervision of: \
        #v(0.5em)
        #text(weight: "bold")[#supervisor] \
        #aux_supervisor
      ]
    ]

    #v(1fr)

    #date
  ]

  // Abstract
  if abstract != [] {
    page(numbering: none)[
      #v(1fr)
      #align(center)[#heading(outlined: false)[Abstract]]
      #abstract
      #if keywords.len() > 0 [
        #v(1em)
        *Keywords:* #keywords.join([ $dot$ ])
      ]
      #v(1fr)
    ]
  }

  // Acknowledgements
  if acknowledgements != [] {
    page(numbering: none)[
      #v(1fr)
      #align(center)[#heading(outlined: false)[Acknowledgements]]
      #acknowledgements
      #v(1fr)
    ]
  }

  // Table of contents.
  outline(depth: 3, indent: auto)
  pagebreak()

  // Main body.
  set par(justify: true, leading: 0.8em, spacing: 1.2em)

  // Headings
  set heading(numbering: "1.1")
  show heading: set block(above: 2em, below: 1em)

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  // Links
  show link: set text(fill: rgb("#005580"))

  // Code blocks
  show raw.where(block: true): it => {
    set text(size: 0.9em)

    // Enable line numbering
    show raw.line: l => {
      box(stack(
        dir: ltr,
        spacing: 1em,
        text(fill: luma(150), str(l.number)),
        l.body,
      ))
    }

    block(
      fill: rgb("#f5f7f9"),
      inset: 12pt,
      radius: 5pt,
      stroke: rgb("#e0e0e0"),
      width: 100%,
      align(left, it),
    )
  }

  body
}
