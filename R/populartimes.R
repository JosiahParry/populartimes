
#' Query Google Place Detail API 
#' 
#' @param place_id Google place ID. See [docs](https://developers.google.com/maps/documentation/javascript/examples/places-placeid-finder) for app to provide place ID.
#' @param key Google API key from https://console.cloud.google.com/. Ensure Places API is enabled. 
#' @importFrom httr GET content
#' @export
get_place_details <- function(place_id, key = Sys.getenv("GOOGLE_KEY")) {
  res <- httr::GET(gen_query_url(placeid))
  place_detail <- httr::content(res)
}


#' Search for Google popular times
#' 
#' @inheritParams get_place_details
#' @importFrom glue glue
#' @importFrom httr content
#' @export
get_popular_times <- function(place_id, key = Sys.getenv("GOOGLE_KEY")) {
  
  place_detail <- get_place_details(place_id)
  # Web-scraping part -----------------------------------------------------
  # I accidentally had test.txt there because I was trying to download the file instead. 
  # that didn't work so I tried a get request. That apparently only works with a test.txt file.
  # When you remove it it doesn't work
  # alternatively a call to xml2::read_html() _does_ work
  # changed URL to add tz param 
  q <- GET(glue::glue("https://www.google.de/search?tz=utc&tbm=map&tch=1&hl=en&q={place_detail$result$name} {place_detail$result$formatted_address}&pb=!4m12!1m3!1d4005.9771522653964!2d-122.42072974863942!3d37.8077459796541!2m3!1f0!2f0!3f0!3m2!1i1125!2i976!4f13.1!7i20!10b1!12m6!2m3!5m1!6e2!20e3!10b1!16b1!19m3!2m2!1i392!2i106!20m61!2m2!1i203!2i100!3m2!2i4!5b1!6m6!1m2!1i86!2i86!1m2!1i408!2i200!7m46!1m3!1e1!2b0!3e3!1m3!1e2!2b1!3e2!1m3!1e2!2b0!3e3!1m3!1e3!2b0!3e3!1m3!1e4!2b0!3e3!1m3!1e8!2b0!3e3!1m3!1e3!2b1!3e2!1m3!1e9!2b1!3e2!1m3!1e10!2b0!3e3!1m3!1e10!2b1!3e2!1m3!1e10!2b0!3e4!2b1!4b1!9b0!22m6!1sa9fVWea_MsX8adX8j8AE%3A1!2zMWk6Mix0OjExODg3LGU6MSxwOmE5ZlZXZWFfTXNYOGFkWDhqOEFFOjE!7e81!12e3!17sa9fVWea_MsX8adX8j8AE%3A564!18e15!24m15!2b1!5m4!2b1!3b1!5b1!6b1!10m1!8e3!17b1!24b1!25b1!26b1!30m1!2b1!36b1!26m3!2m2!1i80!2i92!30m28!1m6!1m2!1i0!2i0!2m2!1i458!2i976!1m6!1m2!1i1075!2i0!2m2!1i1125!2i976!1m6!1m2!1i0!2i0!2m2!1i1125!2i20!1m6!1m2!1i0!2i956!2m2!1i1125!2i976!37m1!1e81!42b1!47m0!49m1!3b1"), destfile = "test.txt")
  
  res <- content(q)
  
  clean_pop_times(res)
}




# https://developers.google.com/maps/documentation/javascript/examples/places-placeid-finder
# for finding place ids 
# placeid <- "ChIJLRQ1PyRP4okRLfSIZZWnhtE" # red arrow diner lowell st. manch vegas bby
# Query Maps API from Place ID --------------------------------------------
