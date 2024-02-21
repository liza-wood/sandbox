library(dplyr) # wrangling
library(ggplot2) # viz
library(fs) # file management
library(here) # directory 

# spatial packages
library(tigris) # for census/geospatial data
library(sf) # wrangling geospatial data
library(geojsonsf)
library(nhdplusTools) # all things rivers in US
#remotes::install_github("paleolimbot/geoarrow")
library(geoarrow)
library(arrow)

# get CA and download HUC12s
ca <- tigris::states(progress_bar=FALSE) %>% filter(NAME=="California")

# can specify any given option for huc8, huc10,etc
huc12 <- nhdplusTools::get_huc(ca, type = "huc12") # this takes a minute or two
huc12 <- sf::st_cast(huc12, "MULTIPOLYGON") # fix geometry
# save out
geoarrow::write_geoparquet(huc12, "~/Documents/Davis/R-Projects/sandbox/data/nhd_huc12.parquet")

h12 <- read_geoparquet_sf("~/Documents/Davis/R-Projects/sandbox/data/nhd_huc12.parquet")

# plot
ggplot() + geom_sf(data=h12, color="skyblue", alpha=0.3, linewidth=0.05)
