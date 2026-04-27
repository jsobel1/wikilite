# Extract all Citation Style 1 templates from wikitext

Extract all Citation Style 1 templates from wikitext

## Usage

``` r
extract_citations(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

Character vector of matched CS1 templates.

## Examples

``` r
if (FALSE) { # \dontrun{
art <- get_article_most_recent_table("Zeitgeber")
extract_citations(art$`*`)
} # }
```
