library(dplyr)
library(ggmap)
# European maps ----
## All of Europe ----
register_google(key = "AIzaSyBY21rxxoVaPbu3lUAwRPotDtgCK4p9tQE")
map_eu <- map_data(map = "world") %>% 
  filter(region %in% c("UK", "Portugal", "Spain", "France",
                       "Belgium",  "Netherlands", "Luxembourg", "Germany",
                       #"Poland", 
                       "Czech Republic", #"Slovakia", "Hungary",
                       "Switzerland", "Italy", "Austria", "Slovenia"))

#library(tidygeocoder)
cities <- c("Maastricht", #"Bergamo", #"Bellagio", "Menaggio", 
            "Lezzeno", #"Como",
            "Amsterdam", "Brussels", "Brugge", "Lisbon",
            "Newcastle upon Tyne", "Edinburgh", "Arrochar", "Oban")
# Not in world cities "Heraklion", "Chania"
countries <- c("Netherlands", "Italy", #"Italy", "Italy", "Italy", "Italy", 
               "Netherlands", "Belgium", "Belgium", "Portugal",
               "UK", "UK", "UK", "UK")
visited_cities <- data.frame(city = as.character(cities), 
                             country = as.character(countries))
visited_cities$location <- paste(visited_cities$city, visited_cities$country, sep = ", ")
latlong <- geocode(visited_cities$location)
visited_cities <- cbind(visited_cities, latlong)

# Not everything is in world cities
#world_cities <- maps::world.cities
#visited_cities <- filter(world_cities, name %in% cities, 
                         # Account for country to eliminate duplicate names
#                         country.etc %in% countries)

map_trip <- function(map, cities){
  p <- ggplot() +
    geom_polygon(data = map,
                 aes(long, lat, group = group), 
                 show.legend = FALSE,
                 alpha = 0.25,
                 size = .5,
                 color = "gray",
                 fill = "white"
    ) +
    geom_point(data = cities, # these are the node long, lat
               aes(lon, lat),
               #shape = 4,
               size = 2, 
               color = "blue", 
               alpha = 0.5) +
    geom_text(data = cities,
              aes(lon, lat, label = city),
              repel = T) +
    ggraph::theme_graph() 
  return(p)
}

map_trip(map_eu, visited_cities)
#ggsave('~/Desktop/map_test.png')

## NL-IT ----

map_trip1 <- map_eu %>% 
  filter(region %in% c("Netherlands", "Italy"))
cities_trip1 <- visited_cities %>% 
  filter(city %in% c("Maastricht", #"Bergamo", "Bellagio", 
                     #"Menaggio", "Como",
                     "Lezzeno", 
                     "Amsterdam"))
map_trip(map_trip1, cities_trip1)

map_trip2 <- map_eu %>% 
  filter(region %in% c("Belgium", "Portugal"))
cities_trip2 <- visited_cities %>% 
  filter(city %in% c( "Brussels", "Brugge", "Lisbon"))
map_trip(map_trip2, cities_trip2)

map_trip3 <- map_eu %>% 
  filter(region %in% c("UK"))
cities_trip3 <- visited_cities %>% 
  filter(city %in% c("Newcastle upon Tyne", "Edinburgh", "Arrochar", "Oban"))
map_trip(map_trip3, cities_trip3)

# California maps ----
ca <- tigris::states(cb=TRUE, progress_bar = FALSE) %>% 
  dplyr::filter(STUSPS %in% c("CA", "OR"))
map_ca <- map_data(map = "state") %>% 
  filter(region %in% c('california', 'oregon'))

#library(tidygeocoder)
cities <- c("Davis", "Napa", "Cayucos",
            "Crescent City", 
            "Tahoe City", "Prairie Creek Redwoods State Park",
            "San Diego", "Point Reyes Station", "Mendocino", "Crater Lake")
# Not in world cities "Heraklion", "Chania"
states <- c(rep("CA", length(cities)-1), "OR")
visited_cities <- data.frame(city = cities, address = paste(cities, states, sep = ", "))
latlong <- geocode(visited_cities$address)
visited_cities <- cbind(visited_cities, latlong)
# Not everything is in world cities
#world_cities <- maps::world.cities
#visited_cities <- filter(world_cities, name %in% cities, 
# Account for country to eliminate duplicate names
#                         country.etc %in% countries)

map_trip(map_ca, visited_cities)

install.packages('xkcd')
library(xkcd)
vignette("xkcd-intro")
