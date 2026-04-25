# wikilite 0.2.0

## New features: interactive timelines and networks

Four new exported functions powered by **plotly** and **visNetwork**:

* `plot_interactive_timeline(articles, date_an, color_by)` — Plotly Gantt-style
  timeline showing article creation and last-edit dates. Bars are colour-coded
  by SciScore (default), article size, or a uniform colour. Hover text includes
  creation date, first editor, and byte sizes. Clicking labels opens the
  Wikipedia article.

* `plot_article_publication_network(articles, date_an, top_n_dois, min_wiki_count, annotate)` —
  Bipartite visNetwork with article nodes (blue squares) and publication nodes
  (orange circles). Edge direction: article → cited DOI. Node size reflects
  citation degree. When `annotate = TRUE`, publication labels are enriched with
  EuropePMC paper titles. Clicking any node opens the corresponding Wikipedia
  or DOI URL.

* `plot_article_cocitation_network(articles, date_an, min_shared_dois)` —
  Article–article visNetwork where edges represent shared DOI citations. Edge
  thickness scales with the number of shared papers; hovering over an edge lists
  the top shared DOIs.

* `plot_article_wikilink_network(articles, date_an, only_internal, top_n_links)` —
  Directed visNetwork of `[[...]]`-style wikilinks. `only_internal = TRUE`
  (default) shows only links within the supplied article set;
  `only_internal = FALSE` adds the top external link targets. Node size reflects
  in-degree.

Three unexported helper functions (`*.build_pubnet_data`, `.build_cocite_data`,
`.build_wikilink_data`) separate data construction from rendering to enable
unit-testing without a network connection.

## Dependency additions

* Added `plotly` to Imports (interactive timeline).
* Added `visNetwork` to Imports (all three network functions).

---

# wikilite 0.1.0

## Initial release

wikilite consolidates and extends the functionality of **WikiCitationHistoRy**
into a single CRAN-ready package.

### New features

* `get_revert_counts()` — retrieve the daily count of revert-tagged edits
  (undo / rollback) for every English Wikipedia article, sourced from the
  Wikitrends module.

### Improvements over WikiCitationHistoRy

* Renamed `Get_sci_score()` → `get_sci_score()`, `Get_sci_score2()` →
  `get_sci_score2()`, `Get_source_type_counts()` → `get_source_type_counts()`,
  and `get_paresd_citations()` → `get_parsed_citations()` for consistent
  snake_case naming.
* Replaced the archived `xlsx` / `rJava` dependency with `openxlsx`
  (pure R, cross-platform).
* Removed unused archived packages: `timevis`, `textreuse`, `ggridges`,
  `gridExtra`, `scales`, `curl`, `XML`.
* `plot_navi_timeline()` now issues an informative message instead of failing
  silently when `timevis` is unavailable.
* All examples that require a network connection are wrapped in `\dontrun{}`.
* Comprehensive `testthat` edition 3 test suite (all network tests guarded by
  `skip_on_cran()`).
* Three vignettes covering introduction, citation analysis, and annotation
  workflows.

### Bug fixes

* Fixed typo in edit-tag filter: `"mv-rollback"` → `"mw-rollback"`.
