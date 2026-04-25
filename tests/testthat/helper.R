# Shared test helpers for wikilite

#' Build a minimal fake revision data frame (no network required)
#'
#' @param text Optional wikitext string.  When \code{NULL} a canonical
#'   fixture with DOIs, ISBNs, URLs, hyperlinks, refs, and CS1 templates
#'   is used.
#' @return A one-row data frame matching the structure returned by
#'   \code{get_article_most_recent_table()}.
#' @noRd
make_fake_table <- function(text = NULL) {
  if (is.null(text)) {
    text <- paste(
      "== Section ==",
      "Some text with a DOI: 10.1038/nature12373.",
      "Also ISBN 978-0-06-112008-4 and PMID 12345678.",
      "A URL: https://example.com and [[Hyperlink|label]].",
      "{{cite journal | author = Smith | year = 2020 | doi = 10.1038/test }}",
      "{{cite web | url = https://example.com | title = Example }}",
      "{{cite book | author = Jones | year = 2019 | isbn = 978-0-06-112008-4 }}",
      "<ref>some reference</ref>",
      "<ref name='r2'>another reference</ref>",
      sep = "\n"
    )
  }
  data.frame(
    art       = "Zeitgeber",
    revid     = 12345L,
    parentid  = 12344L,
    user      = "TestUser",
    userid    = 1L,
    timestamp = "2021-01-01T00:00:00Z",
    size      = nchar(text),
    comment   = "test edit",
    `*`       = text,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}
