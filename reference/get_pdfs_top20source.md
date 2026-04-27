# Plot bar charts of the top 20 values for all citation source types

Calls
[`plot_top_source`](https://jsobel1.github.io/wikilite/reference/plot_top_source.md)
for every type listed in `source_types_list`.

## Usage

``` r
get_pdfs_top20source(
  df_cite_parsed_revid_art,
  source_types_list = c("publisher", "journal", "author", "website", "newspaper")
)
```

## Arguments

- df_cite_parsed_revid_art:

  Parsed citation data frame as returned by
  [`get_parsed_citations`](https://jsobel1.github.io/wikilite/reference/get_parsed_citations.md).

- source_types_list:

  Character vector of citation field names to summarise (default:
  `c("publisher", "journal", "author", "website", "newspaper")`).

## Value

Invisibly returns `NULL`.

## Examples

``` r
if (FALSE) { # \dontrun{
recent <- get_article_most_recent_table("Zeitgeber")
df     <- get_parsed_citations(recent)
get_pdfs_top20source(df)
} # }
```
