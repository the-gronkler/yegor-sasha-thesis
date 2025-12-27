
#let project(
  title: "",
  authors: (),
  supervisor: "",
  aux_supervisor: "",
  date: "",
  logo: none,
  abstract: [],
  acknowledgements: [],
  body,
) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set page(
    paper: "a4",
    numbering: "1",
    number-align: right,
  )
  // Use a modern, professional sans-serif font for the whole document
  set text(font: ("Segoe UI", "Roboto", "Helvetica Neue", "Arial", "sans-serif"), lang: "en", size: 11pt)

  // Title page.
  page(
    margin: (top: 2.54cm, bottom: 2.54cm, x: 4.445cm),
    numbering: none,
  )[
    #set align(center)

    #if logo != none {
      // Note: Typst supports PNG, JPEG, GIF, SVG. PDF images are not supported directly.
      image(logo, width: 100%)
    } else {
      v(2cm)
      text(size: 2em, weight: "bold")[PJAIT]
    }

    #v(2cm)

    #text(weight: "bold")[Faculty of Information Technology]

    #v(1cm)

    #text(weight: "bold")[Department of Software Engineering] \
    Software and Database Engineering

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
  set par(justify: true, leading: 0.8em)
  show par: set block(spacing: 1.2em)

  // Headings
  set heading(numbering: "1.1")
  show heading: set block(above: 2em, below: 1em)

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  body
}
