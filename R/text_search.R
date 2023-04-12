#' @rdname get_places
#' @export
text_search <- function(location = NULL, type = NULL, 
                       keyword = NULL, language = NULL, rankby = NULL, key = Sys.getenv("GOOGLE_KEY")) {
  
  res_list <- list()
  
  b_url <- "https://maps.googleapis.com/maps/api/place/textsearch/json?"
  
  query <- modify_url(
    b_url,
    query = list(
      location = paste0(location, collapse = ", "),
      query = query,
      key = key,
      language = language
    )
  )
  
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
  
  res <- map(res_list, pluck, "results") %>% 
    map_dfr(map, tibbilize_place)
  
}
