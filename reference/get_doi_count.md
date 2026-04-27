# Count DOIs in wikitext

Count DOIs in wikitext

## Usage

``` r
get_doi_count(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

Integer count of matched DOIs.

## Examples

``` r
get_doi_count("See 10.1038/nature12373 and 10.1016/j.cell.2020.01.001.")
#> [1] 2
```
