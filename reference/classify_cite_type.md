# Map a raw CS1 type keyword to a display category

Converts the keyword returned by
[`parse_cite_type`](https://jsobel1.github.io/wikilite/reference/parse_cite_type.md)
(e.g. `"journal"`, `"arxiv"`) to a human-readable display category
aligned with the Wikipedia Citation Style 1/2 template taxonomy.

## Usage

``` r
classify_cite_type(raw_type)
```

## Arguments

- raw_type:

  Character string — the lowercase keyword produced by
  [`parse_cite_type()`](https://jsobel1.github.io/wikilite/reference/parse_cite_type.md).

## Value

One of `"Journal"`, `"Book"`, `"Web"`, `"News/Magazine"`, `"Preprint"`,
`"Thesis"`, `"Conference"`, `"Report"`, `"Multimedia"`,
`"Legal/Patent"`, `"Social Media"`, or `"Other"`.

## Examples

``` r
classify_cite_type("journal")   # "Journal"
classify_cite_type("arxiv")     # "Preprint"
classify_cite_type("book")      # "Book"
```
