# Retrieve the names of pages belonging to a Wikipedia category

Wraps
[`WikipediR::pages_in_category`](https://rdrr.io/pkg/WikipediR/man/pages_in_category.html)
and filters out user and category pages.

## Usage

``` r
get_pagename_in_cat(category)
```

## Arguments

- category:

  Character string — Wikipedia category name (e.g.
  `"Circadian rhythm"`).

## Value

Character vector of article titles, or `NULL` on error.

## Examples

``` r
if (FALSE) { # \dontrun{
get_pagename_in_cat("Circadian rhythm")
# Multiple categories:
unique(unlist(sapply(c("Circadian rhythm", "Sleep"), get_pagename_in_cat)))
} # }
```
