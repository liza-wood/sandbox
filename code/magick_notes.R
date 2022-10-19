library(magick)

# Have x, y, (lat and long) and then z which/rastr which is elevation
plotting_data = data.frame("x" = lat,
           "y" = long,
           "elevation" = z,
           "water_depth" depth (water depth to average land level),
           "date-time" = date,
           "habitat_category" = did a case_when)

# creates a temporary folder
dir_out <- file.path(tempdir(), "animation")
dir.create(dir_out, recursive = T)

# looping through every image
for(val in 1:nrow(plotting_data)){
  depth_data <- ..
  
  p <- plot
  
  # create a filename so that they're all 4 numbers, padded by zeros
  fp <- file.path(dir_out, paste0(stringr::str_pad(val, 4, pad = "0"), ".png"))
  
  ggsave(plot = p,
         filename = fp,
         device - "png")
  
}

# list files and name and read in using lapply
imgs <- list.files(dir_out, full.names = T)
img_list <- lapply(imgs, image_read)

img_joined <- image_join(img_list)

# animate
img_animated <- image_animate(img_joined, fps = 10)






