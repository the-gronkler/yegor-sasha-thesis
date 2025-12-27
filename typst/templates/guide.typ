= Content

Be direct. The thesis should be _as short as possible, but not shorter than that_. Meaning that if you can be more concise without sacrificing readability or quality, you should be.

Here you should explain in detail the context of your work, state-of-the-art of similar tools, what is different about your approach, etc. If it gets lengthy, you can divide it into multiple chapters.

== How much to cite?

It is impossible to answer this question precisely. A rule of thumb presents itself as follows:

- Copy-pasting an entire page of academic work without any citations is a *crime* (copyright).
- Each important aspect of your work that is not directly created by you, should be backed by citations.
- In the section dedicated to alternative sources / state-of-the-art, it is permitted to introduce grouped citations, e.g., by introducing a short summary and them providing many references at the same time.
- It is permitted to omit the citation of Internet webpages if authors of referenced texts are unknown. In such situations you should reference the source broadly, e.g., "On IBM's website it can be seen that [...]."

Theses that were prepared and submitted without the supervisor's active overseeing of the process of creating it will be rejected.

== Definitions

If a given term requires elaborated definition, you should use the appropriate style for that. For example:

/ Free function: A *free function* is a function that is not a part of any class.

And:

/ Method: A *method* is a function that is s part of some class.

== How to structure my work?

It is best to split your chapters into separate files. Notice how this project consists of `contents` directory with `Introduction.tex` and `Content.tex` inside, which are then `\input{...}`-ed in the `main.tex` file. This makes it very easy to change the ordering, separate different topics and collaborate.

== How to introduce other media content?

Typst provides a wide array of options to deal with inputting things like:

- code listings
- figures (images and other non-splittable entities)
- tables
- equations

Let us inspect couple of examples for them:

=== Code listings

Use the raw block ` ```` ```lang ... ``` ```` ` to introduce code listings. Provide caption text to every non-inline listing.

For example:

#figure(
  caption: [Kotlin nullability handling example],
  ```kotlin
  fun main() {
      val text = getStringOrNull()

      println(text?.length ?: "nothing")
  }
  ```,
) <lst:kotlin>

#figure(
  caption: [Java nullability handling example],
  ```java
  public static void main(String[] args) {
      var text = getStringOrNull();

      System.out.println(text != null ? text.length() : "nothing");
  }
  ```,
) <lst:java>

You can now reference the code listings: @lst:kotlin and @lst:java.

=== Figures

To insert an image, place it in the `resources/images/` directory and use the `image` function inside a `figure`.

#figure(
  image("../resources/er-diagram.png", width: 100%),
  caption: [An example figure caption.],
) <fig:example>

Refer to the figure using @fig:example.
