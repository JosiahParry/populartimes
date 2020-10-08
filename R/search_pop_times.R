#' Search an area for popular times. 
#' 
#' @param sw A numeric vector of length two with the format of c(lat, long) indicating the southwest point of a bounding box. Must be in decimal degrees and EPSG 4326.
#' @param ne A numeric vector of length two with the format of c(lat, long) indicating northeast point of a bounding box. Must be in decimal degrees and EPSG 4326.
#' @param radius The search radius of each grid element in meters. 
#' @param type A place type to limit the search to. See API [docs](https://developers.google.com/places/web-service/supported_types) for valid place types. Only one type may be specified per search. 
#' @param key Your Google Places API key.
#' @importFrom purrr map_dfr pluck 
#' @importFrom sf st_point
#' @details 
#' The Google Places API searches return a maximum of 60 responses regardless of a search's radius. To accommodate this limitation of the API, a search grid is created with a number of smaller circles with a defined radius via the `radius` argument. Each cell in the grid uses a single API call. A smaller radius should be used to accommodate denser geographies.
#' The search grid used is saved the the attribute `search_grid` and can be accessed `attr(x, "search_grid")`. 
#' 
#' @examples 
#' sw <- c(42.988690, -71.465834)
#' ne <- c(42.995119, -71.455745)
#' manch_bars <- search_pop_times(sw, ne, radius = 200, type = "bar")
#' @export

search_pop_times <- function(sw, ne, radius = 180,
                             type = NULL, key = Sys.getenv("GOOGLE_KEY"), ...) {
  
  sw <- sf::st_point(sw)
  ne <- sf::st_point(ne)
  
  search_grid <- gen_search_grid(sw, ne, radius)
  
  search_places <- purrr::map_dfr(.x = 1:nrow(search_grid), ~{
    
    coords <- search_grid[.x,]
    
    get_places(coords, radius = radius, key = key, type = type, ...)
    
  })
  
  res <- purrr::map_dfr(purrr::pluck(search_places, "place_id"), get_popular_times, key = key)
  
  attr(res, "search_grid") <- search_grid
  
  res
}