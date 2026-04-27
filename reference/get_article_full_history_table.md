# Retrieve the full revision history of a Wikipedia article

Queries the English Wikipedia MediaWiki API and returns a data frame
where each row is one revision of the given article, ordered
chronologically.

## Usage

``` r
get_article_full_history_table(article_name, date_an = "2020-05-01T00:00:00Z")
```

## Arguments

- article_name:

  Character string giving the English Wikipedia article title (e.g.
  `"Zeitgeber"`).

- date_an:

  Character string — upper date limit for revisions in ISO 8601 format
  (default: `"2020-05-01T00:00:00Z"`).

## Value

A data frame with columns `art`, `revid`, `parentid`, `user`, `userid`,
`timestamp`, `size`, `comment`, and `*` (raw wikitext).

## Examples

``` r
if (FALSE) { # \dontrun{
zeitgeber_history <- get_article_full_history_table("Zeitgeber")
} # }
```
