# Utility Functions -------------------------------------------------------
# Function to create query string for google API
#' @importFrom glue glue
#' @keywords internal
gen_query_url <- function(placeid, key = Sys.getenv("GOOGLE_KEY")) {
  base_detail <- "https://maps.googleapis.com/maps/api/place/details/json?"
  glue::glue("{base_detail}placeid={placeid}&key={key}")
}

# define function to extract popular times
#' @importFrom purrr map_int
#' @importFrom tibble tibble
#' @keywords internal
extract_popularity <- function(iter) {
  tibble(
    hour = map_int(iter[[2]], pluck, 1, .default = NA), 
    popularity = map_int(iter[[2]], pluck, 2, .default = NA)
  )
}


#' @importFrom purrr pluck map_dfr map_chr
#' @importFrom tibble new_tibble tibble
#' @importFrom dplyr bind_cols mutate
#' @importFrom stringr str_squish str_remove_all str_sub
#' @importFrom jsonlite parse_json
#' @keywords internal 
clean_pop_times <- function(res, place_detail) {
  # remove wonky leading characters that prevent reading of json
  resp_list <- str_sub(res$d, 6) %>% 
    str_squish() %>% 
    str_remove_all("\n") %>%
    jsonlite::parse_json()
  
  # we add one to the python indexes because of 0 vs 1 based indexing
  info <- pluck(resp_list, 1, 2, 1, .default = NA)
  popular_times <- pluck(info, 15, 85, 1) # there are 7 list elements one for each day of the week
  current_popularity <- pluck(info, 15, 85, 8, 2, .default = NA)
  time_spent <- pluck(info, 15, 118, 1, .default = NA)
  
  poptimes_tibble <- map_dfr(popular_times, extract_popularity, .id = "day_of_week") 
  
  # Formatting all results --------------------------------------------------
  location <- pluck(place_detail, "result", "geometry", "location")
  
  address <- map_chr(pluck(place_detail, "result", "address_components"), 
                     pluck, "long_name", .default = NA) %>% 
    setNames(map_chr(pluck(place_detail, "result", "address_components"), 
                     pluck, "types", 1, .default = NA)) %>% 
    as.list() %>% 
    tibble::new_tibble(nrow = 1) %>% 
    mutate(lat = pluck(location, "lat", .default = NA),
           lon = pluck(location, "lng", .default = NA))
  
  tibble(
    name = pluck(place_detail, "result", "name", .default = NA),
    place_id = pluck(place_detail, "result", "place_id", .default = NA),
    popular_times = list(poptimes_tibble),
    time_spent = time_spent,
    current_popularity = current_popularity,
    website = pluck(place_detail, "result", "website", .default = NA),
    types = list(unlist(pluck(place_detail, "result", "types", .default = NA))),
    price_level = pluck(place_detail, "result", "price_level", .default = NA),
    rating = pluck(place_detail, "result", "rating", .default = NA),
    n_ratings = pluck(place_detail, "result", "user_ratings_total", .default = NA),
    ratings = list(map_dfr(pluck(place_detail, "result", "reviews", .default = list()),
                           new_tibble, nrow = 1)),
    phone = pluck(place_detail, "result", "international_phone_number", .default = NA),
    business_status = pluck(place_detail, "result", "business_status", .default = NA)
  ) %>% 
    bind_cols(address)
  
}






# Clean up get_places results. Used to clean corresponding json.
tibbilize_place <- function(res) {
  tibble(
    place_id = pluck(res, "place_id"),
    name = pluck(res, "name"),
    lat = pluck(res, "geometry", "location", "lat", .default = NA),
    long = pluck(res, "geometry", "location", "lng", .default = NA),
    vicinity = pluck(res, "vicinity", .default = NA),
    types = list(unlist(pluck(res, "types", .default = NA))),
    rating = pluck(res, "rating", .default = NA),
    n_ratings = pluck(res, "user_ratings_total", .default = NA),
    price_level = pluck(res, "price_level", .default = NA),
    business_status = pluck(res, "business_status", .default = NA),
    photos = pluck(res, "photos", .default = NA)  
    
  )
  
}