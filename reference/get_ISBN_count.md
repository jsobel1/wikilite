# Count ISBNs in wikitext

Count ISBNs in wikitext

## Usage

``` r
get_ISBN_count(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

Integer count of matched ISBNs.

## Examples

``` r
get_ISBN_count("Book isbn=978-0-06-112008-4")
#> [1] 2
```
