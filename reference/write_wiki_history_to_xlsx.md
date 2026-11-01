# Write an article revision table to an xlsx file

Writes a Wikipedia revision table (as returned by
[`get_article_full_history_table`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md)
or similar functions) to an Excel file.

## Usage

``` r
write_wiki_history_to_xlsx(wiki_hist, file_name, dir = NULL)
```

## Arguments

- wiki_hist:

  A data frame of Wikipedia revisions with at least the columns `art`,
  `revid`, `parentid`, `user`, `userid`, `timestamp`, `size`, `comment`,
  and `*` (raw wikitext).

- file_name:

  Path prefix for the output file (no default). The file will be saved
  as `<file_name>_wiki_table.xlsx`.

- dir:

  Optional directory path. When non-`NULL`, `file_name` is interpreted
  as a base name and the file is written inside `dir`.

## Value

Invisibly returns `NULL`. Called for its side effect of writing a file.

## Examples

``` r
# \donttest{
tmpwikitable <- get_article_initial_table("Zeitgeber")
write_wiki_history_to_xlsx(tmpwikitable, "Zeitgeber", dir = tempdir())
# }
```
