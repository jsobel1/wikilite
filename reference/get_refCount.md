# Count `<ref>` tags in wikitext

Count `<ref>` tags in wikitext

## Usage

``` r
get_refCount(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

Integer count of reference tags.

## Examples

``` r
get_refCount("<ref>one</ref> text <ref name='r2'>two</ref>")
#> [1] 2
```
