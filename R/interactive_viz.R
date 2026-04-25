# Interactive timelines and networks for Wikipedia article sets

# -- Internal data-builders (testable without network) -------------------------

#' Build nodes and edges for an article-publication bipartite network
#'
#' @param doi_df Data frame from \code{get_regex_citations_in_wiki_table} with
#'   columns \code{art} and \code{citation_fetched}.
#' @param top_n_dois Maximum number of publication nodes to include.
#' @param min_wiki_count Minimum number of articles that must cite a DOI for it
#'   to appear as a node.
#' @param epmc_meta Optional data frame from
#'   \code{\link{annotate_doi_list_europmc}} with columns \code{doi},
#'   \code{title}, \code{journalTitle}, \code{pubYear}.  When supplied,
#'   publication node labels and tooltips are enriched.
#' @return A named list with elements \code{nodes} and \code{edges}.
#' @noRd
.build_pubnet_data <- function(doi_df,
                                top_n_dois    = 50L,
                                min_wiki_count = 2L,
                                epmc_meta      = NULL) {

  doi_counts <- doi_df |>
    dplyr::group_by(citation_fetched) |>
    dplyr::summarise(
      n_articles = dplyr::n_distinct(art),
      .groups    = "drop"
    ) |>
    dplyr::filter(n_articles >= min_wiki_count) |>
    dplyr::arrange(dplyr::desc(n_articles)) |>
    dplyr::slice_head(n = as.integer(top_n_dois))

  if (nrow(doi_counts) == 0L) return(NULL)

  doi_filt <- dplyr::filter(doi_df, citation_fetched %in% doi_counts$citation_fetched)

  art_doi_counts <- doi_df |>
    dplyr::group_by(art) |>
    dplyr::summarise(n_dois = dplyr::n_distinct(citation_fetched), .groups = "drop")

  arts <- unique(doi_df$art)

  # Enrich DOI labels with EuropePMC metadata when available
  pub_labels <- doi_counts$citation_fetched
  pub_titles <- doi_counts$citation_fetched
  pub_tooltip_extra <- rep("", nrow(doi_counts))

  if (!is.null(epmc_meta) && nrow(epmc_meta) > 0L) {
    idx <- match(doi_counts$citation_fetched, epmc_meta$doi)
    valid <- !is.na(idx)
    if (any(valid)) {
      pub_labels[valid] <- paste0(
        substr(epmc_meta$title[idx[valid]], 1L, 35L), "..."
      )
      pub_tooltip_extra[valid] <- paste0(
        "<br><i>", epmc_meta$journalTitle[idx[valid]], "</i>",
        " (", epmc_meta$pubYear[idx[valid]], ")"
      )
    }
  }

  article_nodes <- data.frame(
    id    = arts,
    label = arts,
    group = "Article",
    shape = "box",
    value = art_doi_counts$n_dois[match(arts, art_doi_counts$art)],
    title = paste0(
      "<b>", arts, "</b><br>",
      "DOIs cited: ",
      art_doi_counts$n_dois[match(arts, art_doi_counts$art)]
    ),
    url   = paste0("https://en.wikipedia.org/wiki/",
                   utils::URLencode(gsub(" ", "_", arts), reserved = FALSE)),
    stringsAsFactors = FALSE
  )

  pub_nodes <- data.frame(
    id    = doi_counts$citation_fetched,
    label = pub_labels,
    group = "Publication",
    shape = "dot",
    value = doi_counts$n_articles,
    title = paste0(
      "<b>DOI:</b> ", doi_counts$citation_fetched,
      pub_tooltip_extra,
      "<br>Cited by <b>", doi_counts$n_articles, "</b> article(s)"
    ),
    url   = paste0("https://doi.org/", doi_counts$citation_fetched),
    stringsAsFactors = FALSE
  )

  nodes <- rbind(article_nodes, pub_nodes)

  edges <- unique(data.frame(
    from  = doi_filt$art,
    to    = doi_filt$citation_fetched,
    color = "#aaaaaa",
    stringsAsFactors = FALSE
  ))

  list(nodes = nodes, edges = edges)
}


#' Build nodes and edges for an article co-citation network
#'
#' @param doi_df Data frame from \code{get_regex_citations_in_wiki_table} with
#'   columns \code{art} and \code{citation_fetched}.
#' @param min_shared_dois Minimum shared DOI count for an edge to be drawn.
#' @return A named list with elements \code{nodes} and \code{edges}, or
#'   \code{NULL} if no pairs pass \code{min_shared_dois}.
#' @noRd
.build_cocite_data <- function(doi_df, min_shared_dois = 1L) {

  art_dois  <- lapply(split(doi_df$citation_fetched, doi_df$art), unique)
  art_names <- names(art_dois)
  n_arts    <- length(art_names)

  if (n_arts < 2L) return(NULL)

  edge_rows <- vector("list", n_arts * (n_arts - 1L) / 2L)
  k <- 0L
  for (i in seq_len(n_arts - 1L)) {
    for (j in seq(i + 1L, n_arts)) {
      shared <- intersect(art_dois[[i]], art_dois[[j]])
      if (length(shared) >= min_shared_dois) {
        k <- k + 1L
        top5 <- paste(utils::head(shared, 5L), collapse = "<br>")
        edge_rows[[k]] <- data.frame(
          from  = art_names[i],
          to    = art_names[j],
          value = length(shared),
          title = paste0(
            "<b>", length(shared), " shared DOI(s)</b><br>", top5,
            if (length(shared) > 5L) paste0("<br>... and ",
                                            length(shared) - 5L, " more") else ""
          ),
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (k == 0L) return(NULL)
  edges <- do.call(rbind, edge_rows[seq_len(k)])

  degree    <- table(c(edges$from, edges$to))
  n_dois    <- vapply(art_dois, function(x) length(unique(x)), integer(1L))

  nodes <- data.frame(
    id    = art_names,
    label = art_names,
    value = as.integer(degree[art_names]),
    title = paste0(
      "<b>", art_names, "</b><br>",
      "Unique DOIs: ", n_dois[art_names], "<br>",
      "Connected to: ", as.integer(degree[art_names]), " article(s)"
    ),
    url = paste0("https://en.wikipedia.org/wiki/",
                 utils::URLencode(gsub(" ", "_", art_names), reserved = FALSE)),
    stringsAsFactors = FALSE
  )
  nodes$value[is.na(nodes$value)] <- 0L

  list(nodes = nodes, edges = edges)
}


#' Build nodes and edges for an article wikilink network
#'
#' @param recent A revision data frame (from
#'   \code{get_category_articles_most_recent}) with columns \code{art} and
#'   \code{*}.
#' @param only_internal Logical.  If \code{TRUE} (default), only wikilinks
#'   that point to another article in \code{recent$art} are retained.
#' @param top_n_links When \code{only_internal = FALSE}, retain at most this
#'   many of the most-linked-to targets (default: 80).
#' @return A named list with elements \code{nodes} and \code{edges}, or
#'   \code{NULL} if no links are found.
#' @noRd
.build_wikilink_data <- function(recent,
                                  only_internal = TRUE,
                                  top_n_links   = 80L) {

  link_rows <- vector("list", nrow(recent))
  for (i in seq_len(nrow(recent))) {
    raw     <- extract_wikihypelinks(recent$`*`[i])
    cleaned <- gsub("\\[\\[|\\]\\]", "", raw)
    targets <- vapply(cleaned,
                      function(x) unlist(strsplit(x, "\\|"))[1L],
                      character(1L))
    # Drop section links (#) and file/image/category prefixes
    targets <- targets[!grepl("^(File:|Image:|Category:|#)", targets, ignore.case = TRUE)]
    if (length(targets) > 0L) {
      link_rows[[i]] <- data.frame(
        from = recent$art[i],
        to   = targets,
        stringsAsFactors = FALSE
      )
    }
  }

  link_df <- do.call(rbind, link_rows)
  if (is.null(link_df) || nrow(link_df) == 0L) return(NULL)

  input_arts <- recent$art

  if (only_internal) {
    link_df <- link_df[link_df$to %in% input_arts, ]
  } else {
    # Cap to top_n_links most referenced targets
    top_targets <- names(utils::tail(sort(table(link_df$to)), as.integer(top_n_links)))
    link_df <- link_df[link_df$to %in% c(input_arts, top_targets), ]
  }

  if (nrow(link_df) == 0L) return(NULL)

  all_nodes <- unique(c(link_df$from, link_df$to))
  in_deg    <- table(link_df$to)
  out_deg   <- table(link_df$from)

  get_deg <- function(name, tbl) as.integer(ifelse(is.na(tbl[name]), 0L, tbl[name]))

  nodes <- data.frame(
    id    = all_nodes,
    label = all_nodes,
    group = ifelse(all_nodes %in% input_arts, "Input article", "Linked article"),
    value = vapply(all_nodes, function(n) get_deg(n, in_deg), integer(1L)),
    title = vapply(all_nodes, function(n) paste0(
      "<b>", n, "</b><br>",
      "In-links: ",  get_deg(n, in_deg),  "<br>",
      "Out-links: ", get_deg(n, out_deg)
    ), character(1L)),
    url   = paste0("https://en.wikipedia.org/wiki/",
                   utils::URLencode(gsub(" ", "_", all_nodes), reserved = FALSE)),
    stringsAsFactors = FALSE
  )

  edges <- unique(data.frame(
    from   = link_df$from,
    to     = link_df$to,
    arrows = "to",
    color  = "#aaaaaa",
    stringsAsFactors = FALSE
  ))

  list(nodes = nodes, edges = edges)
}


# -- JS helper: open node URL on click -----------------------------------------

.vis_click_url_js <- paste0(
  "function(properties) {",
  "  var id = properties.nodes[0];",
  "  if (id === undefined) return;",
  "  var url = this.body.data.nodes._data[id].url;",
  "  if (url) window.open(url, '_blank');",
  "}"
)


# -- Exported visualisation functions ------------------------------------------

#' Build an interactive Gantt-style timeline for a list of Wikipedia articles
#'
#' For each article in \code{articles}, the function retrieves the creation
#' revision and the most recent revision, then renders an interactive
#' \pkg{plotly} figure showing each article as a horizontal bar spanning its
#' edit lifetime.  Hover text includes creation date, first editor, initial
#' and current byte size, and a clickable link to the Wikipedia page.
#'
#' @param articles Character vector of English Wikipedia article titles.
#' @param date_an Character string. Upper date limit for revision queries in
#'   ISO 8601 format (default: \code{"2024-01-01T00:00:00Z"}).
#' @param color_by One of \code{"sciscore"} (colour bars by SciScore, default),
#'   \code{"size"} (colour by current article size), or \code{"none"}
#'   (uniform colour).
#' @return A \code{plotly} htmlwidget.
#' @export
#' @examples
#' \dontrun{
#' articles <- c("Zeitgeber", "Advanced sleep phase disorder",
#'               "Sleep deprivation", "Circadian rhythm")
#' plot_interactive_timeline(articles)
#' }
plot_interactive_timeline <- function(articles,
                                       date_an  = "2024-01-01T00:00:00Z",
                                       color_by = c("sciscore", "size", "none")) {
  color_by <- match.arg(color_by)

  initial <- get_category_articles_creation(articles)
  recent  <- get_category_articles_most_recent(articles)

  if (is.null(initial) || nrow(initial) == 0L) {
    stop("Could not retrieve article history. Check article titles and network access.")
  }

  parse_ts <- function(ts_vec) {
    as.Date(matrix(unlist(strsplit(ts_vec, "T")), byrow = TRUE, ncol = 2L)[, 1L])
  }

  initial$created <- parse_ts(initial$timestamp)

  df <- data.frame(
    art          = initial$art,
    created      = initial$created,
    first_editor = initial$user,
    size_first   = initial$size,
    stringsAsFactors = FALSE
  )

  if (!is.null(recent) && nrow(recent) > 0L) {
    recent$updated <- parse_ts(recent$timestamp)
    df <- merge(df,
                recent[, c("art", "updated", "size")],
                by = "art", all.x = TRUE)
    names(df)[names(df) == "size"] <- "size_last"
  } else {
    df$updated   <- df$created
    df$size_last <- df$size_first
  }

  df$updated[is.na(df$updated)] <- df$created[is.na(df$updated)]
  df <- df[order(df$created), ]
  df$y_pos <- seq_len(nrow(df))
  df$wiki_url <- paste0(
    "https://en.wikipedia.org/wiki/",
    utils::URLencode(gsub(" ", "_", df$art), reserved = FALSE)
  )

  # Compute colour metric
  if (color_by == "sciscore" && !is.null(recent)) {
    df$color_val <- vapply(
      match(df$art, recent$art),
      function(i) if (is.na(i)) NA_real_ else get_sci_score(recent$`*`[i]),
      numeric(1L)
    )
    color_title <- "SciScore"
  } else if (color_by == "size") {
    df$color_val <- df$size_last
    color_title  <- "Current size (bytes)"
  } else {
    df$color_val <- 1
    color_title  <- ""
  }

  # Build figure
  fig <- plotly::plot_ly()

  # Lifespan bars
  for (i in seq_len(nrow(df))) {
    fig <- plotly::add_segments(
      fig,
      x         = df$created[i],
      xend      = df$updated[i],
      y         = df$y_pos[i],
      yend      = df$y_pos[i],
      line      = list(color = "rgba(78,121,167,0.25)", width = 10),
      hoverinfo = "none",
      showlegend = FALSE
    )
  }

  # Creation markers
  fig <- plotly::add_markers(
    fig,
    data   = df,
    x      = ~created,
    y      = ~y_pos,
    name   = "Article created",
    marker = list(
      color    = ~color_val,
      colorscale = "Viridis",
      size     = 12,
      symbol   = "circle",
      colorbar = list(title = color_title),
      showscale = (color_by != "none")
    ),
    text = ~paste0(
      "<b><a href='", wiki_url, "' target='_blank'>", art, "</a></b><br>",
      "Created: ", created, "<br>",
      "First editor: ", first_editor, "<br>",
      "Initial size: ", format(size_first, big.mark = ","), " bytes"
    ),
    hoverinfo = "text"
  )

  # Most-recent-revision markers
  fig <- plotly::add_markers(
    fig,
    data   = df,
    x      = ~updated,
    y      = ~y_pos,
    name   = "Latest revision",
    marker = list(color = "#F28E2B", size = 10, symbol = "diamond"),
    text   = ~paste0(
      "<b>", art, "</b><br>",
      "Last edited: ", updated, "<br>",
      "Current size: ", format(size_last, big.mark = ","), " bytes"
    ),
    hoverinfo = "text"
  )

  plotly::layout(
    fig,
    title     = list(text = "Wikipedia Article Timeline", font = list(size = 18)),
    xaxis     = list(title = "Date", type = "date"),
    yaxis     = list(
      title    = "",
      ticktext = df$art,
      tickvals = df$y_pos,
      tickmode = "array",
      autorange = "reversed"
    ),
    hovermode  = "closest",
    showlegend = TRUE,
    legend     = list(orientation = "h", y = -0.1),
    margin     = list(l = 220, r = 60, t = 60, b = 60)
  )
}


#' Build an interactive article-publication bipartite network
#'
#' Fetches the most recent wikitext for each article, extracts all DOIs, and
#' renders a \pkg{visNetwork} bipartite graph in which:
#' \itemize{
#'   \item Blue square nodes represent Wikipedia articles.
#'   \item Orange circular nodes represent cited publications (DOIs).
#'   \item Edges connect each article to the publications it cites.
#'   \item Node size is proportional to the number of DOIs cited (articles) or
#'     the number of citing articles (publications).
#' }
#' Clicking a publication node opens its DOI page in a new tab.
#' Clicking an article node opens its Wikipedia page.
#'
#' @param articles Character vector of English Wikipedia article titles.
#' @param date_an Character string. Upper date limit in ISO 8601 format
#'   (default: \code{"2024-01-01T00:00:00Z"}).
#' @param top_n_dois Maximum number of publication nodes to display (default:
#'   50).  The most widely cited DOIs are retained.
#' @param min_wiki_count Minimum number of articles that must cite a DOI for it
#'   to be shown (default: 2).
#' @param annotate Logical.  If \code{TRUE}, publication node labels are
#'   enriched with titles from EuropePMC (requires a live internet connection;
#'   slow for large DOI lists).  Default: \code{FALSE}.
#' @return A \code{visNetwork} htmlwidget.
#' @export
#' @examples
#' \dontrun{
#' articles <- c("Zeitgeber", "Advanced sleep phase disorder",
#'               "Sleep deprivation", "Circadian rhythm")
#' plot_article_publication_network(articles)
#'
#' # With EuropePMC annotation for paper titles
#' plot_article_publication_network(articles, annotate = TRUE)
#' }
plot_article_publication_network <- function(articles,
                                              date_an        = "2024-01-01T00:00:00Z",
                                              top_n_dois     = 50L,
                                              min_wiki_count = 2L,
                                              annotate       = FALSE) {
  recent <- get_category_articles_most_recent(articles)
  if (is.null(recent) || nrow(recent) == 0L) {
    stop("Could not retrieve article data. Check article titles and network access.")
  }

  doi_df <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
  if (nrow(doi_df) == 0L) {
    stop("No DOIs found in the supplied articles.")
  }

  epmc_meta <- NULL
  if (annotate) {
    doi_list  <- unique(doi_df$citation_fetched)
    epmc_meta <- tryCatch(
      annotate_doi_list_europmc(doi_list),
      error = function(e) {
        message("EuropePMC annotation failed: ", conditionMessage(e))
        NULL
      }
    )
  }

  net <- .build_pubnet_data(doi_df, top_n_dois, min_wiki_count, epmc_meta)
  if (is.null(net)) {
    stop("No publications pass the min_wiki_count = ", min_wiki_count,
         " threshold. Try lowering it.")
  }

  visNetwork::visNetwork(
    net$nodes, net$edges,
    height = "700px",
    width  = "100%",
    main   = list(text = "Article-Publication Network",
                  style = "font-size:18px;font-weight:bold;text-align:center;")
  ) |>
    visNetwork::visGroups(
      groupname = "Article",
      color     = list(background = "#4E79A7", border = "#2c5282",
                       highlight  = list(background = "#6fa3d4", border = "#2c5282")),
      shape     = "box",
      font      = list(color = "white", size = 14)
    ) |>
    visNetwork::visGroups(
      groupname = "Publication",
      color     = list(background = "#F28E2B", border = "#a05e0f",
                       highlight  = list(background = "#ffb55f", border = "#a05e0f")),
      shape     = "dot"
    ) |>
    visNetwork::visNodes(
      scaling = list(min = 10, max = 50,
                     label = list(enabled = TRUE, min = 10, max = 22))
    ) |>
    visNetwork::visEdges(
      color  = list(color = "#cccccc", highlight = "#F28E2B"),
      smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.2),
      arrows = list(to = list(enabled = TRUE, scaleFactor = 0.4))
    ) |>
    visNetwork::visPhysics(
      solver             = "forceAtlas2Based",
      forceAtlas2Based   = list(gravitationalConstant = -60,
                                centralGravity        = 0.005,
                                springLength          = 100,
                                springConstant        = 0.08),
      stabilization      = list(enabled = TRUE, iterations = 200)
    ) |>
    visNetwork::visOptions(
      highlightNearest = list(enabled = TRUE, degree = 1, hover = TRUE),
      nodesIdSelection = list(enabled = TRUE, useLabels = TRUE)
    ) |>
    visNetwork::visLegend(useGroups = TRUE, position = "right") |>
    visNetwork::visInteraction(navigationButtons = TRUE, tooltipDelay = 100) |>
    visNetwork::visEvents(selectNode = .vis_click_url_js)
}


#' Build an interactive article co-citation network
#'
#' Constructs an undirected weighted network where nodes are Wikipedia articles
#' and an edge between two articles indicates that they both cite at least
#' \code{min_shared_dois} of the same DOIs.  Edge thickness scales with the
#' number of shared citations; node size scales with connectivity.
#'
#' Hovering over an edge lists the top shared DOIs.  Clicking a node opens the
#' Wikipedia article in a new tab.
#'
#' @param articles Character vector of English Wikipedia article titles.
#' @param date_an Character string. Upper date limit in ISO 8601 format
#'   (default: \code{"2024-01-01T00:00:00Z"}).
#' @param min_shared_dois Minimum number of shared DOIs required to draw an
#'   edge (default: 1).  Increase this to focus on the most strongly connected
#'   pairs.
#' @return A \code{visNetwork} htmlwidget, or \code{NULL} (invisibly) if no
#'   article pairs share enough DOIs.
#' @export
#' @examples
#' \dontrun{
#' articles <- c("Zeitgeber", "Advanced sleep phase disorder",
#'               "Sleep deprivation", "Circadian rhythm",
#'               "Non-24-hour sleep-wake disorder")
#' plot_article_cocitation_network(articles, min_shared_dois = 2)
#' }
plot_article_cocitation_network <- function(articles,
                                             date_an         = "2024-01-01T00:00:00Z",
                                             min_shared_dois = 1L) {
  recent <- get_category_articles_most_recent(articles)
  if (is.null(recent) || nrow(recent) == 0L) {
    stop("Could not retrieve article data. Check article titles and network access.")
  }

  doi_df <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
  if (nrow(doi_df) == 0L) {
    stop("No DOIs found in the supplied articles.")
  }

  net <- .build_cocite_data(doi_df, min_shared_dois)
  if (is.null(net)) {
    message("No article pairs share ", min_shared_dois, " or more DOI(s). ",
            "Try lowering min_shared_dois.")
    return(invisible(NULL))
  }

  visNetwork::visNetwork(
    net$nodes, net$edges,
    height = "700px",
    width  = "100%",
    main   = list(text = "Article Co-citation Network",
                  style = "font-size:18px;font-weight:bold;text-align:center;")
  ) |>
    visNetwork::visNodes(
      shape  = "ellipse",
      color  = list(background = "#59A14F", border = "#2d6b27",
                    highlight  = list(background = "#8fd984", border = "#2d6b27")),
      font   = list(size = 14),
      scaling = list(min = 14, max = 50,
                     label = list(enabled = TRUE, min = 12, max = 20))
    ) |>
    visNetwork::visEdges(
      color   = list(color = "#bbbbbb", highlight = "#e07b00"),
      smooth  = list(enabled = FALSE),
      scaling = list(min = 1, max = 12),
      font    = list(size = 10, align = "middle")
    ) |>
    visNetwork::visPhysics(
      solver  = "barnesHut",
      barnesHut = list(gravitationalConstant = -3000,
                       centralGravity        = 0.3,
                       springLength          = 120,
                       springConstant        = 0.04,
                       damping               = 0.09),
      stabilization = list(enabled = TRUE, iterations = 200)
    ) |>
    visNetwork::visOptions(
      highlightNearest = list(enabled = TRUE, degree = 1, hover = TRUE),
      nodesIdSelection = list(enabled = TRUE, useLabels = TRUE)
    ) |>
    visNetwork::visInteraction(navigationButtons = TRUE, tooltipDelay = 100) |>
    visNetwork::visEvents(selectNode = .vis_click_url_js)
}


#' Build an interactive article-article wikilink network
#'
#' Extracts \code{[[...]]}-style wikilinks from the wikitext of each article
#' and renders a directed \pkg{visNetwork} graph.  Nodes represent Wikipedia
#' articles and directed edges represent hyperlinks from one article to another.
#'
#' By default (\code{only_internal = TRUE}) only links between articles in the
#' input set are drawn, making the graph useful for understanding how a topic
#' cluster cross-references itself.  Set \code{only_internal = FALSE} to also
#' include the most-linked-to external Wikipedia pages (capped at
#' \code{top_n_links}).
#'
#' Node size reflects in-degree (number of incoming links).  Clicking any node
#' opens the corresponding Wikipedia article in a new browser tab.
#'
#' @param articles Character vector of English Wikipedia article titles.
#' @param date_an Character string. Upper date limit in ISO 8601 format
#'   (default: \code{"2024-01-01T00:00:00Z"}).
#' @param only_internal Logical.  If \code{TRUE} (default), only wikilinks
#'   pointing to another article in \code{articles} are shown.
#' @param top_n_links When \code{only_internal = FALSE}, the maximum number of
#'   external link targets to include, chosen by link frequency (default: 80).
#' @return A \code{visNetwork} htmlwidget, or \code{NULL} (invisibly) if no
#'   qualifying links are found.
#' @export
#' @examples
#' \dontrun{
#' articles <- c("Zeitgeber", "Advanced sleep phase disorder",
#'               "Sleep deprivation", "Circadian rhythm")
#' # Internal links only
#' plot_article_wikilink_network(articles)
#'
#' # Include top 40 external link targets
#' plot_article_wikilink_network(articles,
#'                               only_internal = FALSE,
#'                               top_n_links   = 40)
#' }
plot_article_wikilink_network <- function(articles,
                                           date_an       = "2024-01-01T00:00:00Z",
                                           only_internal = TRUE,
                                           top_n_links   = 80L) {
  recent <- get_category_articles_most_recent(articles)
  if (is.null(recent) || nrow(recent) == 0L) {
    stop("Could not retrieve article data. Check article titles and network access.")
  }

  net <- .build_wikilink_data(recent, only_internal, top_n_links)
  if (is.null(net)) {
    message(
      if (only_internal)
        "No wikilinks found between the provided articles."
      else
        "No qualifying wikilinks found."
    )
    return(invisible(NULL))
  }

  visNetwork::visNetwork(
    net$nodes, net$edges,
    height = "700px",
    width  = "100%",
    main   = list(text = "Article Wikilink Network",
                  style = "font-size:18px;font-weight:bold;text-align:center;")
  ) |>
    visNetwork::visGroups(
      groupname = "Input article",
      color     = list(background = "#4E79A7", border = "#2c5282",
                       highlight  = list(background = "#6fa3d4", border = "#2c5282")),
      shape     = "box",
      font      = list(color = "white", size = 14)
    ) |>
    visNetwork::visGroups(
      groupname = "Linked article",
      color     = list(background = "#BAB0AC", border = "#888080",
                       highlight  = list(background = "#d4cdc9", border = "#888080")),
      shape     = "ellipse"
    ) |>
    visNetwork::visNodes(
      scaling = list(min = 10, max = 45,
                     label = list(enabled = TRUE, min = 10, max = 20))
    ) |>
    visNetwork::visEdges(
      arrows = list(to = list(enabled = TRUE, scaleFactor = 0.5)),
      color  = list(color = "#cccccc", highlight = "#4E79A7"),
      smooth = list(enabled = TRUE, type = "curvedCW", roundness = 0.15)
    ) |>
    visNetwork::visPhysics(
      solver  = "barnesHut",
      barnesHut = list(gravitationalConstant = -2500,
                       centralGravity        = 0.2,
                       springLength          = 130,
                       springConstant        = 0.04,
                       damping               = 0.09),
      stabilization = list(enabled = TRUE, iterations = 200)
    ) |>
    visNetwork::visOptions(
      highlightNearest = list(enabled = TRUE, degree = 1, hover = TRUE),
      nodesIdSelection = list(enabled = TRUE, useLabels = TRUE)
    ) |>
    visNetwork::visLegend(useGroups = TRUE, position = "right") |>
    visNetwork::visInteraction(navigationButtons = TRUE, tooltipDelay = 100) |>
    visNetwork::visEvents(selectNode = .vis_click_url_js)
}
