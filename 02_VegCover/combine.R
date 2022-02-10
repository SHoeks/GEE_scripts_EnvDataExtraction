# This script extracts the vegcover data using the home-range of the species (times 2)
library(stringr)
library(abind)
library(raster)
library(sf)
library(rgeos)
library(igraph)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
cur_wd = getwd()

# set year and plot options
year = c(2000,2005,2010)[3]
plott = FALSE

# open data
dp = read.csv("../DataPoints/Terr-Corrected_9Feb22.csv", stringsAsFactors = FALSE)
dp = dp[complete.cases(dp$"GIS...latitude"),]
dp$lat = dp$"GIS...latitude"
dp$long = dp$"GIS..longitude"


# get files names
setwd('../OutputsGEE')
files = list.files(pattern='.tif')
files = grep("VegCover",files,value=TRUE)

# set ids input csv
dp$wc_id = NA
id_names = str_split(files[1],"_VegCover")[[1]][1]
id_names = str_sub(id_names,1,str_length(id_names)-4)
dp$wc_id = paste0(id_names,str_pad(1:length(dp$wc_id), 4, pad = "0"))

# get dmatch (matching unique locs with all locs)
unique_locs = str_split(files,"_VegCover",simplify = T)[,1]
dmatch = data.frame(id = unique_locs)
dmatch$unique_locs = paste0(dp[match(unique_locs,dp$wc_id),]$lat,'_',dp[match(unique_locs,dp$wc_id),]$long)
dp$unique_locs = paste0(dp$lat,'_',dp$long)

dddd = data.frame(id_original = dp$wc_id, loc = dp$unique_locs, id_data_layer = unique_locs[match(dp$unique_locs,dmatch$unique_locs)] )
dmatch = dddd

if(year==2000) searh_pattern = 'VegCover2000'
if(year==2005) searh_pattern = 'VegCover2005'
if(year==2010) searh_pattern = 'VegCover2010'

# filter files by year
files_year = files[str_detect(files,searh_pattern)]

# cbind dp and dmatch
d = cbind(dp,dmatch)
head(d)

# check patchiness single data points i
dout = as.data.frame(matrix(NA,nrow=nrow(d),ncol=11))
names(dout) = c('ID_data_layer','ID_original','vegCover_stats_cv','vegCover_stats_mean','vegCover_stats_median','vegCover_stats_sd',
                'vegCover_stats_quantile_0p','vegCover_stats_quantile_25p','vegCover_stats_quantile_50p','vegCover_stats_quantile_75p',
                'vegCover_stats_quantile_100p')
head(dout)


for(i in 1:length(d$wc_id)){
  
  #i = 611
  print(i)
  di = d[i,]
  
  # get name data layer
  data_layer = paste0(str_split(di$id_data_layer,'_',simplify = T)[1:3],collapse = '_')
  r_file = files[str_detect(files,data_layer)] # detect for id
  r_file = r_file[str_detect(r_file,searh_pattern)] # detect for year
  r = raster(r_file);
  if(plott) plot(r,main=i)
  coordinates(di)<-~long+lat
  proj4string(di) = CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
  
  # apply buffer (home range, unit = m)
  home_range = di@data$HomeRange*1000000
  radius_home_range = sqrt((home_range)*2/pi)
  dpf_pb = buffer(di, radius_home_range)
  
  # check size polygon 
  n_times_hr = (area(dpf_pb)/1000000) / di@data$HomeRange
  print(paste0("n times hr: ",n_times_hr))
  
  # clump veg cover
  rr_raw <- mask(r, dpf_pb)
  if(plott) plot(r,main=i);
  if(plott) plot(dpf_pb,add=T);
  if(plott) points(di$long,di$lat,col="red",cex=1,pch=19)
 
  # get stats
  dout$ID_data_layer[i]=names(r)
  dout$ID_original[i]=as.character(di$id_original)
  dout$vegCover_stats_cv[i] = cv(rr_raw[], na.rm = T)
  dout$vegCover_stats_mean[i] = mean(rr_raw[], na.rm = T)
  dout$vegCover_stats_median[i] = mean(rr_raw[], na.rm = T)
  dout$vegCover_stats_sd[i] = sd(rr_raw[], na.rm = T)
  dout[i,7:11] = quantile(rr_raw[], na.rm = T)
  
  # show observation result
  print(dout[i,])
}
print(dout[1:10,])

setwd(cur_wd)
getwd()
write.csv(dout,paste0(searh_pattern,'.csv'))
list.files()
