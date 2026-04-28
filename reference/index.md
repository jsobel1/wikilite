# Package index

## Cache

Control the on-disk article cache.

- [`wiki_cache_dir()`](https://jsobel1.github.io/wikilite/reference/wiki_cache_dir.md)
  : Return the wikilite user cache directory
- [`wiki_clear_cache()`](https://jsobel1.github.io/wikilite/reference/wiki_clear_cache.md)
  : Clear the wikilite disk cache

## Retrieve article history

Download revision histories and metadata from the MediaWiki API. All
functions accept an optional `date_an` timestamp and `lang` edition.

- [`get_article_full_history_table()`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md)
  : Retrieve the full revision history of a Wikipedia article
- [`get_article_initial_table()`](https://jsobel1.github.io/wikilite/reference/get_article_initial_table.md)
  : Retrieve the first revision of a Wikipedia article
- [`get_article_most_recent_table()`](https://jsobel1.github.io/wikilite/reference/get_article_most_recent_table.md)
  : Retrieve the most recent revision of a Wikipedia article
- [`get_article_info_table()`](https://jsobel1.github.io/wikilite/reference/get_article_info_table.md)
  : Retrieve metadata for a Wikipedia article
- [`get_tables_initial_most_recent_full_info()`](https://jsobel1.github.io/wikilite/reference/get_tables_initial_most_recent_full_info.md)
  : Retrieve initial, most-recent, info, and full-history tables for a
  set of articles
- [`get_category_articles_creation()`](https://jsobel1.github.io/wikilite/reference/get_category_articles_creation.md)
  : Retrieve the creation revision for multiple Wikipedia articles
- [`get_category_articles_history()`](https://jsobel1.github.io/wikilite/reference/get_category_articles_history.md)
  : Retrieve the full revision history for multiple Wikipedia articles
- [`get_category_articles_most_recent()`](https://jsobel1.github.io/wikilite/reference/get_category_articles_most_recent.md)
  : Retrieve the most recent revision for multiple Wikipedia articles

## Navigate categories

Browse the Wikipedia category tree.

- [`get_pages_in_cat_table()`](https://jsobel1.github.io/wikilite/reference/get_pages_in_cat_table.md)
  : Retrieve pages in a Wikipedia category
- [`get_pagename_in_cat()`](https://jsobel1.github.io/wikilite/reference/get_pagename_in_cat.md)
  : Retrieve the names of pages belonging to a Wikipedia category
- [`get_page_in_cat_multiple()`](https://jsobel1.github.io/wikilite/reference/get_page_in_cat_multiple.md)
  : Retrieve pages for multiple Wikipedia categories
- [`get_subcat_table()`](https://jsobel1.github.io/wikilite/reference/get_subcat_table.md)
  : Retrieve subcategories of a Wikipedia category
- [`get_subcat_multiple()`](https://jsobel1.github.io/wikilite/reference/get_subcat_multiple.md)
  : Retrieve subcategories for multiple Wikipedia categories
- [`get_subcat_with_depth()`](https://jsobel1.github.io/wikilite/reference/get_subcat_with_depth.md)
  : Recursively retrieve subcategories up to a given depth

## Count citations

Fast regex-based counters. Each function takes a raw wikitext string and
returns an integer.

- [`get_doi_count()`](https://jsobel1.github.io/wikilite/reference/get_doi_count.md)
  : Count DOIs in wikitext

- [`get_refCount()`](https://jsobel1.github.io/wikilite/reference/get_refCount.md)
  :

  Count `<ref>` tags in wikitext

- [`get_hyperlinkCount()`](https://jsobel1.github.io/wikilite/reference/get_hyperlinkCount.md)
  : Count Wikipedia hyperlinks in wikitext

- [`get_urlCount()`](https://jsobel1.github.io/wikilite/reference/get_urlCount.md)
  : Count URLs in wikitext

- [`get_ISBN_count()`](https://jsobel1.github.io/wikilite/reference/get_ISBN_count.md)
  : Count ISBNs in wikitext

- [`get_anyCount()`](https://jsobel1.github.io/wikilite/reference/get_anyCount.md)
  : Count matches of an arbitrary regular expression in wikitext

## Extract & parse citations

Extract and classify Citation Style 1 (CS1) templates and hyperlinks.

- [`extract_citations()`](https://jsobel1.github.io/wikilite/reference/extract_citations.md)
  : Extract all Citation Style 1 templates from wikitext
- [`extract_citations_regexp()`](https://jsobel1.github.io/wikilite/reference/extract_citations_regexp.md)
  : Apply all built-in regular expressions to a Wikipedia revision table
- [`extract_wikihypelinks()`](https://jsobel1.github.io/wikilite/reference/extract_wikihypelinks.md)
  : Extract Wikipedia hyperlinks from wikitext
- [`replace_wikihypelinks()`](https://jsobel1.github.io/wikilite/reference/replace_wikihypelinks.md)
  : Replace Wikipedia hyperlinks with plain text
- [`get_regex_citations_in_wiki_table()`](https://jsobel1.github.io/wikilite/reference/get_regex_citations_in_wiki_table.md)
  : Extract regex matches from a Wikipedia revision table
- [`parse_article_ALL_citations()`](https://jsobel1.github.io/wikilite/reference/parse_article_ALL_citations.md)
  : Parse all Citation Style 1 templates in a wikitext string
- [`parse_cite_type()`](https://jsobel1.github.io/wikilite/reference/parse_cite_type.md)
  : Determine the type of a Citation Style 1 template
- [`classify_cite_type()`](https://jsobel1.github.io/wikilite/reference/classify_cite_type.md)
  : Map a raw CS1 cite type to a display category
- [`get_parsed_citations()`](https://jsobel1.github.io/wikilite/reference/get_parsed_citations.md)
  : Parse all CS1 citations across a Wikipedia revision table
- [`get_citation_type()`](https://jsobel1.github.io/wikilite/reference/get_citation_type.md)
  : Summarise citation types across a Wikipedia revision table
- [`get_source_type_counts()`](https://jsobel1.github.io/wikilite/reference/get_source_type_counts.md)
  : Count citations by CS1 source type

## Quality metrics

SciScore measures the fraction of citations that are peer-reviewed
journal articles.

- [`get_sci_score()`](https://jsobel1.github.io/wikilite/reference/get_sci_score.md)
  : Compute SciScore for a Wikipedia article
- [`get_top_cited_wiki_papers()`](https://jsobel1.github.io/wikilite/reference/get_top_cited_wiki_papers.md)
  : Identify the most-cited DOIs across a set of Wikipedia articles
- [`get_pdfs_top20source()`](https://jsobel1.github.io/wikilite/reference/get_pdfs_top20source.md)
  : Plot bar charts of the top 20 values for all citation source types

## Annotate DOIs

Enrich a list of DOIs with bibliographic metadata from external
databases (EuropePMC, CrossRef, Altmetric).

- [`annotate_doi_list_europmc()`](https://jsobel1.github.io/wikilite/reference/annotate_doi_list_europmc.md)
  : Annotate a list of DOIs using EuropePMC
- [`annotate_doi_list_cross_ref()`](https://jsobel1.github.io/wikilite/reference/annotate_doi_list_cross_ref.md)
  : Annotate a list of DOIs using CrossRef
- [`annotate_doi_list_altmetrics()`](https://jsobel1.github.io/wikilite/reference/annotate_doi_list_altmetrics.md)
  : Annotate a list of DOIs using Altmetric
- [`annotate_doi_to_bibtex_cross_ref()`](https://jsobel1.github.io/wikilite/reference/annotate_doi_to_bibtex_cross_ref.md)
  : Retrieve BibTeX entries for a list of DOIs via CrossRef

## Annotate ISBNs

Look up book metadata from Google Books, Open Library, and Altmetric.

- [`annotate_isbn_google()`](https://jsobel1.github.io/wikilite/reference/annotate_isbn_google.md)
  : Annotate a single ISBN using the Google Books API
- [`annotate_isbn_openlib()`](https://jsobel1.github.io/wikilite/reference/annotate_isbn_openlib.md)
  : Annotate a single ISBN using the Open Library API
- [`annotate_isbn_list_altmetrics()`](https://jsobel1.github.io/wikilite/reference/annotate_isbn_list_altmetrics.md)
  : Annotate a list of ISBNs using Altmetric

## Citation latency

Measure how long after publication a paper first appears in Wikipedia,
and visualise the distribution.

- [`compute_citation_latency()`](https://jsobel1.github.io/wikilite/reference/compute_citation_latency.md)
  : Compute citation latency between Wikipedia insertion and first
  publication
- [`plot_latency_distribution()`](https://jsobel1.github.io/wikilite/reference/plot_latency_distribution.md)
  : Plot the distribution of citation latency
- [`get_segment_history_doi_plot()`](https://jsobel1.github.io/wikilite/reference/get_segment_history_doi_plot.md)
  : Plot DOI latency as horizontal segments
- [`get_dotplot_history()`](https://jsobel1.github.io/wikilite/reference/get_dotplot_history.md)
  : Dot plot of DOI citation insertions over time

## Visualise history

ggplot2 charts for edit activity, page-view trends, and source
composition.

- [`plot_article_creation_per_year()`](https://jsobel1.github.io/wikilite/reference/plot_article_creation_per_year.md)
  : Plot article creation dates over time
- [`plot_distribution_source_type()`](https://jsobel1.github.io/wikilite/reference/plot_distribution_source_type.md)
  : Plot the distribution of citation source types
- [`plot_top_source()`](https://jsobel1.github.io/wikilite/reference/plot_top_source.md)
  : Plot the top 20 values for a given citation field
- [`page_edit_plot()`](https://jsobel1.github.io/wikilite/reference/page_edit_plot.md)
  : Plot weekly edit counts for a Wikipedia article
- [`page_view_plot()`](https://jsobel1.github.io/wikilite/reference/page_view_plot.md)
  : Plot daily Wikipedia page views for an article
- [`get_edits_vs_time_plot()`](https://jsobel1.github.io/wikilite/reference/get_edits_vs_time_plot.md)
  : Plot yearly edit counts for a Wikipedia article
- [`get_size_vs_time_plot()`](https://jsobel1.github.io/wikilite/reference/get_size_vs_time_plot.md)
  : Plot article size over time

## Interactive timelines & networks

plotly timelines and three visNetwork graph types for multi-article
comparison.

- [`plot_interactive_timeline()`](https://jsobel1.github.io/wikilite/reference/plot_interactive_timeline.md)
  : Build an interactive Gantt-style timeline for a list of Wikipedia
  articles
- [`plot_navi_timeline()`](https://jsobel1.github.io/wikilite/reference/plot_navi_timeline.md)
  : Plot an interactive timeline of article creation dates
- [`plot_static_timeline()`](https://jsobel1.github.io/wikilite/reference/plot_static_timeline.md)
  : Plot a static timeline of article creation dates
- [`plot_article_cocitation_network()`](https://jsobel1.github.io/wikilite/reference/plot_article_cocitation_network.md)
  : Build an interactive article co-citation network
- [`plot_article_publication_network()`](https://jsobel1.github.io/wikilite/reference/plot_article_publication_network.md)
  : Build an interactive article-publication bipartite network
- [`plot_article_wikilink_network()`](https://jsobel1.github.io/wikilite/reference/plot_article_wikilink_network.md)
  : Build an interactive article-article wikilink network

## Edit trends

Detect revert-tagged edits and identify disputed articles.

- [`get_revert_counts()`](https://jsobel1.github.io/wikilite/reference/get_revert_counts.md)
  : Count revert-tagged edits per article for a time window
- [`get_closest_date()`](https://jsobel1.github.io/wikilite/reference/get_closest_date.md)
  : Find the closest date in a vector to a reference date

## Export

Write results to Excel or BibTeX files.

- [`export_doi_to_bib()`](https://jsobel1.github.io/wikilite/reference/export_doi_to_bib.md)
  : Annotate a DOI list and export as a BibTeX file
- [`export_extracted_citations_xlsx()`](https://jsobel1.github.io/wikilite/reference/export_extracted_citations_xlsx.md)
  : Export all built-in regex matches to separate xlsx files
- [`write_wiki_history_to_xlsx()`](https://jsobel1.github.io/wikilite/reference/write_wiki_history_to_xlsx.md)
  : Write an article revision table to an xlsx file

## Internals

Package-level environment holding compiled regular expressions.

- [`pkg.env`](https://jsobel1.github.io/wikilite/reference/pkg.env.md) :
  Built-in regular expressions for citation extraction
- [`wikilite-package`](https://jsobel1.github.io/wikilite/reference/wikilite-package.md)
  [`wikilite`](https://jsobel1.github.io/wikilite/reference/wikilite-package.md)
  : wikilite: Retrieve, Parse, and Analyse Wikipedia Article History and
  Citations
