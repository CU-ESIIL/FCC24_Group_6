# load libraries
library(tidyverse)

# set working directory
setwd("/home/jovyan/data-store/FCC24_Group_6")
getwd()

# copy data over from data store
system('mkdir -p ~/data')
system('cp /data-store/iplant/home/shared/earthlab/linked_disturbance/data/linked_disturbance_data_frame.csv ~/data/')

# read in data
disturbance_data_raw <- read.csv('~/data/linked_disturbance_data_frame.csv')

disturbance_data_clean <- disturbance_data_raw %>%
  select(c("date",
           "agbd",
           "chili",
           "spei1YrPrior",
           "spei5YrPrior",
           "spei10YrPrior",
           "aetNorm",
           "defNorm",
           "forestCode",
           "forestType",
           "modisTreeVeg",
           "peakNDVI",
           "yrsSinceFire",
           "yrsSinceInsect",
           "yrsSinceHotDrought",
           "hex_id_5000",
           "hex_id_10000",
           "hex_id_50000",
           "hex_id_100000",
           "lat_lowest",
           "long_lowest",
           "utm_z13n_easting",
           "utm_z13n_northing",
           "roadBuffer",
           "forestMask",
           "collectionYrFire",
           "collectionYrInsect",
           "collectionYrHotDrought")) %>%
  filter(agbd <= 500)

write_csv(disturbance_data_clean, "~/data/linked_disturbance_data_clean.csv")
