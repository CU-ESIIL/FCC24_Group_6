
# install.packages("spatialRF")
library(tidyverse)
library(spatialRF)


# Set random seed
random.seed <- 1

# Read dataframe
df <- read_csv('~/data/linked_disturbance_data_clean.csv')

df <- df[!is.na(df['peakNDVI']),]

# Set dependent and predictor variables
dependent.variable.name <- "agbd"
# predictor.variable.names <- colnames(df)[3:(length(colnames(df))-4)]
predictor.variable.names <- c('chili', 'spei1YrPrior', 'spei5YrPrior',
                              'spei10YrPrior', 'aetNorm', 'defNorm', 'forestCode',
                              'modisTreeVeg', 'peakNDVI', 'yrsSinceFire',
                              'yrsSinceInsect', 'yrsSinceHotDrought',
                              'hex_id_5000', 'hex_id_10000', 'hex_id_50000',
                              'hex_id_100000',
                              'utm_z13n_easting', 'utm_z13n_northing',
                              'yrsSinceHotDrought..x..yrsSinceInsect', 
                              'yrsSinceHotDrought..x..yrsSinceFire', 
                              'yrsSinceFire..x..yrsSinceHotDrought', 
                              'yrsSinceFire..x..yrsSinceInsect', 
                              'yrsSinceInsect..x..yrsSinceHotDrought', 
                              'yrsSinceInsect..x..yrsSinceFire')
disturbance.variable.names <- c('yrsSinceFire','yrsSinceHotDrought','yrsSinceInsect',
                                'yrsSinceHotDrought..x..yrsSinceInsect', 
                                'yrsSinceHotDrought..x..yrsSinceFire', 
                                'yrsSinceFire..x..yrsSinceHotDrought', 
                                'yrsSinceFire..x..yrsSinceInsect', 
                                'yrsSinceInsect..x..yrsSinceHotDrought', 
                                'yrsSinceInsect..x..yrsSinceFire')

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

# X and y coordinates are utm easting/northing
xy <- df[, c("utm_z13n_easting", "utm_z13n_northing")]
colnames(xy) <- c('x','y')

# euclidean_matrix <- dist(as.data.frame(xy)[1:100000,])

# Fit basic model
model.non.spatial <- spatialRF::rf(
  data = df[1:20000,],
  dependent.variable.name = dependent.variable.name,
  predictor.variable.names = predictor.variable.names,
  xy = xy, #not needed by rf, but other functions read it from the model
  seed = random.seed,
  verbose = FALSE,
  ranger.arguments=list(
    num.trees=500,
    mtry=5,
    min.node.size=10
  )
)
model.non.spatial


# Plot residuals
spatialRF::plot_residuals_diagnostics(
  model.non.spatial,
  verbose = FALSE
)

# Plot dependence curves
spatialRF::plot_response_curves(
  model.non.spatial,
  variables=disturbance.variable.names,
  quantiles = c(0.5),
  ncol = 3
)
