# this script combines all data and converts them to the real values
library(stringr)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
inp = read.csv("../DataPoints/Terr-Corrected_9Feb22.csv", stringsAsFactors = FALSE)
names(inp)

# open data ERA5
d01_ERA5 = read.csv("../01_ERA5/ERA5_data_matched.csv", stringsAsFactors = FALSE)

# open data VegCover
d02_VegCover = list()
d02_VegCover$VegCover2000 = read.csv("../02_VegCover/VegCover2000.csv", stringsAsFactors = FALSE)
d02_VegCover$VegCover2005 = read.csv("../02_VegCover/VegCover2005.csv", stringsAsFactors = FALSE)
d02_VegCover$VegCover2010 = read.csv("../02_VegCover/VegCover2010.csv", stringsAsFactors = FALSE)

# convert and add ERA5 data
inp$Year_n = d01_ERA5$Year
inp$Month_n = d01_ERA5$month
inp$x = d01_ERA5$coord1
inp$y = d01_ERA5$coord2
inp$dp_2m_t_ERA5 = d01_ERA5$dewpoint_2m_temperature-273.15 
inp$mean_2m_t_ERA5 = d01_ERA5$mean_2m_air_temperature-273.15 
inp$total_prec_ERA5 = d01_ERA5$total_precipitation*1000
inp$maxt_ERA5 = d01_ERA5$maximum_2m_air_temperature-273.15 
inp$mint_ERA5 = d01_ERA5$minimum_2m_air_temperature-273.15 
inp$u_wind_10m_ERA5 = d01_ERA5$u_component_of_wind_10m
inp$v_wind_10m_ERA5 = d01_ERA5$v_component_of_wind_10m

# convert and add VegCover data
inp$vegCover_stats_cv=inp$vegCover_stats_mean=inp$vegCover_stats_median=inp$vegCover_stats_sd=NA
inp$vegCover_stats_quantile_0p=inp$vegCover_stats_quantile_25p=inp$vegCover_stats_quantile_50p=NA
inp$vegCover_stats_quantile_75p=inp$vegCover_stats_quantile_100p=NA
for(i in 1:nrow(inp)){
   
   # find closest year
   min_idx = which.min(abs(inp$Year[i]-c(2000,2005,2010)))
   
   # use veg cover closest year
   d02_VegCover[[min_idx]]
   
   
   inp$vegCover_stats_cv[i]= d02_VegCover[[min_idx]]$vegCover_stats_cv[i]
   inp$vegCover_stats_mean[i]= d02_VegCover[[min_idx]]$vegCover_stats_mean[i]
   inp$vegCover_stats_median[i]= d02_VegCover[[min_idx]]$vegCover_stats_median[i]
   inp$vegCover_stats_sd[i]= d02_VegCover[[min_idx]]$vegCover_stats_sd[i]
   inp$vegCover_stats_quantile_0p[i]= d02_VegCover[[min_idx]]$vegCover_stats_quantile_0p[i]
   inp$vegCover_stats_quantile_25p[i]= d02_VegCover[[min_idx]]$vegCover_stats_quantile_25p[i]
   inp$vegCover_stats_quantile_50p[i]= d02_VegCover[[min_idx]]$vegCover_stats_quantile_50p[i]
   inp$vegCover_stats_quantile_75p[i]= d02_VegCover[[min_idx]]$vegCover_stats_quantile_75p[i]
   inp$vegCover_stats_quantile_100p[i]= d02_VegCover[[min_idx]]$vegCover_stats_quantile_100p[i]
   
}

write.csv(inp,"../DataPoints/Terr-Corrected_9Feb22_VegCover_ERA5_attached.csv")






