# Parse all Citation Style 1 templates in a wikitext string

Extracts every CS1 citation, replaces hyperlinks, and returns a tidy
long data frame where each row is one field of one citation.

## Usage

``` r
parse_article_ALL_citations(art_text, article_name = NULL)
```

## Arguments

- art_text:

  Character string of raw wikitext.

- article_name:

  Optional source-article title. When supplied (non-NULL), the returned
  data frame gains an `art` column populated with this value, preserving
  provenance through downstream pivots, joins, and exports. Defaults to
  `NULL` for backward compatibility.

## Value

A data frame with columns `type`, `id_cite`, `variable`, and `value` —
plus `art` when `article_name` is supplied.

## Examples

``` r
# \donttest{
art <- get_article_most_recent_table("Zeitgeber")
parse_article_ALL_citations(art$`*`, article_name = "Zeitgeber")
# }
```
