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
           "lon_lowest",
           "utm_z13n_easting",
           "utm_z13n_northing",
           "roadBuffer",
           "forestMask",
           "collectionYrFire",
           "collectionYrInsect",
           "collectionYrHotDrought")) %>%
  filter(agbd <= 500) %>%
  mutate(test_validation_training = "training")

# validation_test_indices <- sample(1:nrow(disturbance_data_clean), ceiling(nrow(disturbance_data_clean)*0.30))
# validation_indices <- sample(validation_test_indices, ceiling(length(validation_test_indices)*0.50))
# test_indices <- validation_test_indices[!validation_indices %in% validation_test_indices]
# 
# disturbance_data_clean$test_validation_training[validation_indices] <- rep("validation", length(disturbance_data_clean$test_validation_training))
# disturbance_data_clean$test_validation_training[test_indices] <- rep("test", length(disturbance_data_clean$test_validation_training))

write_csv(disturbance_data_clean, "~/data/linked_disturbance_data_clean.csv")
