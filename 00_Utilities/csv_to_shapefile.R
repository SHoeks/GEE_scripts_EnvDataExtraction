# this script creates a shapefile (points) from the data using long and lat
# it only keep the unique x (long) and y (lat) locations 
# the temporal component is added later again to select the specific years and months
library(maptools)
library(rgdal)
library(sp)
library(stringr)

# open data file
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
points = read.csv("../DataPoints/Terr-Corrected_9Feb22.csv", stringsAsFactors = F)

# make ids
points$wc_id = NA
points$wc_id = paste0("Wd_",str_pad(1:length(points$wc_id), 4, pad = "0"))

# convert temporal columns
months_let = c("Jan","Feb","Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
points$Month_n = match(points$Month,months_let)
points$Month_n_pad = points$Month_n
points$unique_locs = paste0(points$lat,'_',points$long)
points = points[!duplicated(points$unique_locs),]
points$lat = points$"GIS...latitude"
points$long = points$"GIS..longitude"

# write shapefile
coordinates(points)=~long+lat
writeOGR(obj=points, dsn="points_unique_xy", layer="points_unique_xy", 
         driver="ESRI Shapefile", overwrite_layer = T)

