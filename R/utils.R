# Utility Functions -------------------------------------------------------
# Function to create query string for google API
gen_query_url <- function(placeid, key = Sys.getenv("GOOGLE_KEY")) {
  base_detail <- "https://maps.googleapis.com/maps/api/place/details/json?"
  glue::glue("{base_detail}placeid={placeid}&key={key}")
}

# define function to extract popular times
extract_popularity <- function(iter) {
  tibble(
    hour = map_int(iter[[2]], pluck, 1), 
    popularity = map_int(iter[[2]], pluck, 2)
  )
}



clean_pop_times <- function(res) {
  # remove wonky leading characters that prevent reading of json
  resp_list <- str_sub(res$d, 6) %>% 
    str_squish() %>% 
    str_remove_all("\n") %>%
    jsonlite::parse_json()
  
  # we add one to the python indexes because of 0 vs 1 based indexing
  info <- pluck(resp_list, 1, 2, 1)
  popular_times <- pluck(info, 15, 85, 1) # there are 7 list elements one for each day of the week
  current_popularity <- pluck(info, 15, 85, 8, 2)
  time_spent <- pluck(info, 15, 118, 1)
  
  poptimes_tibble <- map_dfr(popular_times, extract_popularity, .id = "day_of_week") 
  
  # Formatting all results --------------------------------------------------
  location <- pluck(place_detail, "result", "geometry", "location")
  
  address <- map_chr(pluck(place_detail, "result", "address_components"), pluck, "long_name") %>% 
    setNames(map_chr(pluck(place_detail, "result", "address_components"), pluck, "types", 1)) %>% 
    as.list() %>% 
    tibble::new_tibble(nrow = 1) %>% 
    mutate(lat = pluck(location, "lat"),
           lon = pluck(location, "lon"))
  
  tibble(
    name = pluck(place_detail, "result", "name"),
    place_id = pluck(place_detail, "result", "place_id"),
    popular_times = list(poptimes_tibble),
    time_spent = time_spent,
    current_popularity = current_popularity,
    website = pluck(place_detail, "result", "website"),
    types = list(unlist(pluck(place_detail, "result", "types"))),
    price_level = pluck(place_detail, "result", "price_level"),
    rating = pluck(place_detail, "result", "rating"),
    n_ratings = pluck(place_detail, "result", "user_ratings_total"),
    ratings = list(map_dfr(pluck(place_detail, "result", "reviews"), new_tibble, nrow = 1)),
    phone = pluck(place_detail, "result", "international_phone_number"),
    business_status = pluck(place_detail, "result", "business_status")
  ) %>% 
    bind_cols(address)
  
}