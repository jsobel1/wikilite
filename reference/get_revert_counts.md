# Count revert-tagged edits per article for a time window

Queries the English Wikipedia MediaWiki API for all revisions whose
timestamps fall between `start` (newer) and `end` (older), counts
revisions tagged as `"mw-undo"` or `"mw-rollback"` (revert-type edits),
and returns a sorted data frame of articles with at least one such edit.

## Usage

``` r
get_revert_counts(start, end)
```

## Arguments

- start:

  Character string — newer boundary of the query window in MediaWiki API
  timestamp format `"YYYYMMDDHHmmss"` (e.g. `"20181212010000"`).

- end:

  Character string — older boundary in the same format (e.g.
  `"20181212000000"`).

## Value

A data frame with columns:

- `art`:

  Article title.

- `sum_nb_reverts`:

  Total number of revert-tagged edits within the time window.

Rows are ordered by `sum_nb_reverts` descending. Articles with zero
reverts are excluded.

## Details

The function handles pagination automatically — it follows all
`arvcontinue` tokens until the full time window has been fetched.

## Examples

``` r
if (FALSE) { # \dontrun{
# Count revert edits for a one-hour window on 12 December 2018
get_revert_counts("20181212010000", "20181212000000")
} # }
```
