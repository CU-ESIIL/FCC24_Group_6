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

# drop unneeded columns
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
  filter(agbd <= 500)

# split data into 70% training, 15% validation, and 15% test sets
validation_test_indices <- sample(1:nrow(disturbance_data_clean), ceiling(nrow(disturbance_data_clean)*0.30))
validation_indices <- sample(validation_test_indices, ceiling(length(validation_test_indices)*0.50))
test_indices <- validation_test_indices[!(validation_test_indices %in% validation_indices)]

disturbance_data_sets <- disturbance_data_clean %>%
  mutate(test_validation_training = case_when(
    row_number() %in% validation_indices ~ "validation",
    row_number() %in% test_indices ~ "test",
    TRUE ~ "training"
  ))

# write cleaned data to CSV file
write_csv(disturbance_data_sets, "~/data/linked_disturbance_data_clean.csv")
