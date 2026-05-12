# Identify the most-cited DOIs across a set of Wikipedia articles

Finds the 40 most frequently cited DOIs, annotates them via EuropePMC
and CrossRef, and adds per-article citation counts.

## Usage

``` r
get_top_cited_wiki_papers(df_doi_revid_art)
```

## Arguments

- df_doi_revid_art:

  Data frame of DOI matches as returned by
  [`get_regex_citations_in_wiki_table`](https://jsobel1.github.io/wikilite/reference/get_regex_citations_in_wiki_table.md)
  with the DOI regexp.

## Value

A data frame of the top cited DOIs with bibliographic annotations and
Wikipedia citation counts.

## Examples

``` r
# \donttest{
doi_df <- get_regex_citations_in_wiki_table(
  get_article_most_recent_table("Zeitgeber"),
  "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+"
)
get_top_cited_wiki_papers(doi_df)
# }
```
