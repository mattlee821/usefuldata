# Interactive Datasets

``` r

library(usefuldata)
library(DT)
```

## Olink Mapping

``` r

DT::datatable(mapping_GRCh38_p14_olink, options = list(scrollX = TRUE))
#> Warning in instance$preRenderHook(instance): It seems your data is too big for
#> client-side DataTables. You may consider server-side processing:
#> https://rstudio.github.io/DT/server.html
```

## SomaLogic Mapping

``` r

DT::datatable(mapping_GRCh38_p14_somalogic, options = list(scrollX = TRUE))
#> Warning in instance$preRenderHook(instance): It seems your data is too big for
#> client-side DataTables. You may consider server-side processing:
#> https://rstudio.github.io/DT/server.html
```
