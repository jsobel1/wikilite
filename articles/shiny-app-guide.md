# Wikipedia History Flow — Shiny App Guide

## Overview

The **Wikipedia History Flow** Shiny app is an interactive tool for
exploring a Wikipedia article’s revision history, citation structure,
editor behaviour, stability, and vandalism patterns. It is located at
`history-flow-analysis/shiny_app/app.R`.

## Launching the app

``` r

# From R console, inside the project directory:
shiny::runApp("history-flow-analysis/shiny_app")

# Or from the app directory directly:
setwd("history-flow-analysis/shiny_app")
shiny::runApp()
```

**Required packages:**

``` r

install.packages(c(
  "shiny", "dplyr", "tidyr", "ggplot2", "plotly",
  "echarts4r", "jsonlite", "scales", "htmltools",
  "DT", "openxlsx", "visNetwork"
))

# For BibTeX export via CrossRef:
install.packages("rcrossref")
```

## Control bar

At the top of the app, enter:

| Control         | Description                                          |
|-----------------|------------------------------------------------------|
| **Article**     | Wikipedia article title (e.g. `Zeitgeber`)           |
| **Language**    | Wikipedia language edition (`en`, `fr`, `de`, …)     |
| **From / To**   | Date range filter for the revision history           |
| **Min Δ bytes** | Filter out micro-edits smaller than this byte change |
| **Top N**       | Maximum number of authors to colour individually     |
| **Fetch →**     | Download and process the revision history            |

Click **Fetch →** before any other tab will populate. For articles with
tens of thousands of revisions (e.g. `COVID-19`), the first fetch may
take 30–60 seconds. Subsequent date-range changes are instant because
the data is cached locally.

------------------------------------------------------------------------

## History Flow tab

Replicates the Microsoft History Flow visualisation (Viégas et al.,
2004). Each coloured stream represents one editor’s contribution over
time.

**Left panel — Author list:** - Each chip shows the editor’s name,
colour swatch, and edit count. - Toggle individual editors on/off with
the switch. - Editors toggled off are merged into the “Others” stream. -
Click the colour swatch to change an editor’s colour.

**Centre — History Flow chart:** - The x-axis is time; the y-axis is the
article’s byte length. - Stream width = bytes attributed to that author
in each revision. - Hover over a stream to see the revision date and
editor.

**Right panel:** - **Revision selector** — pick any revision to
inspect. - **Text (coloured by author)** — wikitext coloured by the
first author who introduced each line. - **Changes vs. previous
revision** — diff panel showing additions (green) and removals (red).

------------------------------------------------------------------------

## Citation Analysis tab

Tracks every `<ref>…</ref>` citation across sampled revisions.

### Setup

1.  Choose the **Status** filter (active citations, all, additions only,
    or removed).
2.  Choose a **Reference type** filter.
3.  Set the **\# snapshots** (3–30 revisions to sample; more = slower
    but more accurate).
4.  Click **Analyse Citations** — the app fetches wikitext for each
    snapshot.

### SciScore gauge

After analysis, four metric cards appear:

| Card | Meaning |
|----|----|
| **SciScore — journal%** | Fraction of active citations that use `{{cite journal}}` |
| **DOI coverage%** | Fraction of active citations that contain a DOI |
| **Journal refs** | Raw count of `{{cite journal}}` citations |
| **DOI-linked refs** | Raw count of citations with a DOI |

### Citation timeline

A horizontal segment plot: each row is a unique citation, segments span
from when the citation first appeared to when it was last seen. Active
citations are bold; removed citations are faded. Hover for details.

### Citation table

An interactive table with clickable links: - **DOIs** link to
`doi.org` - **URLs** link directly - **ISBNs** link to WorldCat - After
annotating with EuropePMC, extra columns appear: **Journal**, **Year**,
**OA** (open-access flag), **Citations** (times cited).

### Buttons

| Button | Action |
|----|----|
| **Analyse Citations** | Fetch wikitext snapshots and build the citation matrix |
| **Annotate with EuropePMC** | Query EuropePMC for all DOIs; enriches the table |
| **⬇ XLSX** | Export the citation table to Excel |
| **⬇ BibTeX** | Export all DOIs to a `.bib` file (requires `rcrossref`) |
| **Compute Citation Latency** | Calculate days from paper publication to Wikipedia insertion |

### Citation latency panel

After clicking **Compute Citation Latency**: - **Left plot** — Density
distribution of latency in days, stratified by preprint
(bioRxiv/medRxiv) vs. journal article. Includes a KS-test p-value. -
**Right plot** — Segment plot: each DOI shown as a line from its
publication date (navy dot) to its Wikipedia insertion date (red
triangle).

------------------------------------------------------------------------

## Authorship tab

Quantifies editor contributions.

| Metric card | Meaning |
|----|----|
| Revisions | Total revisions in the filtered date range |
| Editors | Number of unique editors |
| Anonymous | Fraction of edits by IP addresses |
| Gini | Inequality of edit distribution (0 = equal, 1 = one editor) |
| Top editor | Most prolific editor |
| Top editor share | Fraction of revisions by the top editor |

**Plots:** - Registered vs. anonymous edit history - Top N editor bar
chart - Cumulative unique-editor growth over time

**Editor breakdown table** — sortable table with all editors, edit
counts, and date of first/last edit. Download via **⬇ XLSX**.

------------------------------------------------------------------------

## Stability tab

Measures how much the article changes over time.

| Metric card    | Meaning                                     |
|----------------|---------------------------------------------|
| Current size   | Latest revision size in bytes               |
| Max size       | Largest revision ever                       |
| Median Δ bytes | Median absolute byte change per edit        |
| Revert rate    | Fraction of edits that undo a previous edit |

**Plots:** - Article size over time (line) - Edit size distribution
(histogram of Δ bytes) - Edit rhythm heatmap (day-of-week × hour-of-day)

Download the full revision history via **⬇ Revision history XLSX**.

------------------------------------------------------------------------

## Vandalism & Wars tab

Identifies potentially damaging edits and edit-war episodes.

| Metric card           | Meaning                                    |
|-----------------------|--------------------------------------------|
| Vandalism events      | Edits classified as likely vandalism       |
| Repaired              | Events followed by a revert                |
| Median repair time    | How quickly vandalism is removed           |
| Edit war episodes     | Clusters of mutual reverts between editors |
| Total reverts in wars | Sum of reverts across all war episodes     |

**Plots:** - Vandalism timeline (interactive; hover for details) -
Survival curve (how long vandalism persists before removal) - Edit war
heatmap

**Edit war table** — each episode with start date, end date, duration,
number of reverts, and the editors involved. Download via **⬇ XLSX**.

------------------------------------------------------------------------

## Multi-Article tab

Compare multiple Wikipedia articles simultaneously.

1.  Enter one article title per line in the text area.
2.  Choose the language edition.
3.  Choose the timeline colour metric (SciScore, size, or none).
4.  Click **Fetch →**.

Four sub-tabs are populated:

| Sub-tab | Visualisation |
|----|----|
| Timeline | Interactive Gantt chart (article lifespan + colour metric) |
| Co-citation Network | Articles sharing DOIs are connected by edges |
| Publication Network | Bipartite: articles ↔︎ DOIs they cite |
| Wikilink Network | Directed links between articles in your list |

All networks are interactive (drag, zoom, click-to-open).

------------------------------------------------------------------------

## Category Explorer tab

Browse the Wikipedia category tree and batch-load articles into
Multi-Article.

1.  Type a Wikipedia category name (e.g. `Circadian rhythm`).
2.  Choose the language edition.
3.  Click **Browse Category**.

The panel shows: - A count of articles and subcategories. - Clickable
article list (links open the Wikipedia page). - Subcategory table (click
a row to drill down by re-entering the name).

Click **→ Send to Multi-Article tab** to populate the Multi-Article text
area with all articles in the category and switch to that tab
automatically.

------------------------------------------------------------------------

## Tips for large articles

- **Set a narrow date range** (`From`/`To`) to limit the number of
  revisions loaded.
- **Reduce `# snapshots`** in Citation Analysis (10 is usually enough
  for a quick overview; 25–30 for publication-quality results).
- **Use the cache** — the first `Fetch` for an article is slow;
  subsequent calls with the same article name are instant.
- The app caps at **5 000 revisions** in memory; for very active
  articles (e.g. `COVID-19`) narrow the date range.

------------------------------------------------------------------------

## Keyboard shortcuts

| Key                        | Action                       |
|----------------------------|------------------------------|
| `Enter` (in Article field) | Equivalent to clicking Fetch |

------------------------------------------------------------------------

## File outputs

| Button          | File name pattern          | Format |
|-----------------|----------------------------|--------|
| Citation XLSX   | `{Article}_citations.xlsx` | Excel  |
| Citation BibTeX | `{Article}_citations.bib`  | BibTeX |
| Editor XLSX     | `{Article}_editors.xlsx`   | Excel  |
| History XLSX    | `{Article}_history.xlsx`   | Excel  |
| Vandalism XLSX  | `{Article}_vandalism.xlsx` | Excel  |
| Edit wars XLSX  | `{Article}_edit_wars.xlsx` | Excel  |
