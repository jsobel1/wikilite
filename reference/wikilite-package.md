# wikilite: Retrieve, Parse, and Analyse Wikipedia Article History and Citations

\*\*wikilite\*\* is a toolkit for mining Wikipedia article revision
history and citations via the public MediaWiki API. Core capabilities:

- History retrieval:

  Full or partial revision histories for one or many articles via
  [`get_article_full_history_table`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md),
  [`get_article_initial_table`](https://jsobel1.github.io/wikilite/reference/get_article_initial_table.md),
  [`get_article_most_recent_table`](https://jsobel1.github.io/wikilite/reference/get_article_most_recent_table.md).

- Category navigation:

  [`get_pagename_in_cat`](https://jsobel1.github.io/wikilite/reference/get_pagename_in_cat.md),
  [`get_subcat_table`](https://jsobel1.github.io/wikilite/reference/get_subcat_table.md),
  [`get_subcat_with_depth`](https://jsobel1.github.io/wikilite/reference/get_subcat_with_depth.md)
  and related helpers.

- Citation extraction:

  Built-in regular expressions for DOIs, ISBNs, PMIDs, URLs, and all
  Citation Style 1 templates, accessible via
  [`get_regex_citations_in_wiki_table`](https://jsobel1.github.io/wikilite/reference/get_regex_citations_in_wiki_table.md)
  or
  [`extract_citations_regexp`](https://jsobel1.github.io/wikilite/reference/extract_citations_regexp.md).

- Citation parsing:

  [`parse_article_ALL_citations`](https://jsobel1.github.io/wikilite/reference/parse_article_ALL_citations.md)
  parses every CS1 template into a tidy long data frame; counting
  helpers
  ([`get_doi_count`](https://jsobel1.github.io/wikilite/reference/get_doi_count.md),
  [`get_refCount`](https://jsobel1.github.io/wikilite/reference/get_refCount.md),
  …) provide fast scalar summaries.

- Quality metrics:

  [`get_sci_score`](https://jsobel1.github.io/wikilite/reference/get_sci_score.md)
  (proportion of journal citations).

- Annotation:

  [`annotate_doi_list_europmc`](https://jsobel1.github.io/wikilite/reference/annotate_doi_list_europmc.md),
  [`annotate_doi_list_cross_ref`](https://jsobel1.github.io/wikilite/reference/annotate_doi_list_cross_ref.md),
  [`annotate_doi_list_altmetrics`](https://jsobel1.github.io/wikilite/reference/annotate_doi_list_altmetrics.md),
  [`annotate_isbn_google`](https://jsobel1.github.io/wikilite/reference/annotate_isbn_google.md),
  [`annotate_isbn_openlib`](https://jsobel1.github.io/wikilite/reference/annotate_isbn_openlib.md).

- Revert trends:

  [`get_revert_counts`](https://jsobel1.github.io/wikilite/reference/get_revert_counts.md)
  retrieves the count of revert-tagged edits across all Wikipedia
  articles for a given time window.

- Visualisation:

  Timelines, edit-activity plots, and citation distribution charts built
  on ggplot2.

## Built-in regular expressions

The package-level environment
[`pkg.env`](https://jsobel1.github.io/wikilite/reference/pkg.env.md)
contains all pre-built patterns. Access via `pkg.env$doi_regexp`,
`pkg.env$regexp_list`, etc.

## See also

Useful links:

- <https://github.com/jsobel1/wikilite>

- Report bugs at <https://github.com/jsobel1/wikilite/issues>

## Author

**Maintainer**: Jonathan Sobel <jsobel83@gmail.com>
([ORCID](https://orcid.org/0000-0002-5111-4070))
