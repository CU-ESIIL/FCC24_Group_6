# Packages
library(tidyverse)
# Working directory should be "setwd("~/data-store/FCC24_Group_6")"

data_path <- "~/data/"

full_df <- read_csv(file.path(data_path,"linked_disturbance_data_frame.csv")) %>%
    filter(agbd < 1000)

small_df <- sample_n(full_df, size = 100000) 

ggplot(small_df, aes(x = yrsSinceFire, y = agbd)) +
  geom_point() +
  geom_smooth() +
  theme_bw(base_size = 14)

ggplot(small_df) +
  geom_histogram(aes(x = log(agbd)), bins = 100)

ggplot(small_df) +
  geom_point(aes(x =lon_lowest, y = lat_lowest, color = log(agbd)), 
             alpha = 0.5, size = 0.25) +
  scale_color_viridis_c() +
  labs(x = "Lat.", y = "Long.", title = "Spatial distribution of GEDI AGBD (log)") +
  theme_bw(base_size = 14)

ggsave("agbd.png")

# Model explore
simple_lm <- lm(agbd ~ lon_lowest + lat_lowest + elev_lowes, data = small_df)
summary(simple_lm)





