# CRAN submission comments — wikilite 0.1.0

## Test environments

* Local Windows 11, R 4.4.x
* R-hub: Windows (R-devel), Ubuntu (R-release), macOS (R-release)
* win-builder: R-devel

## R CMD check results

0 errors | 0 warnings | 0 notes (expected on first submission: 1 NOTE
"New submission").

## Dependencies

All dependencies are on CRAN. The package requires R >= 4.1.0 for the native
pipe operator (`|>`).

## Network access

All functions that query external APIs (MediaWiki, EuropePMC, CrossRef,
Altmetric, Google Books, Open Library) are guarded by `\dontrun{}` in
examples and `skip_on_cran()` in tests. The package does not initiate any
network connections during `R CMD check`.

## Large vignettes

All vignette code chunks use `eval = FALSE`; no network calls are made during
vignette building.
