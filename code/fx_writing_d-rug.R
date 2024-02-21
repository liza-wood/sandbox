library(rgbif)
library(ggplot2)

?occ_search
GBIF_Frax = occ_search(scientificName = "Fraxinus velutina", hasCoordinate = TRUE, basisOfRecord = "PRESERVED_SPECIMEN")

Frax_dat <- GBIF_Frax$data

wm <- borders("world", colour="gray50", fill="gray50") #map backgroud
ggplot()+ coord_fixed() + wm +
  geom_point(data = Frax_dat, aes(x = decimalLongitude, y = decimalLatitude),
             colour = "darkred", size = 0.5) +
  theme_bw() + ggtitle(Frax_dat$scientificName)

dist_map <- function(x){
  GBIFdata = occ_search(scientificName = x, limit = 300, hasCoordinate = TRUE, basisOfRecord = "PRESERVED_SPECIMEN")
  dat = GBIFdata$data
  wm = borders("world", colour="gray50", fill="gray50") #map backgroud
  p = ggplot()+ coord_fixed() + wm +
    geom_point(data = dat, aes(x = decimalLongitude, y = decimalLatitude),
               colour = "darkred", size = 0.5) +
    theme_bw() + ggtitle(dat$scientificName)
  return(p)
}

dist_map("Fremontodendron californicum")

