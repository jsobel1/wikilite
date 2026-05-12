# Retrieve the full revision history of a Wikipedia article

Queries the Wikipedia MediaWiki API and returns a data frame where each
row is one revision of the given article, ordered chronologically.

## Usage

``` r
get_article_full_history_table(
  article_name,
  date_an = NULL,
  lang = "en",
  use_cache = TRUE
)
```

## Arguments

- article_name:

  Character string giving the Wikipedia article title (e.g.
  `"Zeitgeber"`).

- date_an:

  Character string — upper date limit for revisions in ISO 8601 format.
  Default: current UTC time.

- lang:

  Two-letter language code for the Wikipedia edition to query (default:
  `"en"` for English).

- use_cache:

  Logical. When `TRUE` (default), results are cached to disk and reused
  on repeated calls with the same arguments.

## Value

A data frame with columns `art`, `revid`, `parentid`, `user`, `userid`,
`timestamp`, `size`, `comment`, and `*` (raw wikitext).

## Examples

``` r
# \donttest{
zeitgeber_history <- get_article_full_history_table("Zeitgeber")
french_history    <- get_article_full_history_table("COVID-19", lang = "fr")
# }
```
