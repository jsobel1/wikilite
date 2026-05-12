# Retrieve the names of pages belonging to a Wikipedia category

Wraps
[`WikipediR::pages_in_category`](https://rdrr.io/pkg/WikipediR/man/pages_in_category.html)
and filters out user and category pages.

## Usage

``` r
get_pagename_in_cat(category, lang = "en")
```

## Arguments

- category:

  Character string — Wikipedia category name (e.g.
  `"Circadian rhythm"`).

- lang:

  Two-letter language code (default: `"en"`).

## Value

Character vector of article titles, or `NULL` on error.

## Examples

``` r
# \donttest{
get_pagename_in_cat("Circadian rhythm")
get_pagename_in_cat("Rythme_circadien", lang = "fr")
# }
```
