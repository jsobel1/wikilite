# progress_helpers.R
# Internal helpers for progress reporting during multi-article fetches and
# batch annotation calls. Mirrors the Python `progress.py` module in the
# wikicitation-mcp companion: structured emissions at percentage milestones
# for known totals, every-Nth-item emissions for open-ended pagination.
#
# Output routing:
#   - Inside a Shiny session (detected via `shiny::isRunning()`), updates
#     the active `withProgress()` handler so end-users see a Shiny progress
#     bar.
#   - Outside Shiny, uses `cli::cli_progress_bar()` so the user sees a
#     terminal progress bar with rate + ETA. cli is already a transitive
#     dependency of dplyr, but is now a direct Import so the contract is
#     explicit.
#   - When `getOption("wikilite.progress", TRUE)` is FALSE, all progress
#     output is suppressed -- useful inside vignettes/tests/CI.
#
# Public-ish helpers (kept un-exported, internal to the package):
#   .progress_start(label, total = NULL)
#   .progress_update(handle, by = 1L, label = NULL)
#   .progress_done(handle)
#
# All three accept NULL handles (e.g., when progress is disabled) and
# silently no-op so callers don't need to check enable/disable themselves.

.progress_enabled <- function() {
  isTRUE(getOption("wikilite.progress", TRUE))
}

.in_shiny_session <- function() {
  requireNamespace("shiny", quietly = TRUE) &&
    isTRUE(tryCatch(shiny::isRunning(), error = function(e) FALSE))
}

#' Open a progress reporter for a (possibly long-running) operation.
#'
#' @param label Short tag, e.g. "Fetching revisions".
#' @param total Expected final count, or NULL for open-ended.
#' @return An opaque handle to pass to `.progress_update()` and
#'   `.progress_done()`. Returns NULL when progress is disabled.
#' @noRd
.progress_start <- function(label, total = NULL) {
  if (!.progress_enabled()) return(NULL)

  if (.in_shiny_session()) {
    # Caller is responsible for an enclosing withProgress().
    # incProgress here is the per-update step; we record metadata in a list.
    return(list(kind = "shiny", label = label, total = total, count = 0L,
                started = Sys.time()))
  }

  id <- if (!is.null(total) && is.finite(total) && total > 0) {
    cli::cli_progress_bar(label, total = as.integer(total),
                           clear = FALSE, .auto_close = FALSE)
  } else {
    # Open-ended (no known total). cli supports total = NA for spinner mode.
    cli::cli_progress_bar(label, total = NA, clear = FALSE, .auto_close = FALSE)
  }
  list(kind = "cli", id = id, total = total, count = 0L, started = Sys.time())
}

#' Increment a progress handle by `by`.
#' @noRd
.progress_update <- function(handle, by = 1L, label = NULL) {
  if (is.null(handle) || by <= 0) return(invisible())
  handle$count <- handle$count + by

  if (handle$kind == "shiny") {
    # incProgress is a no-op outside an active withProgress() block, which
    # makes this safe even if the caller forgot to wrap.
    amount <- if (!is.null(handle$total) && handle$total > 0)
                by / handle$total else 0
    detail <- if (!is.null(handle$total))
                sprintf("%d / %d", handle$count, handle$total)
              else
                sprintf("%d items", handle$count)
    try(shiny::incProgress(amount, detail = detail), silent = TRUE)
  } else if (handle$kind == "cli") {
    cli::cli_progress_update(id = handle$id, set = handle$count)
  }
  invisible(handle)
}

#' Close a progress handle and emit a final summary line.
#' @noRd
.progress_done <- function(handle) {
  if (is.null(handle)) return(invisible())
  elapsed <- as.numeric(difftime(Sys.time(), handle$started, units = "secs"))
  rate <- if (elapsed > 0) handle$count / elapsed else NA_real_

  if (handle$kind == "cli") {
    cli::cli_progress_done(id = handle$id)
    cli::cli_alert_success(sprintf(
      "%d items in %.1fs (%.1f items/s)",
      handle$count, elapsed,
      if (is.na(rate)) 0 else rate
    ))
  } else if (handle$kind == "shiny") {
    try(shiny::incProgress(0, detail = sprintf(
      "done - %d items in %.1fs", handle$count, elapsed
    )), silent = TRUE)
  }
  invisible(NULL)
}
