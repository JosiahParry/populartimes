
#' Search for Google Places in a given area
#' 
#' @inheritParams search_pop_times
#' @param location  A numeric vector of length two with the format of `c(lat, long)` indicating the center of a circle to search. 
#' @param radius The radius of the search circle in meters. 
#' @importFrom httr modify_url content GET
#' @importFrom purrr pluck map_dfr map
#' @export
get_places <- function(location = NULL, radius = NULL, type = NULL, 
         keyword = NULL, language = NULL, rankby = NULL, key = Sys.getenv("GOOGLE_KEY")) {
  
  res_list <- list()
  
  b_url <- "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
  
  query <- modify_url(b_url, query = list(type = type,
                                      location = paste0(location, collapse = ", "),
                                      radius = radius, key = key,
                                      language = language, rankby = language))
  
  # Get initial query 
  res <- content(httr::GET(query))
  
  # append first query results as list to the res_list list to keep somewhat orderly
  res_list <- append(res_list, list(res))
  
  # grab next token (if it exists)
  next_token <- pluck(res, "next_page_token")
  
  
  while(!is.null(next_token)) {
    Sys.sleep(runif(1, min = 2, max = 2.75))
    query <- httr::modify_url(b_url, query = list(pagetoken = next_token, key = key))
    resp <- httr::GET(query)
    res <- httr::content(resp)
    res_list <- append(res_list, list(res))
    next_token <- pluck(res, "next_page_token")
  }
  
  map(res_list, pluck, "results") %>% 
    map_dfr(map, tibbilize_place)
  
}






