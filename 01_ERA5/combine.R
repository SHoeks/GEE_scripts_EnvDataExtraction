library(stringr)
library(abind)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("../OutputsGEE") # go to folder

# Get correct year and month of files
file_names = list.files()
file_names = grep("ERA5",file_names,value = TRUE)
file_names_paths = file_names
file_names = str_split(file_names,"_",simplify = T)[,3]
file_names = str_split(file_names,"\\.",simplify = T)[,1]
years = as.numeric(str_sub(file_names,1,4))
months = as.numeric(str_sub(file_names,5,6))

# Load files
csv = lapply(file_names_paths,read.csv)

# Remove unwanted columns
for(i in 1:length(csv)){
  csv[[i]]$system.index = NULL
  csv[[i]]$mean_sea_level_pressure = NULL
  csv[[i]]$surface_pressure  = NULL
  csv[[i]]$coord1 = NA
  csv[[i]]$coord2 = NA
  for(j in 1:nrow(csv[[i]])){
    csv[[i]]$coord1[j] = str_split(str_split(csv[[i]]$.geo[j],'\\[')[[1]][2],',')[[1]][1]
    csv[[i]]$coord2[j] = str_split(str_split(str_split(csv[[i]]$.geo[j],'\\[')[[1]][2],',')[[1]][2],'\\]')[[1]][1]
  }
  csv[[i]]$.geo = NULL
}

# Add year and month to data sets
for(i in 1:length(csv)){
  csv[[i]]$year = years[i]
  csv[[i]]$month = months[i]
}
csv_df = as.data.frame(abind(csv, along=1))

# Match data
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
inp = read.csv("../DataPoints/Terr-Corrected_9Feb22.csv", stringsAsFactors = FALSE)
inp = inp[,c("GIS...latitude","GIS..longitude","Year","Month")]
names(inp) = c("lat","long","Year","Month")
id_names = str_sub(csv_df$wc_id[1],1,str_length(csv_df$wc_id[1])-4)
inp$id = paste0(id_names,str_pad(1:nrow(inp), 4, pad = "0"))
inp = inp[complete.cases(inp),]

# Match data with all points
inp$unique_locs = paste0(inp$lat,'_',inp$long)
inp_unique = inp[!duplicated(inp$unique_locs),]
inp$id_data = inp_unique$id[match(inp$unique_locs,inp_unique$unique_locs)]
months_let = c("Jan","Feb","Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
data_matched = data.frame()

for(i in 1:nrow(inp)){
  year_extract = ifelse(inp$Year[i]>2017,2017,inp$Year[i])
  month_n = which(months_let==inp$Month[i])
  idx = which(csv_df$year==year_extract & csv_df$month==month_n & csv_df$wc_id==inp$id_data[i])
  data_matched = rbind(data_matched,csv_df[idx,])
}

# Write data
check = cbind(data_matched,inp)
write.csv(data_matched,"ERA5_data_matched.csv")





