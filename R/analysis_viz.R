# Analysis and visualisation functions ported from the COVID-19 analysis pipeline

#' Plot yearly edit counts for a Wikipedia article
#'
#' Produces a \pkg{ggplot2} bar chart of edit counts grouped by year,
#' optionally coloured by edit type (revert vs. other).
#'
#' @param art_history_full A full revision history data frame as returned by
#'   \code{\link{get_article_full_history_table}}.
#' @param art_name Character string used as the plot title.
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \donttest{
#' hist_df <- get_article_full_history_table("Zeitgeber")
#' get_edits_vs_time_plot(hist_df, "Zeitgeber")
#' }
get_edits_vs_time_plot <- function(art_history_full, art_name) {
  df <- art_history_full
  df$year <- as.integer(substr(df$timestamp, 1L, 4L))
  df$edit_type <- ifelse(
    grepl("mw-undo|mw-rollback", df$comment, ignore.case = TRUE),
    "Revert", "Edit"
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x = year, fill = edit_type)) +
    ggplot2::geom_bar(stat = "count", position = "stack") +
    ggplot2::scale_fill_manual(values = c("Edit" = "steelblue", "Revert" = "tomato")) +
    ggplot2::labs(title = paste("Edit history:", art_name),
                  x = "Year", y = "Number of edits", fill = "Type") +
    ggplot2::theme_classic()
  print(p)
  invisible(p)
}


#' Plot article size over time
#'
#' Produces a \pkg{ggplot2} line chart of article size (bytes) over the full
#' revision history.
#'
#' @param art_history_full A full revision history data frame as returned by
#'   \code{\link{get_article_full_history_table}}.
#' @param art_name Character string used as the plot title.
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \donttest{
#' hist_df <- get_article_full_history_table("Zeitgeber")
#' get_size_vs_time_plot(hist_df, "Zeitgeber")
#' }
get_size_vs_time_plot <- function(art_history_full, art_name) {
  df      <- art_history_full
  df$date <- as.Date(substr(df$timestamp, 1L, 10L))
  p <- ggplot2::ggplot(df, ggplot2::aes(x = date, y = size)) +
    ggplot2::geom_line(colour = "steelblue") +
    ggplot2::geom_point(size = 0.8, alpha = 0.4, colour = "steelblue") +
    ggplot2::labs(title = paste("Article size over time:", art_name),
                  x = "Date", y = "Size (bytes)") +
    ggplot2::scale_x_date() +
    ggplot2::theme_classic()
  print(p)
  invisible(p)
}


#' Find the closest date in a vector to a reference date
#'
#' Utility used for aligning publication dates to Wikipedia revision snapshots.
#'
#' @param date_in A \code{Date} or date-coercible value.
#' @param date_vect A vector of \code{Date} values.
#' @return The element of \code{date_vect} closest in time to \code{date_in}.
#' @export
#' @examples
#' dates <- as.Date(c("2020-01-01", "2020-06-01", "2021-01-01"))
#' get_closest_date(as.Date("2020-04-15"), dates)
get_closest_date <- function(date_in, date_vect) {
  date_in   <- as.Date(date_in)
  date_vect <- as.Date(date_vect)
  date_vect[which.min(abs(as.numeric(date_vect - date_in)))]
}


#' Compute citation latency between Wikipedia insertion and first publication
#'
#' Joins a DOI history data frame with EuropePMC annotation to compute, for
#' each citation, how many days elapsed between the paper's first publication
#' and its first appearance in the Wikipedia article.  Also flags preprints
#' by DOI prefix (\code{10.1101/}).
#'
#' @param doi_history_df Data frame from
#'   \code{\link{get_regex_citations_in_wiki_table}} with columns \code{art},
#'   \code{revid}, \code{timestamp} (optional), and \code{citation_fetched}.
#' @param epmc_annotation_df Data frame from
#'   \code{\link{annotate_doi_list_europmc}} with columns \code{doi} and
#'   \code{firstPublicationDate}.
#' @return A joined data frame with additional columns \code{latency_days}
#'   (numeric) and \code{is_preprint} (logical).
#' @export
#' @examples
#' \donttest{
#' recent  <- get_article_most_recent_table("Zeitgeber")
#' doi_df  <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
#' epmc_df <- annotate_doi_list_europmc(unique(doi_df$citation_fetched))
#' latency <- compute_citation_latency(doi_df, epmc_df)
#' }
compute_citation_latency <- function(doi_history_df, epmc_annotation_df) {
  if (!is.data.frame(epmc_annotation_df) || nrow(epmc_annotation_df) == 0L ||
      !all(c("doi", "firstPublicationDate") %in% names(epmc_annotation_df))) {
    doi_history_df$firstPublicationDate <- NA_character_
    doi_history_df$latency_days         <- NA_real_
    doi_history_df$is_preprint          <- stringr::str_starts(
      doi_history_df$citation_fetched, "10.1101/"
    )
    return(doi_history_df)
  }
  joined <- dplyr::left_join(
    doi_history_df,
    dplyr::select(epmc_annotation_df,
                  doi, firstPublicationDate),
    by = c("citation_fetched" = "doi")
  )

  wiki_date <- if ("timestamp" %in% names(joined)) {
    as.Date(substr(joined$timestamp, 1L, 10L))
  } else {
    rep(NA_real_, nrow(joined))
  }

  pub_date <- suppressWarnings(as.Date(joined$firstPublicationDate))

  joined$latency_days <- as.numeric(difftime(wiki_date, pub_date, units = "days"))
  joined$is_preprint  <- stringr::str_starts(joined$citation_fetched, "10.1101/")
  joined
}


#' Plot the distribution of citation latency
#'
#' Produces a \pkg{ggplot2} density or violin plot of the number of days
#' between paper publication and Wikipedia citation insertion.  Optionally
#' stratifies by preprint status and annotates with a KS test p-value.
#'
#' @param latency_df Data frame as returned by
#'   \code{\link{compute_citation_latency}} with columns \code{latency_days}
#'   and optionally \code{is_preprint}.
#' @param stratify_by Character string or \code{NULL}.  Use
#'   \code{"is_preprint"} to compare preprints vs. journal articles; any
#'   other value or \code{NULL} plots the pooled distribution.
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \donttest{
#' recent  <- get_article_most_recent_table("Zeitgeber")
#' doi_df  <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
#' epmc_df <- annotate_doi_list_europmc(unique(doi_df$citation_fetched))
#' latency <- compute_citation_latency(doi_df, epmc_df)
#' plot_latency_distribution(latency)
#' plot_latency_distribution(latency, stratify_by = "is_preprint")
#' }
plot_latency_distribution <- function(latency_df, stratify_by = NULL) {
  df <- latency_df[!is.na(latency_df$latency_days), ]

  if (!is.null(stratify_by) && stratify_by == "is_preprint" &&
      "is_preprint" %in% names(df)) {
    df$group <- ifelse(df$is_preprint, "Preprint (10.1101/)", "Journal article")
    p <- ggplot2::ggplot(df, ggplot2::aes(x = latency_days, fill = group)) +
      ggplot2::geom_density(alpha = 0.5) +
      ggplot2::scale_fill_manual(
        values = c("Preprint (10.1101/)" = "#E15759",
                   "Journal article"      = "#4E79A7")
      ) +
      ggplot2::labs(title = "Citation latency: preprints vs. journal articles",
                    x     = "Latency (days)",
                    y     = "Density",
                    fill  = "Source type") +
      ggplot2::theme_classic()

    pp  <- df$latency_days[df$is_preprint]
    jp  <- df$latency_days[!df$is_preprint]
    if (length(pp) > 1L && length(jp) > 1L) {
      ks_p <- tryCatch(stats::ks.test(pp, jp)$p.value, error = function(e) NA)
      if (!is.na(ks_p)) {
        p <- p + ggplot2::annotate(
          "text", x = Inf, y = Inf, hjust = 1.1, vjust = 1.5,
          label = paste0("KS p = ", signif(ks_p, 3))
        )
      }
    }
  } else {
    p <- ggplot2::ggplot(df, ggplot2::aes(x = latency_days)) +
      ggplot2::geom_density(fill = "steelblue", alpha = 0.6) +
      ggplot2::labs(title = "Citation latency distribution",
                    x = "Latency (days)", y = "Density") +
      ggplot2::theme_classic()
  }
  print(p)
  invisible(p)
}


#' Plot DOI latency segments
#'
#' Produces a segment plot showing, for each DOI, the gap between paper
#' publication date and first Wikipedia citation insertion.
#'
#' @param df_doi A data frame as returned by
#'   \code{\link{compute_citation_latency}} with columns
#'   \code{citation_fetched}, \code{firstPublicationDate},
#'   and \code{latency_days}.
#' @param art_name Character string used as the plot title.
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \donttest{
#' recent  <- get_article_most_recent_table("Zeitgeber")
#' doi_df  <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
#' epmc_df <- annotate_doi_list_europmc(unique(doi_df$citation_fetched))
#' latency <- compute_citation_latency(doi_df, epmc_df)
#' get_segment_history_doi_plot(latency, "Zeitgeber")
#' }
get_segment_history_doi_plot <- function(df_doi, art_name) {
  df <- df_doi[!is.na(df_doi$latency_days), ]
  df$pub_date  <- suppressWarnings(as.Date(df$firstPublicationDate))
  df$wiki_date <- df$pub_date + df$latency_days
  df <- df[order(df$pub_date), ]
  df$doi_label <- substr(df$citation_fetched, 1L, 25L)
  df$y_pos     <- seq_len(nrow(df))

  p <- ggplot2::ggplot(df) +
    ggplot2::geom_segment(
      ggplot2::aes(x = pub_date, xend = wiki_date,
                   y = y_pos,   yend = y_pos),
      colour = "steelblue", linewidth = 0.8
    ) +
    ggplot2::geom_point(ggplot2::aes(x = pub_date, y = y_pos),
                        colour = "navy", size = 2) +
    ggplot2::geom_point(ggplot2::aes(x = wiki_date, y = y_pos),
                        colour = "tomato", size = 2, shape = 17) +
    ggplot2::scale_x_date() +
    ggplot2::labs(title  = paste("DOI latency segments:", art_name),
                  x      = "Date",
                  y      = "Citation") +
    ggplot2::theme_classic() +
    ggplot2::theme(axis.text.y = ggplot2::element_blank(),
                   axis.ticks.y = ggplot2::element_blank())
  print(p)
  invisible(p)
}


#' Dot plot of DOI citation edits over time
#'
#' Plots each DOI citation insertion as a point on a timeline, providing a
#' fine-grained view of when citations were added to the article.
#'
#' @param df_doi A data frame as returned by
#'   \code{\link{compute_citation_latency}} with columns
#'   \code{citation_fetched}, \code{firstPublicationDate},
#'   and \code{latency_days}.
#' @param art_name Character string used as the plot title.
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \donttest{
#' recent  <- get_article_most_recent_table("Zeitgeber")
#' doi_df  <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
#' epmc_df <- annotate_doi_list_europmc(unique(doi_df$citation_fetched))
#' latency <- compute_citation_latency(doi_df, epmc_df)
#' get_dotplot_history(latency, "Zeitgeber")
#' }
get_dotplot_history <- function(df_doi, art_name) {
  df <- df_doi[!is.na(df_doi$latency_days), ]
  df$pub_date  <- suppressWarnings(as.Date(df$firstPublicationDate))
  df$wiki_date <- df$pub_date + df$latency_days
  df$is_preprint_f <- factor(df$is_preprint,
                              levels = c(FALSE, TRUE),
                              labels = c("Journal", "Preprint"))

  p <- ggplot2::ggplot(df,
         ggplot2::aes(x = wiki_date, y = latency_days, colour = is_preprint_f)) +
    ggplot2::geom_point(alpha = 0.7, size = 2) +
    ggplot2::scale_colour_manual(
      values = c("Journal" = "steelblue", "Preprint" = "tomato")
    ) +
    ggplot2::scale_x_date() +
    ggplot2::labs(title  = paste("DOI insertion dot plot:", art_name),
                  x      = "Wikipedia insertion date",
                  y      = "Latency (days)",
                  colour = "Source type") +
    ggplot2::theme_classic()
  print(p)
  invisible(p)
}
