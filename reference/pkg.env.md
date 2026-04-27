# Built-in regular expressions for citation extraction

A package-level environment that stores all pre-built regular expression
patterns used by wikilite. Access individual patterns by name (e.g.
`pkg.env$doi_regexp`) or iterate over `pkg.env$regexp_list` to apply all
patterns at once.

## Usage

``` r
pkg.env
```

## Format

An `environment`.

## Details

- `doi_regexp`:

  Matches DOIs: `10.XXXX/...`

- `isbn_regexp`:

  Matches ISBNs following an `isbn=` or `ISBN:` prefix.

- `url_regexp`:

  Matches `http://` and `https://` URLs.

- `pmid_regexp`:

  Matches PubMed identifiers.

- `cite_regexp`:

  Matches any Citation Style 1 template.

- `journal_regexp`, `news_regexp`, `web_regexp`, `book_regexp`, ...:

  Type-specific CS1 patterns.

- `ref_regexp`:

  Matches `<ref>...</ref>` blocks.

- `wikihyperlink_regexp`:

  Matches `[[...]]`-style links.

- `regexp_list`:

  Named character vector of all patterns above, suitable for iterating
  with
  [`extract_citations_regexp`](https://jsobel1.github.io/wikilite/reference/extract_citations_regexp.md).
