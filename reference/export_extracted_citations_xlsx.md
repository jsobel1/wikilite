# Export all built-in regex matches to separate xlsx files

Applies every regular expression in
[`pkg.env`](https://jsobel1.github.io/wikilite/reference/pkg.env.md)`$regexp_list`
to `article_most_recent_table` and saves the results as individual
`.xlsx` files in the working directory.

## Usage

``` r
export_extracted_citations_xlsx(article_most_recent_table, name_file_prefix)
```

## Arguments

- article_most_recent_table:

  A Wikipedia revision data frame (e.g. from
  [`get_category_articles_most_recent`](https://jsobel1.github.io/wikilite/reference/get_category_articles_most_recent.md)).

- name_file_prefix:

  Character prefix used for all output file names.

## Value

Invisibly returns `NULL`. Called for its side effect of writing files.

## Examples

``` r
if (FALSE) { # \dontrun{
category_most_recent <- get_category_articles_most_recent(
  c("Zeitgeber", "Advanced sleep phase disorder")
)
export_extracted_citations_xlsx(category_most_recent, "sleep_articles")
} # }
```
