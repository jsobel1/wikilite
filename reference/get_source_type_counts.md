# Count citations by CS1 source type

Count citations by CS1 source type

## Usage

``` r
get_source_type_counts(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

A data frame with columns `cite_type` and `Freq`, or `NA` if no
citations are found.

## Examples

``` r
if (FALSE) { # \dontrun{
art <- get_article_most_recent_table("Zeitgeber")
get_source_type_counts(art$`*`)
} # }
```
