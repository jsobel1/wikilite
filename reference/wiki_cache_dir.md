# Return the wikilite user cache directory

Returns (and creates if needed) the platform-appropriate user cache
directory for wikilite, as determined by
[`R_user_dir`](https://rdrr.io/r/tools/userdir.html).

## Usage

``` r
wiki_cache_dir()
```

## Value

Character string path to the cache directory (created if it does not
exist).

## Examples

``` r
if (FALSE) { # \dontrun{
wiki_cache_dir()
} # }
```
