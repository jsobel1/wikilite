# CRAN submission comments -- wikilite 0.2.1

## Test environments

* Local Windows 11, R 4.2.3 (ucrt) -- 0 errors, 1 warning, 0 NOTEs
* win-builder: R-devel (planned)

## R CMD check results

Local `R CMD check` returns **0 ERRORs / 0 NOTEs / 1 WARNING**.

### Expected WARNING

* "LaTeX errors when creating PDF version of manual" -- Windows-only
  artefact caused by hyperlinks in the PDF index interacting with the
  local TinyTeX installation. The PDF without index builds cleanly. This
  warning does not appear on Linux/macOS or on CRAN's infrastructure.

## Resubmission notes (response to CRAN review, 2026-05-11)

This is a resubmission of wikilite, bumped to version **0.2.1**, addressing
the two points raised in the previous review plus removing the optional
`rAltmetric` dependency entirely:

1. **References in `DESCRIPTION`.** Added the methods reference in the
   required CRAN format:
   `Benjakob, Aviram and Sobel (2022) <doi:10.1093/gigascience/giab095>`.
2. **`\dontrun{}` vs `\donttest{}`.** Replaced every `\dontrun{}` example
   wrapper with `\donttest{}`. All examples that hit external APIs
   (MediaWiki, EuropePMC, CrossRef, Google Books, Open Library,
   Wikimedia pageviews) are now in `\donttest{}` and run successfully
   under `R CMD check --as-cran --run-donttest`.
3. **Removed `rAltmetric` dependency.** `annotate_doi_list_altmetrics()`
   and `annotate_isbn_list_altmetrics()` have been removed from the
   package. `rAltmetric` has been archived on CRAN since 2022 and its
   presence was causing a NOTE; removing these two functions eliminates
   the dependency entirely.

Additional cleanup performed at the same time:

* Documented previously-undocumented arguments (`batch_size` on
  `annotate_doi_list_europmc`; `lang` on the four interactive-viz
  functions).
* Added `nb_cnt` to `globalVariables()` to silence the only remaining
  "no visible binding" NOTE from dplyr NSE.
* Replaced two non-ASCII em-dashes in `R/progress_helpers.R` comments
  with plain ASCII.
* Tightened `.Rbuildignore` to exclude `_pkgdown.yml`, `.github/`,
  `.claude/`, and build artefacts.
* Rewrote a handful of examples that referenced a free variable
  (`latency_df`) or wrote files into the working directory to be
  self-contained and to use `tempdir()`.
* Fixed two README URLs that returned 403/404.
* Removed `purrr` from Imports (was only used by the removed Altmetric
  functions).
* Fixed vignette code chunks that could error during `R CMD check` when
  network returns empty results.

## Dependencies

All hard dependencies (Imports) are on CRAN. The package requires
R >= 4.1.0 for the native pipe operator (`|>`).

## Network access

All functions that query external APIs (MediaWiki, EuropePMC, CrossRef,
Google Books, Open Library, Wikimedia pageviews) are wrapped in
`\donttest{}` in examples (so they are not run on CRAN itself) and
`skip_on_cran()` in tests. The package does not initiate any network
connections during `R CMD check` on CRAN.

## Vignettes

All vignette code chunks set `eval = identical(Sys.getenv("NOT_CRAN"), "true")`,
so no network calls are made during CRAN's vignette build.
