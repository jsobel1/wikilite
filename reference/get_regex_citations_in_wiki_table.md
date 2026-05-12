# Extract regex matches from a Wikipedia revision table

Applies `citation_regexp` to the wikitext column (`*`) of
`article_wiki_table` and returns a tidy data frame mapping each revision
to its matched strings.

## Usage

``` r
get_regex_citations_in_wiki_table(article_wiki_table, citation_regexp)
```

## Arguments

- article_wiki_table:

  A data frame of Wikipedia revisions with columns `art`, `revid`, and
  `*` (wikitext).

- citation_regexp:

  A regular expression string.

## Value

A data frame with columns `art`, `revid`, and `citation_fetched`.

## Details

Available built-in regular expressions are stored in
[`pkg.env`](https://jsobel1.github.io/wikilite/reference/pkg.env.md)`$regexp_list`.

## Examples

``` r
# \donttest{
history <- get_article_full_history_table("Zeitgeber")
dois    <- get_regex_citations_in_wiki_table(history,
             "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+")
# }
```
