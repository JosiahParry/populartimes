# library(sf)
# 
# sw <- st_point(c(48.132986, 11.566126)) 
# ne <- st_point(c(48.142199, 11.580047))
# se <- st_point(c(ne[1], sw[2]))
# nw <- st_point(c(sw[1], ne[2]))
# 
# 
# 
# 
# # use this value plus a radius, set to 180m by default 
# # to 
# # This relates to the internal function cover_rect_with_circles
# # not completely following the processing here
# 
# # These below values are used for comparing to the python library
# # My r-based calculations are slightly different for distances 
# # so it'll return different results, use these when comparing to og populartimes
# r <- radius <- 180
# w <- 1024.4210946497974
# h <- 1036.1868320116494
# 
# 

# Given a rectangle defined by southwest and northeast points create a grid of circles with a defined radius. Return the centers of the circles. Centers are to be used for querying Google Places 
#' @importFrom sf st_point st_sfc st_distance
#' @importFrom purrr map2_dfr
#' @importFrom magrittr %>%
#' @keywords internal
gen_search_grid <- function(sw, ne, radius = 180) {
  dist_lat <- st_sfc(st_point(c(ne[1], sw[2])), sw, crs = 4326) %>% 
    st_distance() %>% 
    max()
  
  
  dist_long <- st_sfc(st_point(c(sw[1], ne[2])), sw, crs = 4326) %>%
    st_distance() %>%
    max()
  
  w <- dist_lat
  h <- dist_long
  r <- radius
  
  dists_grid <- cover_rect_w_circles(w, h, r)
  
  map2_dfr(.x = dists_grid$x,
           .y = dists_grid$y,
           .f = ~calc_grid_centers(c(sw[2], sw[1]), .y, .x)) 
}


# Takes width, height, and radius and measures distance in meters from

# From the python comment string: 
# fully cover a rectangle of given width and height with
# circles of radius r. This algorithm uses a hexagonal
# honeycomb pattern to cover the area.
# we are returned distances in provided units from an origin point
# the m-wrzr/populartimes calculates these as offsets from the southwestern point of a rectangle 
#' @keywords internal
cover_rect_w_circles <- function(w, h, r) {
  
  x_dist <- sqrt(3) * r
  y_dist <- 1.5 * r
  
  n_x_even <- ceiling(w / x_dist)
  n_x_odd <- ceiling((as.numeric(w) - x_dist /2) / x_dist) + 1
  
  n_y <- ceiling((as.numeric(h) - r) / y_dist) 
  
  y_offset <- 0.5 * r
  
  
  x_vals <- c()
  y_vals <- c()
  
  for (y in 0:n_y) {
    if (y %% 2 == 0) {
      x_offset <- x_dist / 2
      n_x <- as.numeric(n_x_even) 
    } else {
      x_offset <- 0
      n_x <- n_x_odd 
    }
    
    for (x in 0:(n_x-1)) {
      x_vals <- append(x_vals, x_offset + x * x_dist)
      y_vals <- append(y_vals, y_offset + y * y_dist)
    }
  }
  
  # need to feed the dist_lat, dist_long, radius, and these resultant values into the rect_circle_collision
  data.frame(x = x_vals, y = y_vals)
}

# This takes a predefined coordinate point and distance from (lat and long) it in meters and finds the corresponding point 
#' @importFrom geosphere destPoint
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#' @keywords internal
calc_grid_centers <- function(point, x_dist, y_dist) {
  geosphere::destPoint(as.numeric(point), b = 0, x_dist) %>% 
    geosphere::destPoint(b = 90, y_dist) %>% 
    as.data.frame() %>% 
    select(lat, lon)
  

}



