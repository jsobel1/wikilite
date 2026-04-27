# Find the closest date in a vector to a reference date

Utility used for aligning paper publication dates to Wikipedia revision
snapshots.

## Usage

``` r
get_closest_date(date_in, date_vect)
```

## Arguments

- date_in:

  A `Date` or date-coercible value.

- date_vect:

  A vector of `Date` values.

## Value

The element of `date_vect` closest in time to `date_in`.

## Examples

``` r
dates <- as.Date(c("2020-01-01", "2020-06-01", "2021-01-01"))
get_closest_date(as.Date("2020-04-15"), dates)
#> [1] "2020-06-01"
```
