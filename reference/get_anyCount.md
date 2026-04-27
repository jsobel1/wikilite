# Count matches of an arbitrary regular expression in wikitext

Count matches of an arbitrary regular expression in wikitext

## Usage

``` r
get_anyCount(art_text, regexp)
```

## Arguments

- art_text:

  Character string of raw wikitext.

- regexp:

  A regular expression string.

## Value

Integer count of matches.

## Examples

``` r
get_anyCount("foo bar baz foo", "foo")
#> [1] 2
```
