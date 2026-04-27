# Clear the wikilite disk cache

Deletes all cached API responses stored by wikilite. Subsequent calls to
API-backed functions will make fresh network requests.

## Usage

``` r
wiki_clear_cache()
```

## Value

`NULL` invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
wiki_clear_cache()
} # }
```
