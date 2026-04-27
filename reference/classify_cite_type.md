# Map a raw CS1 cite type to a display category

Converts a raw Citation Style 1 template keyword into one of twelve
human-readable display categories used by
[`get_citation_type`](https://jsobel1.github.io/wikilite/reference/get_citation_type.md)
and the pkgdown site.

## Usage

``` r
classify_cite_type(raw_type)
```

## Arguments

- raw_type:

  Character string — the lowercase keyword produced by
  [`parse_cite_type`](https://jsobel1.github.io/wikilite/reference/parse_cite_type.md),
  e.g. `"journal"`, `"arxiv"`.

## Value

One of `"Journal"`, `"Book"`, `"Web"`, `"News/Magazine"`, `"Preprint"`,
`"Thesis"`, `"Conference"`, `"Report"`, `"Multimedia"`,
`"Legal/Patent"`, `"Social Media"`, or `"Other"`. The function is
case-insensitive and trims leading/trailing whitespace.

## Examples

``` r
classify_cite_type("journal")    # "Journal"
#> [1] "Journal"
classify_cite_type("arxiv")      # "Preprint"
#> [1] "Preprint"
classify_cite_type("book")       # "Book"
#> [1] "Book"
classify_cite_type("JOURNAL")    # "Journal"  (case-insensitive)
#> [1] "Journal"
classify_cite_type("unknown_xyz") # "Other"
#> [1] "Other"
```
