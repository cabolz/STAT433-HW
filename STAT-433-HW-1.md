STAT 433 HW 1
================
Caitlin Bolz
2/3/2021

``` r
library(readr)
library(data.table)
```

I choose a smaller dataset to work with so I could easily read and
interpret the file. Once I apply my findings, this code can be used for
other bridge data sets by simply changing the link in the read.csv
command.

I intially started reading in the data with the read.csv, read\_csv, and
fread commands. All three of these commands produced 24 obs. of 123
variables.

``` r
bridges. = read.csv("https://www.fhwa.dot.gov/bridge/nbi/2019/delimited/VI19.txt")

bridges_ = read_csv("https://www.fhwa.dot.gov/bridge/nbi/2019/delimited/VI19.txt")
```

    ## 
    ## -- Column specification --------------------------------------------------------
    ## cols(
    ##   .default = col_double(),
    ##   STRUCTURE_NUMBER_008 = col_character(),
    ##   ROUTE_NUMBER_005D = col_character(),
    ##   HIGHWAY_DISTRICT_002 = col_logical(),
    ##   COUNTY_CODE_003 = col_character(),
    ##   PLACE_CODE_004 = col_character(),
    ##   FEATURES_DESC_006A = col_character(),
    ##   CRITICAL_FACILITY_006B = col_logical(),
    ##   FACILITY_CARRIED_007 = col_character(),
    ##   LOCATION_009 = col_character(),
    ##   LRS_INV_ROUTE_013A = col_logical(),
    ##   SUBROUTE_NO_013B = col_logical(),
    ##   LONG_017 = col_character(),
    ##   MAINTENANCE_021 = col_character(),
    ##   OWNER_022 = col_character(),
    ##   FUNCTIONAL_CLASS_026 = col_character(),
    ##   ADT_029 = col_logical(),
    ##   YEAR_ADT_030 = col_logical(),
    ##   RAILINGS_036A = col_character(),
    ##   TRANSITIONS_036B = col_character(),
    ##   APPR_RAIL_036C = col_character()
    ##   # ... with 39 more columns
    ## )
    ## i Use `spec()` for the full column specifications.

``` r
bridgesf = fread("https://www.fhwa.dot.gov/bridge/nbi/2019/delimited/VI19.txt")
```
