# Count citations by CS1 source type

Count citations by CS1 source type

## Usage

``` r
get_source_type_counts(art_text, article_name = NULL)
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

A data frame with columns `cite_type` and `Freq` — plus `art` when
`article_name` is supplied — or `NA` if no citations are found.

## Examples

``` r
# \donttest{
art <- get_article_most_recent_table("Zeitgeber")
get_source_type_counts(art$`*`, article_name = "Zeitgeber")
# }
```
