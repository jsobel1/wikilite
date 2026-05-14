# CRAN submission comments -- wikilite 0.1.0 (resubmission)

This is a resubmission addressing all issues flagged by the CRAN incoming
auto-check on 2026-05-05. Changes since the initial submission:

* DESCRIPTION URL changed to the canonical form
  `https://jsobel1.github.io/wikilite/` (added trailing slash).
* Technical terms (`MediaWiki`, `DOIs`, `ISBNs`, `PMIDs`, `URLs`, `SciScore`)
  in the Description field are now wrapped in single quotes per CRAN policy.
* Replaced GigaScience publisher URL with plain DOI text in the README to
  avoid spurious 403/Forbidden URL-checker false positives.
* Added `.github`, `_pkgdown.yml`, `vignettes/cache`, and stray
  `vignettes/*.xlsx` artefacts to `.Rbuildignore` so the source tarball
  contains only canonical package contents.
* Replaced two non-ASCII em-dashes inside string literals in
  `R/progress_helpers.R` with ASCII hyphens.
* Added `nb_cnt` to the `globalVariables()` declaration to silence the
  no-visible-binding NOTE in `get_revert_counts()`.
* Removed `annotate_doi_list_altmetrics()` and `annotate_isbn_list_altmetrics()`
  (which depended on the archived `rAltmetric` package) from the package.
* Added `shiny` to Suggests; the progress helpers reference it through
  `requireNamespace()` for in-Shiny progress bar routing.
* Regenerated all `man/*.Rd` files via roxygen2 7.3.3, fixing every
  codoc mismatch reported in the auto-check (missing `lang`, `use_cache`,
  `batch_size`, `dir`, `workers`, `replacement` arguments and the
  `replecement` typo).

## Test environments

* Local Windows 11, R 4.2.3 (ucrt) -- 0 errors, 0 warnings, 2 NOTEs
* win-builder: R-devel (planned)

## R CMD check results

0 ERRORs, 0 WARNINGs, 2 NOTEs:

* "New submission" -- expected.
* "unable to verify current time" -- NTP-resolution artefact on the local
  machine; not reproducible on CRAN infrastructure.

## Dependencies

All hard dependencies (Imports) are on CRAN. The package requires
R >= 4.1.0 for the native pipe operator (`|>`).

## Network access

All functions that query external APIs (MediaWiki, EuropePMC, CrossRef,
Google Books, Open Library, Wikimedia pageviews) are guarded by
`\dontrun{}` in examples and `skip_on_cran()` in tests. The package does
not initiate any network connections during `R CMD check`.

## Vignettes

All vignette code chunks set `eval = identical(Sys.getenv("NOT_CRAN"), "true")`,
so no network calls are made during CRAN's vignette build.
