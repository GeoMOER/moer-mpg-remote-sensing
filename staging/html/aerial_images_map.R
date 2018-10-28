# Create leaflet map of aerial images

library(mapview)
library(raster)
library(sf)

setwd("C:\\Users\\tnauss\\permanent\\edu\\mpg-remote-sensing\\moer-mpg-remote-sensing\\staging\\html")

mapviewOptions(basemaps = mapviewGetOption("basemaps")[c(3, 1:2, 4:5)])

aerial_files = list.files("C:\\Users\\tnauss\\permanent\\edu\\mpg-envinsys-plygrnd\\data\\aerial\\org",
                          full.names = TRUE)

aerial_stacks = lapply(aerial_files, function(f){
  stack(f)
})

mapviewOptions(mapview.maxpixels = 5000)
m <- mapview(aerial_stacks[[1]]) + aerial_stacks[[2]]

## create standalone .html
mapshot(m, url = "aerial_images_map.html")
