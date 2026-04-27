# Compute SciScore2 for a Wikipedia article

SciScore2 is the ratio of DOIs to `<ref>` tags in the article. A ratio
close to 1 indicates that most references include a DOI (likely
peer-reviewed sources).

## Usage

``` r
get_sci_score2(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

Numeric value, or `NA` when there are no reference tags.

## Examples

``` r
if (FALSE) { # \dontrun{
art <- get_article_most_recent_table("Zeitgeber")
get_sci_score2(art$`*`)
} # }
```
