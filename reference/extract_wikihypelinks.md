# Extract Wikipedia hyperlinks from wikitext

Extract Wikipedia hyperlinks from wikitext

## Usage

``` r
extract_wikihypelinks(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

Character vector of matched `[[...]]`-style links.

## Examples

``` r
extract_wikihypelinks("See [[Zeitgeber|the article]] and [[Sleep]].")
```
