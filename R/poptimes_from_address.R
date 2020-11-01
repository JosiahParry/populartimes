#' Get the popular times given a place name and address
#' 
#' Search Google for popular times for a given point of interest's name and address. Google is smart, so the address component is not exceptionally strict. But do your best to format it! 
#' 
#' @param place_name The name of the place.
#' @param address A string containing the address of a place. Roughly as "<street address>, <city>, <region>, <postal code>, <country>". This field is flexible. 
#' @export
#' @examples 
#' poptimes_from_address("Red Arrow", "61 Lowell Street, Manchester, NH, 03101, US")
#' poptimes_from_address("McDonald", "Helmstraat 16, 6211 TA Maastricht, Netherlands")

 
poptimes_from_address <- function(place_name, address) {
  
  q <- httr::GET(glue::glue("https://www.google.de/search?tz=utc&tbm=map&tch=1&hl=en&q={place_name} {address}&pb=!4m12!1m3!1d4005.9771522653964!2d-122.42072974863942!3d37.8077459796541!2m3!1f0!2f0!3f0!3m2!1i1125!2i976!4f13.1!7i20!10b1!12m6!2m3!5m1!6e2!20e3!10b1!16b1!19m3!2m2!1i392!2i106!20m61!2m2!1i203!2i100!3m2!2i4!5b1!6m6!1m2!1i86!2i86!1m2!1i408!2i200!7m46!1m3!1e1!2b0!3e3!1m3!1e2!2b1!3e2!1m3!1e2!2b0!3e3!1m3!1e3!2b0!3e3!1m3!1e4!2b0!3e3!1m3!1e8!2b0!3e3!1m3!1e3!2b1!3e2!1m3!1e9!2b1!3e2!1m3!1e10!2b0!3e3!1m3!1e10!2b1!3e2!1m3!1e10!2b0!3e4!2b1!4b1!9b0!22m6!1sa9fVWea_MsX8adX8j8AE%3A1!2zMWk6Mix0OjExODg3LGU6MSxwOmE5ZlZXZWFfTXNYOGFkWDhqOEFFOjE!7e81!12e3!17sa9fVWea_MsX8adX8j8AE%3A564!18e15!24m15!2b1!5m4!2b1!3b1!5b1!6b1!10m1!8e3!17b1!24b1!25b1!26b1!30m1!2b1!36b1!26m3!2m2!1i80!2i92!30m28!1m6!1m2!1i0!2i0!2m2!1i458!2i976!1m6!1m2!1i1075!2i0!2m2!1i1125!2i976!1m6!1m2!1i0!2i0!2m2!1i1125!2i20!1m6!1m2!1i0!2i956!2m2!1i1125!2i976!37m1!1e81!42b1!47m0!49m1!3b1"), destfile = "test.txt")
  
  res <- httr::content(q)
  
  resp_list <- stringr::str_sub(res$d, 6) %>% 
    stringr::str_squish() %>% 
    stringr::str_remove_all("\n") %>%
    jsonlite::parse_json()
  
  # we add one to the python indexes because of 0 vs 1 based indexing
  info <- purrr::pluck(resp_list, 1, 2, 1, .default = NA_real_)
  popular_times <- purrr::pluck(info, 15, 85, 1) # there are 7 list elements one for each day of the week
  current_popularity <- purrr::pluck(info, 15, 85, 8, 2, .default = NA_real_)
  time_spent <- pluck(info, 15, 118, 1, .default = NA_real_)
  
  poptimes_tibble <- purrr::map_dfr(popular_times, extract_popularity, .id = "day_of_week") 
  
  location <- purrr::pluck(resp_list, 2, 1)
  lon <- purrr::pluck(location, 3, .default = NA_real_)
  lat <- purrr::pluck(location, 2, .default = NA_real_)
  
  
  tibble::tibble(
    lon = lon,
    lat = lat, 
    popular_times = list(poptimes_tibble),
    time_spent = time_spent,
    current_popularity = current_popularity,
  )
  
}


