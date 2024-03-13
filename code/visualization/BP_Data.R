# Load libraries
library(tidyverse)
library(dplyr)
library(ggplot2)
library(viridis)


# read in data
disturbance_data_raw <- read.csv('~/data/linked_disturbance_data_frame.csv')

disturbance_data_clean <- df %>%
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

write_csv(disturbance_data_clean, "~/data/linked_disturbance_data_clean.csv")

dfclean <- disturbance_data_clean # renamed the cleaned data

dfclean1 <-sample_n(dfclean, size = 100000)


######################################################
############ Data Explore ###########################


# AGBD by Forest Type
ggplot(dfclean1, aes(x = forestType, y = agbd, fill = forestType)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("AGBD by Forest Type")


# Peak NDVI by Forest Type
ggplot(dfclean1, aes(x = forestType, y = peakNDVI, fill = forestType)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Peak NDVI by Forest Type")



# Map of Forest Type by AGBD by bins 
dfclean1 <- dfclean1 %>%
  mutate(agbd_log = log(agbd + 1),  # Ensure no log(0)
         agbd_cat = cut(agbd_log,
                        breaks = quantile(agbd_log, probs = seq(0, 1, by = 0.25), na.rm = TRUE),
                        include.lowest = TRUE,
                        labels = c('Low', 'Medium', 'High', 'Very High')))
ggplot(dfclean1) +
  geom_point(aes(x = lon_lowest, y = lat_lowest, color = factor(forestType), shape = agbd_cat), alpha = 0.5) +
  scale_color_viridis(discrete = TRUE, option = "D", name = "Forest Type") +
  scale_shape_manual(values = c(0:3), name = "AGBD Category") +  # Adjust the values based on your number of bins
  labs(x = "Longitude", y = "Latitude", title = "Spatial Distribution by Forest Type") +
  theme_minimal() +
  theme(legend.position = "right")




####################.  DISTURBANCES    ########

#  years since hot drought and above ground biomass
dfclean1$yrsSinceHotDroughtCat <- cut(dfclean1$yrsSinceHotDrought,
                                      breaks = c(-Inf, 5, 10, 15, 20, Inf),  # I just picked these breaks, but they can change
                                      labels = c("1-5", "6-10", "11-15", "16-20", "21+"))

ggplot(dfclean1) +
  geom_point(aes(x = lon_lowest, y = lat_lowest, color = log(agbd), shape = yrsSinceHotDroughtCat), alpha = 0.5, size = 1.5) +
  scale_color_viridis(option = "D", name = "Log(AGBD)") +
  scale_shape_manual(values = 0:4, name = "Years Since Hot Drought") +  # Match shapes to categories
  labs(x = "Longitude", y = "Latitude", title = "Impact of Hot Drought on AGBD") +
  theme_minimal() +
  theme(legend.position = "right")


### years since hot drought and NDVI
dfclean1$peakNDVICat <- cut(dfclean1$peakNDVI,
                            breaks = c(-Inf, 0.2, 0.4, 0.6, 0.8, Inf),  # Adjust these breaks as necessary
                            labels = c("<=0.2", "0.21-0.4", "0.41-0.6", "0.61-0.8", ">0.8"))

ggplot(dfclean1) +
  geom_point(aes(x = lon_lowest, y = lat_lowest, color = factor(peakNDVICat), shape = yrsSinceHotDroughtCat), alpha = 0.5, size = 1.5) +
  scale_color_viridis(discrete = TRUE, option = "D", name = "NDVI") +
  scale_shape_manual(values = c(0:4), name = "Years Since Hot Drought") +
  labs(x = "Longitude", y = "Latitude", title = "Impact of Hot Drought on NDVI") +
  theme_minimal() +
  theme(legend.position = "right")



## years since insect outbreak and NDVI
dfclean1$yrsSinceInsectCat <- cut(dfclean1$yrsSinceInsect,
                                  breaks = c(-Inf, 5, 10, 15, 20, Inf),  # Adjust these breaks as necessary
                                  labels = c("1-5", "6-10", "11-15", "16-20", "21+"))



ggplot(dfclean1) +
  geom_point(aes(x = lon_lowest, y = lat_lowest, color = factor(peakNDVICat), shape = yrsSinceInsectCat), alpha = 0.5, size = 1.5) +
  scale_color_viridis(discrete = TRUE, option = "D", name = "NDVI Cat.") +
  scale_shape_manual(values = c(0:4), name = "Years Since Insect Outbreak") +
  labs(x = "Longitude", y = "Latitude", title = "Impact of Insect Outbreaks on NDVI") +
  theme_minimal() +
  theme(legend.position = "right")


## years since fire and NDVI

dfclean1$yrsSinceFireCat <- cut(dfclean1$yrsSinceFire,
                                breaks = c(-Inf, 5, 10, 15, 20, Inf),  # Adjust these breaks as necessary
                                labels = c("1-5", "6-10", "11-15", "16-20", "21+"))



ggplot(dfclean1) +
  geom_point(aes(x = lon_lowest, y = lat_lowest, color = factor(peakNDVICat), shape = yrsSinceFireCat), alpha = 0.5, size = 1.5) +
  scale_color_viridis(discrete = TRUE, option = "D", name = "NDVI") +
  scale_shape_manual(values = c(0:4), name = "Years Since Fire") +
  labs(x = "Longitude", y = "Latitude", title = "Impact of Fire on NDVI") +
  theme_minimal() +
  theme(legend.position = "right")




#Adding categorical bins for disturbances: years since insect outbreak by forest type
#1. INSECT 
dfclean1$yrsSinceInsectCat <- cut(dfclean1$yrsSinceInsect,
                                  breaks = c(-Inf, 1, 5, 10, Inf), #  breaks
                                  labels = c("<=1 year", "2-5 years", "6-10 years", ">10 years"))

ggplot(dfclean1) +
  geom_point(aes(x = lon_lowest, y = lat_lowest, color = factor(forestType), shape = yrsSinceInsectCat), alpha = 0.5) +
  scale_color_viridis(discrete = TRUE, option = "D", name = "Forest Type") +
  scale_shape_manual(values = c(0:3), name = "Years Since Insect") +
  labs(x = "Longitude", y = "Latitude", title = "Spatial Distribution of Forest Types by Years Since Insect") +
  theme_minimal() +
  theme(legend.position = "right")








