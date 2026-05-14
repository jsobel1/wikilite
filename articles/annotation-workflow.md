# Annotation Workflow

## Overview

Once you have extracted DOIs, ISBNs, or PMIDs from Wikipedia wikitext,
the next step is to enrich them with bibliographic metadata and citation
counts. **wikilite** provides four annotation pathways:

| Database | DOI | ISBN | Function |
|----|----|----|----|
| EuropePMC | ✓ | — | [`annotate_doi_list_europmc()`](https://jsobel1.github.io/wikilite/reference/annotate_doi_list_europmc.md) |
| CrossRef | ✓ | — | [`annotate_doi_list_cross_ref()`](https://jsobel1.github.io/wikilite/reference/annotate_doi_list_cross_ref.md), [`annotate_doi_to_bibtex_cross_ref()`](https://jsobel1.github.io/wikilite/reference/annotate_doi_to_bibtex_cross_ref.md) |
| Google Books | — | ✓ | [`annotate_isbn_google()`](https://jsobel1.github.io/wikilite/reference/annotate_isbn_google.md) |
| Open Library | — | ✓ | [`annotate_isbn_openlib()`](https://jsobel1.github.io/wikilite/reference/annotate_isbn_openlib.md) |

## Setup

``` r

library(wikilite)

# Fetch the most recent revision of a test article
recent <- get_article_most_recent_table("Zeitgeber")
text   <- recent$`*`
```

## Extract identifiers

``` r

# DOIs
doi_df   <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
doi_list <- unique(doi_df$citation_fetched)
cat("Found", length(doi_list), "unique DOIs\n")
#> Found 13 unique DOIs

# ISBNs
isbn_df   <- get_regex_citations_in_wiki_table(recent, pkg.env$isbn_regexp)
isbn_list <- unique(isbn_df$citation_fetched)
cat("Found", length(isbn_list), "unique ISBNs\n")
#> Found 0 unique ISBNs
```

## Annotate DOIs with EuropePMC

EuropePMC is open-access, returns rich open-access status and citation
counts, and is the recommended first-pass annotation service.

``` r

# Annotate the first 5 DOIs
epmc_results <- annotate_doi_list_europmc(doi_list[1:5])

# Useful columns: title, authorString, journalTitle, pubYear, citedByCount
head(epmc_results[, c("doi", "title", "journalTitle", "pubYear",
                      "citedByCount", "isOpenAccess")])
#>                                    doi
#> 1 10.1001/archpsyc.1988.01800340076012
#> 2            10.1016/j.cpr.2006.07.001
#> 3            10.1016/j.cub.2006.12.011
#> 4         10.1016/0031-9384(92)90188-8
#> 5  10.47102/annals-acadmedsg.v37n8p662
#>                                                                                                       title
#> 1 Social zeitgebers and biological rhythms. A unified approach to understanding the etiology of depression.
#> 2                The social zeitgeber theory, circadian rhythms, and mood disorders: review and evaluation.
#> 3                                                           The human circadian clock entrains to sun time.
#> 4                                                                 The circadian rhythm of body temperature.
#> 5                           Basic science review on circadian rhythm biology and circadian sleep disorders.
#>          journalTitle pubYear citedByCount isOpenAccess
#> 1 Arch Gen Psychiatry    1988          368            N
#> 2    Clin Psychol Rev    2006          242            N
#> 3           Curr Biol    2007          258            N
#> 4       Physiol Behav    1992          398            N
#> 5 Ann Acad Med Singap    2008           18            N
```

## Annotate DOIs with CrossRef

CrossRef provides comprehensive bibliographic metadata and is the
authoritative source for DOI resolution.

``` r

crossref_results <- annotate_doi_list_cross_ref(doi_list[1:5])
head(crossref_results)
#>                                    doi
#> 1 10.1001/archpsyc.1988.01800340076012
#> 2            10.1016/j.cpr.2006.07.001
#> 3            10.1016/j.cub.2006.12.011
#> 4         10.1016/0031-9384(92)90188-8
#> 5  10.47102/annals-acadmedsg.v37n8p662
#>                                                                                       title
#> 1                                                  Social Zeitgebers and Biological Rhythms
#> 2 The social zeitgeber theory, circadian rhythms, and mood disorders: Review and evaluation
#> 3                                            The human circadian clock entrains to sun time
#> 4                                                  The circadian rhythm of body temperature
#> 5            Basic Science Review on Circadian Rhythm Biology and Circadian Sleep Disorders
#>                                             authorString
#> 1                                       Ehlers, Cindy L.
#> 2 Grandin, Louisa D.; Alloy, Lauren B.; Abramson, Lyn Y.
#> 3     Roenneberg, Till; Kumar, C. Jairaj; Merrow, Martha
#> 4                   Refinetti, Roberto; Menaker, Michael
#> 5                                        Toh, Kong Leong
#>                                   journalTitle pubYear         pubType
#> 1               Archives of General Psychiatry    1988 journal-article
#> 2                   Clinical Psychology Review    2006 journal-article
#> 3                              Current Biology    2007 journal-article
#> 4                    Physiology &amp; Behavior    1992 journal-article
#> 5 Annals of the Academy of Medicine, Singapore    2008 journal-article
#>                            publisher      issn volume issue    page
#> 1 American Medical Association (AMA) 0003-990X     45    10     948
#> 2                        Elsevier BV 0272-7358     26     6 679-694
#> 3                        Elsevier BV 0960-9822     17     2 R44-R45
#> 4                        Elsevier BV 0031-9384     51     3 613-637
#> 5     Academy of Medicine, Singapore 0304-4602     37     8 662-668
#>   citedByCount
#> 1          545
#> 2          324
#> 3          386
#> 4          568
#> 5           46
```

Retrieve BibTeX entries directly:

``` r

bibtex_entries <- annotate_doi_to_bibtex_cross_ref(doi_list[1:3])
#>   |                                                                              |                                                                      |   0%  |                                                                              |=======================                                               |  33%  |                                                                              |===============================================                       |  67%  |                                                                              |======================================================================| 100%
cat(bibtex_entries[[1]])
#>  @article{Ehlers_1988, title={Social Zeitgebers and Biological Rhythms: A Unified Approach to Understanding the Etiology of Depression}, volume={45}, ISSN={0003-990X}, url={http://dx.doi.org/10.1001/archpsyc.1988.01800340076012}, DOI={10.1001/archpsyc.1988.01800340076012}, number={10}, journal={Archives of General Psychiatry}, publisher={American Medical Association (AMA)}, author={Ehlers, Cindy L.}, year={1988}, month=Oct, pages={948} }
```

Export to a `.bib` file:

``` r

export_doi_to_bib(doi_list[1:10], file_name = "zeitgeber_refs.bib")
#>   |                                                                              |                                                                      |   0%  |                                                                              |=======                                                               |  10%  |                                                                              |==============                                                        |  20%  |                                                                              |=====================                                                 |  30%  |                                                                              |============================                                          |  40%  |                                                                              |===================================                                   |  50%  |                                                                              |==========================================                            |  60%  |                                                                              |=================================================                     |  70%  |                                                                              |========================================================              |  80%  |                                                                              |===============================================================       |  90%  |                                                                              |======================================================================| 100%
```

## Identify the top-cited papers across multiple articles

[`get_top_cited_wiki_papers()`](https://jsobel1.github.io/wikilite/reference/get_top_cited_wiki_papers.md)
combines EuropePMC annotation and CrossRef citation counts to rank the
most impactful papers cited across your article set.

``` r

articles  <- c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
recent_all <- get_category_articles_most_recent(articles)
doi_all    <- get_regex_citations_in_wiki_table(recent_all, pkg.env$doi_regexp)

top40 <- get_top_cited_wiki_papers(doi_all)
head(top40[, c("title", "journalTitle", "pubYear",
               "wiki_count", "count", "cited_in_wiki_art")])
#>                                                                                                                                                    title
#> 1                                               Short sleep duration is associated with reduced leptin, elevated ghrelin, and increased body mass index.
#> 2 Should I study or should I go (to sleep)? The influence of test schedule on the sleep behavior of undergraduates and its association with performance.
#> 3                                                                                          Effects of caffeine on sleep quality and daytime functioning.
#> 4                                                                                                          Desynchronization of human circadian rhythms.
#> 5 Efficient and regular patterns of nighttime sleep are related to increased vulnerability to microsleeps following a single night of sleep restriction.
#> 6                                   Contrasting Effects of Sleep Restriction, Total Sleep Deprivation, and Sleep Timing on Positive and Negative Affect.
#>                journalTitle pubYear wiki_count count cited_in_wiki_art
#> 1                  PLoS Med    2004          1  1823 Sleep deprivation
#> 2                  PLoS One    2021          1     9 Sleep deprivation
#> 3 Risk Manag Healthc Policy    2018          1   112 Sleep deprivation
#> 4             Jpn J Physiol    1967          1   183         Zeitgeber
#> 5            Chronobiol Int    2013          1    18 Sleep deprivation
#> 6      Front Behav Neurosci    2022          1    26 Sleep deprivation
```

## Annotate ISBNs

### Google Books

Google Books returns metadata for most widely published books.

``` r

# Single ISBN
book_meta <- annotate_isbn_google("9780156031356")
book_meta[, c("title", "publisher", "publishedDate", "categories")]
#> NULL
```

### Open Library

Open Library is an alternative book database.

``` r

book_meta_ol <- annotate_isbn_openlib("9780156031356")
str(book_meta_ol)
#> 'data.frame':    1 obs. of  5 variables:
#>  $ ISBN9780156031356.bib_key      : chr "ISBN9780156031356"
#>  $ ISBN9780156031356.info_url     : chr "http://openlibrary.org/books/OL17246834M/Elephants_on_acid"
#>  $ ISBN9780156031356.preview      : chr "restricted"
#>  $ ISBN9780156031356.preview_url  : chr "https://archive.org/details/elephantsonacido0000boes"
#>  $ ISBN9780156031356.thumbnail_url: chr "https://covers.openlibrary.org/b/id/10346210-S.jpg"
```

## Revert-trend analysis

[`get_revert_counts()`](https://jsobel1.github.io/wikilite/reference/get_revert_counts.md)
queries all Wikipedia revisions in a time window and returns articles
ranked by their number of revert-tagged edits (undo / rollback). This is
useful for identifying disputed or frequently vandalized articles.

``` r

# One-hour window on 12 December 2018
reverts <- get_revert_counts(
  start = "20181212010000",
  end   = "20181212000000"
)

# Top 10 most reverted articles in that hour
head(reverts, 10)
#>                                                              art sum_nb_reverts
#> 1                                                       Figueroa              4
#> 2                                                    Radim Šimek              4
#> 3                                              Admiral Schofield              2
#> 4                                        Alex Oxlade-Chamberlain              2
#> 5                                                      Bad Bunny              2
#> 6                                                    Don Shirley              2
#> 7  European Cup and UEFA Champions League records and statistics              2
#> 8                                            Isosceles trapezoid              2
#> 9                                                    Killing Eve              2
#> 10                                                    Like terms              2
```

## Putting it all together

A typical full workflow:

``` r

# 1. Define your article list
articles <- get_pagename_in_cat("Circadian rhythm")

# 2. Fetch the most recent revision of each article
recent <- get_category_articles_most_recent(articles)

# 3. Extract DOIs
doi_df   <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
doi_list <- unique(doi_df$citation_fetched)

# 4. Annotate via EuropePMC
annotated <- annotate_doi_list_europmc(doi_list)

# 5. Find the top-cited papers
top_papers <- get_top_cited_wiki_papers(doi_df)

# 6. Export
openxlsx::write.xlsx(annotated,   "circadian_doi_annotated.xlsx")
openxlsx::write.xlsx(top_papers,  "circadian_top_papers.xlsx")
export_doi_to_bib(annotated$doi,  "circadian_refs.bib")
#>   |                                                                              |                                                                      |   0%
#>   |                                                                              |                                                                      |   1%  |                                                                              |=                                                                     |   1%
#>   |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |==                                                                    |   4%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |=======                                                               |  11%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |============                                                          |  18%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |==============                                                        |  21%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |================                                                      |  24%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  25%
#>   |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |=====================                                                 |  31%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |=======================                                               |  34%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%
#>   |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%
#>   |                                                                              |==========================                                            |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%
#>   |                                                                              |============================                                          |  39%  |                                                                              |============================                                          |  40%  |                                                                              |============================                                          |  41%
#>   |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================                                        |  44%  |                                                                              |===============================                                       |  44%  |                                                                              |===============================                                       |  45%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  46%  |                                                                              |=================================                                     |  47%
#>   |                                                                              |=================================                                     |  48%  |                                                                              |==================================                                    |  48%
#>   |                                                                              |==================================                                    |  49%
#>   |                                                                              |===================================                                   |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |===================================                                   |  51%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%
#>   |                                                                              |=====================================                                 |  54%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%
#>   |                                                                              |==========================================                            |  59%  |                                                                              |==========================================                            |  60%
#>   |                                                                              |==========================================                            |  61%  |                                                                              |===========================================                           |  61%
#>   |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |============================================                          |  64%  |                                                                              |=============================================                         |  64%
#>   |                                                                              |=============================================                         |  65%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%
#>   |                                                                              |===============================================                       |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%
#>   |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |=================================================                     |  71%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  72%  |                                                                              |===================================================                   |  73%
#>   |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  77%
#>   |                                                                              |======================================================                |  78%  |                                                                              |=======================================================               |  78%
#>   |                                                                              |=======================================================               |  79%
#>   |                                                                              |========================================================              |  79%  |                                                                              |========================================================              |  80%  |                                                                              |========================================================              |  81%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |==========================================================            |  84%  |                                                                              |===========================================================           |  84%
#>   |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%
#>   |                                                                              |=============================================================         |  86%  |                                                                              |=============================================================         |  87%
#>   |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |===============================================================       |  91%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |=================================================================     |  94%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%
#>   |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================|  99%  |                                                                              |======================================================================| 100%
```
