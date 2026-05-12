# Build an interactive Gantt-style timeline for a list of Wikipedia articles

For each article in `articles`, the function retrieves the creation
revision and the most recent revision, then renders an interactive
plotly figure showing each article as a horizontal bar spanning its edit
lifetime. Hover text includes creation date, first editor, initial and
current byte size, and a clickable link to the Wikipedia page.

## Usage

``` r
plot_interactive_timeline(
  articles,
  date_an = NULL,
  lang = "en",
  color_by = c("sciscore", "size", "none")
)
```

## Arguments

- articles:

  Character vector of English Wikipedia article titles.

- date_an:

  Character string. Upper date limit for revision queries in ISO 8601
  format (default: current UTC time).

- lang:

  Two-letter Wikipedia language code (default `"en"`).

- color_by:

  One of `"sciscore"` (colour bars by SciScore, default), `"size"`
  (colour by current article size), or `"none"` (uniform colour).

## Value

A `plotly` htmlwidget.

## Examples

``` r
# \donttest{
articles <- c("Zeitgeber", "Advanced sleep phase disorder",
              "Sleep deprivation", "Circadian rhythm")
plot_interactive_timeline(articles)
# }
```
