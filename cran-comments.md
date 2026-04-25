# CRAN submission comments -- wikilite 0.1.0

## Test environments

* Local Windows 11, R 4.2.3 (ucrt)
* R-hub: Windows (R-devel), Ubuntu (R-release), macOS (R-release)
* win-builder: R-devel

## R CMD check results

### Known local NOTE (not a code issue)

The PDF manual check produces an ERROR on the local Windows machine:

  "Font T1/pcr/m/n/10=pcrr8t at 10.0pt not loadable: Metric (TFM) file not
  found."

This is caused by a missing Courier font metric (pcrr8t) in the local MiKTeX
installation. The Rd documentation is syntactically valid and the same check
passes cleanly on Linux (R-hub / win-builder). CRAN checks will not encounter
this issue.

### Expected NOTEs on first submission

* "New submission" -- expected.
* "Suggests or Enhances not in mainstream repositories: rAltmetric" --
  rAltmetric (ropensci/rAltmetric) is listed in Suggests only. The two
  functions that use it (annotate_doi_list_altmetrics,
  annotate_isbn_list_altmetrics) call requireNamespace() and emit an
  informative error if the package is absent. All tests that exercise these
  functions are guarded by skip_on_cran().
* "unable to verify current time" -- NTP resolution issue on the local
  machine; not reproducible on CRAN infrastructure.

## Dependencies

All hard dependencies (Imports) are on CRAN. rAltmetric is in Suggests only
and is available from <https://github.com/ropensci/rAltmetric>. The package
requires R >= 4.1.0 for the native pipe operator (`|>`).

## Network access

All functions that query external APIs (MediaWiki, EuropePMC, CrossRef,
Altmetric, Google Books, Open Library, Wikimedia pageviews) are guarded by
`\dontrun{}` in examples and `skip_on_cran()` in tests. The package does not
initiate any network connections during `R CMD check`.

## Large vignettes

All vignette code chunks use `eval = FALSE`; no network calls are made during
vignette building.
