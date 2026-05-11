# CRAN submission comments -- wikilite 0.2.0

## Test environments

* Local Windows 11, R 4.2.3 (ucrt)
* R-hub: Windows (R-devel), Ubuntu (R-release), macOS (R-release)
* win-builder: R-devel

## R CMD check results

Local `R CMD check --as-cran` returns **0 ERRORs / 0 WARNINGs / 2 NOTEs**.

### Expected NOTEs

* "New submission" -- expected.
* "Suggests or Enhances not in mainstream repositories: rAltmetric" --
  `rAltmetric` (ropensci/rAltmetric) is listed in `Suggests` only and the
  install source is declared via `Additional_repositories:
  https://ropensci.r-universe.dev`. The two functions that use it
  (`annotate_doi_list_altmetrics`, `annotate_isbn_list_altmetrics`) call
  `requireNamespace()` and emit an informative error if the package is
  absent; their examples are wrapped in `\dontrun{}` because they require
  an external (non-CRAN) optional package. All tests that exercise these
  functions are guarded by `skip_on_cran()`.
* "unable to verify current time" -- NTP resolution issue on the local
  machine; not reproducible on CRAN infrastructure.

## Resubmission notes (response to Beni Altmann, 2026-05-11)

This is a resubmission of wikilite, bumped to version **0.2.0**, addressing
the two points raised in the previous review:

1. **References in `DESCRIPTION`.** Added the methods reference in the
   required CRAN format:
   `Benjakob, Aviram and Sobel (2022) <doi:10.1093/gigascience/giab095>`.
2. **`\dontrun{}` vs `\donttest{}`.** Replaced every `\dontrun{}` example
   wrapper with `\donttest{}`, with two exceptions: the two
   Altmetric-dependent examples (`annotate_doi_list_altmetrics`,
   `annotate_isbn_list_altmetrics`) remain in `\dontrun{}` because they
   genuinely cannot be executed without the optional `rAltmetric` package
   (not on CRAN), which matches the policy that `\dontrun{}` is allowed
   for missing additional software. All other examples that hit external
   APIs (MediaWiki, EuropePMC, CrossRef, Google Books, Open Library,
   Wikimedia pageviews) are now in `\donttest{}` and run successfully
   under `R CMD check --as-cran --run-donttest`.

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

## Dependencies

All hard dependencies (Imports) are on CRAN. `rAltmetric` is in
`Suggests` only and is available from
<https://github.com/ropensci/rAltmetric> (also mirrored at
<https://ropensci.r-universe.dev>, declared via `Additional_repositories`).
The package requires R >= 4.1.0 for the native pipe operator (`|>`).

## Network access

All functions that query external APIs (MediaWiki, EuropePMC, CrossRef,
Altmetric, Google Books, Open Library, Wikimedia pageviews) are wrapped in
`\donttest{}` in examples (so they are not run on CRAN itself) and
`skip_on_cran()` in tests. The package does not initiate any network
connections during `R CMD check` on CRAN.

## Large vignettes

All vignette code chunks use `eval = FALSE`; no network calls are made during
vignette building.
