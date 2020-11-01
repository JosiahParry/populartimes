
<!-- README.md is generated from README.Rmd. Please edit that file -->

# populartimes

<!-- badges: start -->

<!-- badges: end -->

populartimes is an R translation of the wonderful python
[library](https://github.com/m-wrzr/populartimes) of the same name.

populartimes provides access to the Google Places nearby and detail API
endpoints. It goes a step further and retrieves popular time data if
available and requested.

The use of the popular times data is questionable legally. Please see
[issue \#90](https://github.com/m-wrzr/populartimes/issues/90) of the
original library. Please be thoughtful with your use of this library and
do not abuse it.

Note that this library requires the use of a Google Places API. There is
a limit on the number of free queries you can make. I believe this is
1,000 in a single 24 hour period.

## Installation

You can install the development version of populartimes from with:

``` r
# install.packages("remotes")
remotes::install_github("JosiahParry/populartimes")
```

In order to use the majority of the functionality of this package,
ensure that you have a Google API key from
<https://console.cloud.google.com/>. Ensure Places API is enabled.

The easiest way to utilize this is by setting the environment variable
`GOOGLE_KEY` to your key value. For example `Sys.setenv("GOOGLE_KEY" =
"your-key-value")` or by using an .Renviron file. You can get a key by
following [these
instructions](https://developers.google.com/places/web-service/get-api-key).

## Example

### Search an area for popular times

`search_pop_times()` works by creating a search grid of overlapping
circles with a radius specified in meters by the `radius` argument
(default of 180 meters). Each circle centroid is used to search the
Google Places Nearby API and returns up to 60 results each. The denser
the area, the smaller the radius should be. This also means that the
smaller your search radius, the more API queries will be made. Be
careful as you can be bulled for going over your limit\!

There are two required arguments for `search_pop_times()`: `sw`, and
`ne`. These are a numeric vector length two with the format of `c(lat,
long)` indicating the southwest and northeastern corners of a bounding
box. Please note that this must be in EPSG 4326 (aka decimal degrees).

Optionally you can specify a type of place to search. If you do this,
only one place can be searched for at a time. Please see the [API
docs](https://developers.google.com/places/web-service/supported_types)
for supported place types.

``` r
library(populartimes)
library(tidyverse)

sw <- c(42.988690, -71.465834)
ne <- c(42.995119, -71.455745)

manch_bars <- search_pop_times(sw, ne, radius = 200, type = "bar")
```

The popular times are stored in a list column where each value is a
tibble. To access the popular times, you can unnest the column. See the
below example for unnesting the popular times for a single bar. Be aware
that popular times are provided in UTC time zone.

Note: the Thirsty Moose has a great mimosa deal during brunch on the
weekends.

``` r
manch_bars %>% 
  filter(name == "Thirsty Moose Taphouse Manchester") %>% 
  unnest(popular_times) %>% 
  ggplot(aes(hour, popularity)) +
  geom_col() + 
  facet_wrap(c("day_of_week"), ncol = 1)
  
```

You can access the centroids used in the centroid by grabbing the
`search_grid` attribute of the resultant object—e.g. `attr(x,
"search_grid")` will return a data frame containing the lat long.

``` r
attr(manch_bars, "search_grid") %>% 
  ggplot(aes(lon, lat)) +
  geom_point()
```

### Search for a place by name and address

``` r
poptimes_from_address("McDonald", "Helmstraat 16, 6211 TA Maastricht, Netherlands")
```

### Search an area for places

Note that `get_places()` does not implement a grid search. You are
limited to the nearest 60 results regardless of radius.

``` r
get_places(ne, radius = 200)
```

#### Get popular times for a given place

``` r
get_popular_times("ChIJywwlXCZP4okRQTupAgSLMSI") %>% 
  select(name, popular_times)
```
