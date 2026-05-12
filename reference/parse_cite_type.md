# Determine the type of a Citation Style 1 template

Extracts the citation type keyword (e.g. `"journal"`, `"book"`, `"web"`)
from a raw CS1 citation string.

## Usage

``` r
parse_cite_type(citation)
```

## Arguments

- citation:

  Character string containing a CS1 template.

## Value

Lowercase character string giving the citation type.

## Examples

``` r
parse_cite_type("{{cite journal | author = Smith | year = 2020 }}")
parse_cite_type("{{Cite book | title = My Book }}")
```
