# Uncomment if needed to install packages
# install.packages("spatialRF")
# install.packages("Metrics")

# Load required packages
library(tidyverse)
library(spatialRF)
library(Metrics)

# Set random seed
random.seed <- 1

# Read dataframe
df <- read_csv('~/data/linked_disturbance_data_clean.csv')
df <- df[!is.na(df['peakNDVI']),]
# Set dependent and predictor variables
dependent.variable.name <- "agbd"
# predictor.variable.names <- colnames(df)[3:(length(colnames(df))-4)]
predictor.variable.names <- c('aetNorm', 'defNorm', 'forestCode',
                              'modisTreeVeg', 'peakNDVI', 'yrsSinceFire',
                              'yrsSinceInsect', 'yrsSinceHotDrought',
                              'utm_z13n_easting', 'utm_z13n_northing',
                              'yrsSinceHotDrought..x..yrsSinceInsect',
                              'yrsSinceFire..x..yrsSinceHotDrought', 
                              'yrsSinceFire..x..yrsSinceInsect')
disturbance.variable.names <- c('yrsSinceFire','yrsSinceHotDrought','yrsSinceInsect',
                                'yrsSinceHotDrought..x..yrsSinceInsect',
                                'yrsSinceFire..x..yrsSinceHotDrought', 
                                'yrsSinceFire..x..yrsSinceInsect')

# Replace some NAs
df$yrsSinceHotDrought <- df$yrsSinceHotDrought %>% replace_na(40)
df$yrsSinceFire <- df$yrsSinceFire %>% replace_na(40)
df$yrsSinceInsect <- df$yrsSinceInsect %>% replace_na(40)

var_list <- c('yrsSinceHotDrought','yrsSinceFire','yrsSinceInsect')
for (var_name_i in var_list) {
  for (var_name_j in var_list[var_list != var_name_i]) {
    df[paste0(var_name_i, '..x..', var_name_j)] <- df[var_name_i] * df[var_name_j]
  }
}


train_df <- df[df$test_validation_training=='training',]
val_df <-  df[df$test_validation_training=='validation',]

# X and y coordinates are utm easting/northing
train_xy <- train_df[, c("utm_z13n_easting", "utm_z13n_northing")]
val_xy <- val_df[, c("utm_z13n_easting", "utm_z13n_northing")]

colnames(train_xy) <- c('x','y')
colnames(val_xy) <- c('x','y')

# Fit basic model
model.non.spatial <- spatialRF::rf(
  data = train_df,
  dependent.variable.name = dependent.variable.name,
  predictor.variable.names = predictor.variable.names,
  xy = train_xy, #not needed by rf, but other functions read it from the model
  seed = random.seed,
  verbose = FALSE,
  ranger.arguments=list(
    num.trees=250,
    mtry=3,
    min.node.size=100
  )
)
model.non.spatial

save(model.non.spatial, file='model2')

# Plot residuals
spatialRF::plot_residuals_diagnostics(
  model.non.spatial,
  verbose = FALSE
)

# Plot dependence curves
spatialRF::plot_response_curves(
  model.non.spatial,
  variables=disturbance.variable.names,
  quantiles = c(0.1, 0.5, 0.9),
  ncol = 3
)

# # Plot dependence surface
# spatialRF::plot_response_surface(
#   model.non.spatial,
#   a='yrsSinceFire',
#   b='yrsSinceHotDrought',
# )

spatialRF::plot_importance(
  model.non.spatial,
  verbose = FALSE
  )

# Inference
predicted_model <- stats::predict(
  object = model.non.spatial,
  data = val_df,
  type = "response"
)

# Write results
val_df$predicted <- predicted_model$predictions
write_csv(val_df, file='~/data/predicted_val.csv')
