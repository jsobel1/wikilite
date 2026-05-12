# Count revert-tagged (or all) edits per article for a time window

Queries the English Wikipedia MediaWiki API for all revisions whose
timestamps fall between `start` (newer) and `end` (older), counts
revisions tagged as `"mw-undo"` or `"mw-rollback"` (revert-type edits)
when `rev_eds = TRUE`, or counts all revisions when `rev_eds = FALSE`.
Handles pagination automatically.

## Usage

``` r
get_revert_counts(start, end, rev_eds = TRUE)
```

## Arguments

- start:

  Character string — newer boundary of the query window in MediaWiki API
  timestamp format `"YYYYMMDDHHmmss"` (e.g. `"20181212010000"`).

- end:

  Character string — older boundary in the same format (e.g.
  `"20181212000000"`).

- rev_eds:

  Logical. If `TRUE` (default), only revert-tagged edits (`"mw-undo"` or
  `"mw-rollback"`) are counted and the result column is named
  `sum_nb_reverts`. If `FALSE`, all revisions are counted and the result
  column is named `sum_nb_edits`.

## Value

A data frame with columns:

- `art`:

  Article title.

- `sum_nb_reverts` or `sum_nb_edits`:

  Total edit count within the time window (mode-dependent).

Rows are ordered descending. Articles with zero counts are excluded.

## Examples

``` r
# \donttest{
# Count revert edits for a one-hour window on 12 December 2018
get_revert_counts("20181212010000", "20181212000000")

# Count ALL edits for the same window
get_revert_counts("20181212010000", "20181212000000", rev_eds = FALSE)
# }
```
