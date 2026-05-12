# Export all built-in regex matches to separate xlsx files

Applies every regular expression in
[`pkg.env`](https://jsobel1.github.io/wikilite/reference/pkg.env.md)`$regexp_list`
to `article_most_recent_table` and saves the results as individual
`.xlsx` files.

## Usage

``` r
export_extracted_citations_xlsx(article_most_recent_table, name_file_prefix)
```

## Arguments

- article_most_recent_table:

  A Wikipedia revision data frame (e.g. from
  [`get_category_articles_most_recent`](https://jsobel1.github.io/wikilite/reference/get_category_articles_most_recent.md)).

- name_file_prefix:

  Full path prefix used for all output file names. Each file is named
  `<name_file_prefix>_<regexp>_extracted_citations.xlsx`. If only a base
  name is given (no directory), files are written to the current working
  directory (see [`getwd()`](https://rdrr.io/r/base/getwd.html)).

## Value

Invisibly returns `NULL`. Called for its side effect of writing files.

## Examples

``` r
# \donttest{
category_most_recent <- get_category_articles_most_recent(
  c("Zeitgeber", "Advanced sleep phase disorder")
)
export_extracted_citations_xlsx(
  category_most_recent,
  file.path(tempdir(), "sleep_articles")
)
# }
```
