# Count Wikipedia hyperlinks in wikitext

Count Wikipedia hyperlinks in wikitext

## Usage

``` r
get_hyperlinkCount(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

Integer count of `[[...]]`-style links.

## Examples

``` r
get_hyperlinkCount("[[Article one]] and [[Article two|display]]")
#> [1] 2
```
