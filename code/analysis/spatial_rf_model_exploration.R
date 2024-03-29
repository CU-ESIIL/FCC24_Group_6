setwd("~/data-store/FCC24_Group_6")

# Install packages
# install.packages("spatialRF")
# install.packages("rnaturalearth")
# install.packages("rnaturalearthdata")
# install.packages("randomForestExplainer")
# install.packages("kableExtra")
# install.packages("pdp")

library(tidyr)
library(dplyr)
library(readr)
library(spatialRF)
library(kableExtra)
library(rnaturalearth)
library(rnaturalearthdata)
library(tidyverse)
library(randomForestExplainer)
library(pdp)

df <- read_csv('/data-store/iplant/home/shared/earthlab/linked_disturbance/data/linked_disturbance_data_frame_baby.csv')

#loading training data and distance matrix from the package
data(plant_richness_df)
data(distance_matrix)

#names of the response variable and the predictors
dependent.variable.name <- "richness_species_vascular"
predictor.variable.names <- colnames(plant_richness_df)[5:21]

#coordinates of the cases
xy <- plant_richness_df[, c("x", "y")]

#distance matrix
distance.matrix <- distance_matrix

#distance thresholds (same units as distance_matrix)
distance.thresholds <- c(0, 1000, 2000, 4000, 8000)

#random seed for reproducibility
random.seed <- 1

world <- rnaturalearth::ne_countries(
  scale = "medium", 
  returnclass = "sf"
)

ggplot2::ggplot() +
  ggplot2::geom_sf(
    data = world, 
    fill = "white"
  ) +
  ggplot2::geom_point(
    data = plant_richness_df,
    ggplot2::aes(
      x = x,
      y = y,
      color = richness_species_vascular
    ),
    size = 2.5
  ) +
  ggplot2::scale_color_viridis_c(
    direction = -1, 
    option = "F"
  ) +
  ggplot2::theme_bw() +
  ggplot2::labs(color = "Plant richness") +
  ggplot2::scale_x_continuous(limits = c(-170, -30)) +
  ggplot2::scale_y_continuous(limits = c(-58, 80))  +
  ggplot2::ggtitle("Plant richness of the American ecoregions") + 
  ggplot2::xlab("Longitude") + 
  ggplot2::ylab("Latitude")


spatialRF::plot_training_df(
  data = plant_richness_df,
  dependent.variable.name = dependent.variable.name,
  predictor.variable.names = predictor.variable.names,
  ncol = 3,
  point.color = viridis::viridis(100, option = "F"),
  line.color = "gray30"
)

spatialRF::plot_training_df_moran(
  data = plant_richness_df,
  dependent.variable.name = dependent.variable.name,
  predictor.variable.names = predictor.variable.names,
  distance.matrix = distance.matrix,
  distance.thresholds = distance.thresholds,
  fill.color = viridis::viridis(
    100,
    option = "F",
    direction = -1
  ),
  point.color = "gray40"
)

preference.order <- c(
  "climate_bio1_average_X_bias_area_km2",
  "climate_aridity_index_average",
  "climate_hypervolume",
  "climate_bio1_average",
  "climate_bio15_minimum",
  "bias_area_km2"
)

predictor.variable.names <- spatialRF::auto_cor(
  x = plant_richness_df[, predictor.variable.names],
  cor.threshold = 0.6,
  preference.order = preference.order
) %>% 
  spatialRF::auto_vif(
    vif.threshold = 2.5,
    preference.order = preference.order
  )

names(predictor.variable.names)
# 
# interactions <- spatialRF::the_feature_engineer(
#   data = plant_richness_df,
#   dependent.variable.name = dependent.variable.name,
#   predictor.variable.names = predictor.variable.names,
#   xy = xy,
#   importance.threshold = 0.50, #uses 50% best predictors
#   cor.threshold = 0.60, #max corr between interactions and predictors
#   seed = random.seed,
#   repetitions = 100,
#   verbose = TRUE
# )
# 
# kableExtra::kbl(
#   head(interactions$screening, 10),
#   format = "html"
# ) %>%
#   kableExtra::kable_paper("hover", full_width = F)

model.non.spatial <- spatialRF::rf(
  data = plant_richness_df,
  dependent.variable.name = dependent.variable.name,
  predictor.variable.names = predictor.variable.names,
  distance.matrix = distance.matrix,
  distance.thresholds = distance.thresholds,
  xy = xy, #not needed by rf, but other functions read it from the model
  seed = random.seed,
  verbose = FALSE
)

spatialRF::plot_importance(
  model.non.spatial,
  verbose = FALSE
)


model.spatial <- spatialRF::rf_spatial(
  model = model.non.spatial,
  method = "mem.moran.sequential", #default method
  verbose = FALSE,
  seed = random.seed
)

p1 <- spatialRF::plot_importance(
  model.non.spatial, 
  verbose = FALSE) + 
  ggplot2::ggtitle("Non-spatial model") 

p2 <- spatialRF::plot_importance(
  model.spatial,
  verbose = FALSE) + 
  ggplot2::ggtitle("Spatial model")

p1 | p2 
