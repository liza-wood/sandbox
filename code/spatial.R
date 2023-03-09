# Spatial with Tara
library(tidyverse)
library(rmapshaper)
library(tigris)
library(tidycensus)
library(sf)
library(tmap)
library(leaflet)

# pl pulls city boundaries are geometries
pl <- places(state = "CA", year = 2020, cb = FALSE)

davis <- pl %>% 
  filter(NAME == "Davis")

## First, let's look at what variables are available 
v20 <- load_variables(2020, "acs5", cache=TRUE) # load variable options

## Now that we have chosen our variables of interest, let's pull in that data
# getacs pulls in census tract geometries
ca.tracts <- get_acs(
  geography = "tract",
  year = 2020, # final year
  variables = c(totp = "B01003_001", #median income
                medhouse = "B25077_001"), #Median housing value for owner-occupied housing units
  state = "CA",
  output= "wide",
  survey = "acs5", #this loads the data from the last 5 years of acs records
  geometry = TRUE,
  cb = FALSE
)

davis.tracts <- ms_clip(target = ca.tracts, clip = davis, remove_slivers = TRUE) 

fruit <- read.csv("https://raw.githubusercontent.com/d-rug/intro_to_spatial_mapping/main/data/data.csv")

st_crs(davis.tracts)
st_crs(fruit)

# 2 parts to the space: 3-dimensional space (earth shape ellipse) and the projections

fruit.sf <- fruit %>%
  st_as_sf(coords = c("lng", "lat"), 
           crs = "+proj=longlat +datum=WGS84 +ellps=WGS84")
st_crs(fruit.sf)# +p

# Check the units
st_crs(fruit.sf)$units

# So basically we want to set it as universal trans mercator as a unit (metric?)
fruit.utm <- fruit.sf %>%
  st_transform(crs = "+proj=utm +zone=10 +datum=NAD83 +ellps=GRS80")

## Reproject davis.tracts to also be in UTM
davis.tracts.utm <- davis.tracts %>%
  st_transform(crs = "+proj=utm +zone=10 +datum=NAD83 +ellps=GRS80")

# Great, nows lets check to see if all dataframes are on the same CRS
st_crs(fruit.utm) == st_crs(davis.tracts.utm) #TRUE

# Check the units
st_crs(fruit.utm)$units

tm_shape(davis.tracts.utm) +
  tm_polygons(col = "medhouseE", style = "quantile", palette = "Blues",
              title = "Median Housing Value ($)") +
  tm_shape(fruit.utm) +
  tm_dots(col = "green") +
  #tm_text("types") +
  tm_scale_bar(breaks = c(0, 1, 2), text.size = 1, position = c("left", "bottom")) +
  tm_compass(type = "4star", position = c("right", "bottom"))  +
  tm_layout(main.title = "Fruit Trees in Davis", 
            main.title.size = 1.25, main.title.position="center",
            legend.outside = TRUE, legend.outside.position = "right",
            frame = FALSE)

# Leaflet
## need to reproject davis.tracts data to be +proj=longlat
davis.tracts.sf <- davis.tracts %>%
  st_transform(crs = "+proj=longlat +datum=WGS84 +ellps=WGS84")

leaflet() %>%
  addTiles() %>%
  addMarkers(data = fruit.sf, popup = ~as.character(types), label = ~as.character(types)) %>%
  addPolygons(data = davis.tracts.sf, 
              color = ~colorQuantile("Blues", totpE, n = 5)(totpE),
              weight = 1,
              smoothFactor = 0.5,
              opacity = 1.0,
              fillOpacity = 0.5,
              highlightOptions = highlightOptions(color = "white",
                                                  weight = 2,
                                                  bringToFront = TRUE))

# Raster-ish data: What parts of town have the highest diversity of fruit trees?

# 1. this is a grid without any tree data yet
## sf package does not work with raster data
Grid <- davis %>% #take our davis outline and draw a rectangle around it
  st_make_grid(n = 25) %>% # let each side of the rectangle have 25 cells
  st_cast("MULTIPOLYGON") %>% #make the grid
  st_sf() %>%
  mutate(cellid = row_number())

# 2. Get fruit types
fruit.types <- fruit.utm %>% group_by(types) %>% # Here group fruit.utm by tree type, note that group by preserves the geometry, turning point classes into multi-point
  summarise()

Grid <- Grid %>% #make sure our grid is matching the CRS of our other layers
  st_as_sf(coords = c("lng", "lat"), 
           crs = "+proj=longlat +datum=WGS84 +ellps=WGS84") %>% 
  st_transform(crs = "+proj=utm +zone=10 +datum=NAD83 +ellps=GRS80")

richness_grid <- Grid %>%
  st_join(fruit.types) %>% #join the fruit.types layer to the grid
  mutate(overlap = ifelse(!is.na(types), 1, 0)) %>% #if type is not NA write 1
  group_by(cellid) %>% #group by the cell ID's of the grid
  summarize(num_types = sum(overlap)) #sum the number of types for each grid cell

ggplot(davis.tracts.utm) + #can plot these using GG plot if we are not worried about north arrow or scale bar (prob can do in tmaps but I don't know that package)
  geom_sf(aes(fill = medhouseE)) + #lets add our housing values layer
  scale_fill_viridis_c() + 
  ggnewscale::new_scale_fill() +
  geom_sf(data = richness_grid, aes(fill = num_types), color = NA) + #add our grid
  scale_fill_viridis_c(alpha = 1, option = "B", na.value = "#00000000", limits = c(1,7), name = "Num tree types per cell") #I used the limits and na.value fields to make cells where there are no trees clear, so that we can see the background map. 