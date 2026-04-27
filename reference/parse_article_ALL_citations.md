# Parse all Citation Style 1 templates in a wikitext string

Extracts every CS1 citation, replaces hyperlinks, and returns a tidy
long data frame where each row is one field of one citation.

## Usage

``` r
parse_article_ALL_citations(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

A data frame with columns `type`, `id_cite`, `variable`, and `value`.

## Examples

``` r
if (FALSE) { # \dontrun{
art <- get_article_most_recent_table("Zeitgeber")
parse_article_ALL_citations(art$`*`)
} # }
```
