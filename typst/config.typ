#let code_ref = "master"
#let repo_base = "https://github.com/the-gronkler/yegor-sasha-thesis/"
#let repo_ref = repo_base + "blob/" + code_ref

#let _source_code_cited = state("source-code-cited", false)

#let source_code_link(file_path) = {
  let path = if file_path.starts-with("/") { file_path } else { "/" + file_path }
  context {
    if _source_code_cited.get() {
      [#link(repo_ref + path)[#raw(path.split("/").last())]]
    } else {
      _source_code_cited.update(true)
      [#link(repo_ref + path)[#raw(path.split("/").last())] @SourceCodeRepo]
    }
  }
}

// Creates an unbreakable block to keep paragraphs and code examples together on the same page
// This prevents awkward page breaks between explanatory text and its associated code blocks
// Usage: #code_example[ Your paragraph here ```code``` ]
#let code_example(content) = block(breakable: false, content)
