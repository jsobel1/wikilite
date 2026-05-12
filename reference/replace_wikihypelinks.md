# Replace Wikipedia hyperlinks with plain text

Removes `[[...]]`-style wikitext markup, keeping the display text (the
part after `|`, if present) or the link target.

## Usage

``` r
replace_wikihypelinks(art_text)
```

## Arguments

- art_text:

  Character string of raw wikitext.

## Value

The input string with all hyperlinks replaced by plain text.

## Examples

``` r
replace_wikihypelinks("[[Zeitgeber|the article]] was described in [[Biology]].")
```
