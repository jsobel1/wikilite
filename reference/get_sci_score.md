# Compute SciScore for a Wikipedia article

SciScore is the proportion of CS1-template citations that are journal
citations (`cite journal`). A score of 1 means all citations are to
peer-reviewed journals; 0 means none are.

## Usage

``` r
get_sci_score(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

Numeric value between 0 and 1, or `0` if there are no citations.

## Examples

``` r
# \donttest{
art <- get_article_most_recent_table("Zeitgeber")
get_sci_score(art$`*`)
# }
```
