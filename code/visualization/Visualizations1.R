# Data Visualizations

##read in dataset

system('mkdir -p ~/data')
#system('cp /data-store/iplant/home/shared/earthlab/linked_disturbance/data/linked_disturbance_data_frame.csv ~/data/')
df1 <- read.csv('~/data/linked_disturbance_data_frame.csv')
setwd <-("~/data-store/FCC24_Group_6")

#Clean/filter dataset

disturbance_data_clean <- df1 %>%
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

df_clean <- disturbance_data_clean


# Create Exploratory Figures for Drought Disturbance

# Packages
library(tidyverse)

data_path <- "~/data/"

#full_df <- read_csv(file.path(data_path,df_clean))

sample_df <- sample_n(df_clean, size = 100000)


library(tidyr)

#Create map of forest type distribution across our region

library(viridis)

ggplot(sample_df) +
  geom_point(aes(x = lon_lowest, y = lat_lowest, color = factor(forestType)), 
             alpha = 0.5, size = 1) +
  scale_color_viridis(discrete = TRUE, option = "D", name = "Forest Type") +
  labs(x = "Lat.", y = "Long.", title = "Spatial distribution of Forest Types") +
  theme_bw(base_size = 20)+
  guides(color = guide_legend(override.aes = list(size = 2))) +theme(
    plot.title = element_text(size = 12)  # Adjust the size of the plot title here
  )+
  theme(
    axis.title.x = element_text(size = 10),  # Adjust the size of the x-axis title
    axis.title.y = element_text(size = 10)   # Adjust the size of the y-axis title
  )

# Map of Forest Type by AboveGround Biomass and Years Since Drought

# Figure of # 1. years since fire and ABGB
df_clean$yrsSinceFireCat <- cut(df_clean$yrsSinceFire,
                                      breaks = c(-Inf, 5, 10, 15, 20, Inf),  # I just picked these breaks, but they can change
                                      labels = c("1-5", "6-10", "11-15", "16-20", "21+"))
ggplot(df_clean) +
  geom_point(aes(x = lon_lowest, y = lat_lowest, color = log(agbd), shape = yrsSinceFireCat), alpha = 10, size = 2) +
  scale_color_viridis(option = "A", name = "Log(AGBD)") +
  scale_shape_manual(values = 0:4, name = "Years Since Fire") +  # Match shapes to categories
  labs(x = "Longitude", y = "Latitude", title = "Impact of Fire on AGBD") +
  theme_minimal() +
  theme(legend.position = "right")


# Figure of # 2. years since insects and ABGB
df_clean$yrsSinceInsectCat <- cut(df_clean$yrsSinceInsect,
                                breaks = c(-Inf, 5, 10, 15, 20, Inf),  # I just picked these breaks, but they can change
                                labels = c("1-5", "6-10", "11-15", "16-20", "21+"))
ggplot(df_clean) +
  geom_point(aes(x = lon_lowest, y = lat_lowest, color = log(agbd), shape = yrsSinceInsectCat), alpha = 10, size = 2) +
  scale_color_viridis(option = "H", name = "Log(AGBD)") +
  scale_shape_manual(values = 0:4, name = "Years Since Insect") +  # Match shapes to categories
  labs(x = "Longitude", y = "Latitude", title = "Impact of Insects on AGBD") +
  theme_minimal() +
  theme(legend.position = "right")