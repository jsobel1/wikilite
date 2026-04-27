# Annotate a DOI list and export as a BibTeX file

Queries CrossRef for each DOI in `doi_list`, then writes the results to
a BibTeX file.

## Usage

``` r
export_doi_to_bib(doi_list, file_name = "file.bib")
```

## Arguments

- doi_list:

  Character vector of DOIs.

- file_name:

  Output file name (default: `"file.bib"`).

## Value

Invisibly returns `NULL`. Called for its side effect of writing a file.

## Examples

``` r
if (FALSE) { # \dontrun{
category_recent <- get_category_articles_most_recent(
  c("Zeitgeber", "Advanced sleep phase disorder")
)
extracted <- get_regex_citations_in_wiki_table(
  category_recent,
  "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+"
)
export_doi_to_bib(unique(extracted$citation_fetched)[1:5], "output.bib")
} # }
```
