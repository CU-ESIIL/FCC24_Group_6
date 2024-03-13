# Packages
library(tidyverse)
# Working directory should be "setwd("~/data-store/FCC24_Group_6")"

data_path <- "~/data"

full_df <- read_csv(file.path(data_path,"linked_disturbance_data_frame.csv")) %>%
  filter(agbd < 1000) %>%
  rename(x = lon_lowest, y=lat_lowest)

small_df <- sample_n(full_df, size = 100000) 

# Simple spatial interpolation nearest neighbor
install.packages("gstat")
library(gstat)
library(terra)
library(sf) 

# Create empty raster template to interpolate over
e <- ext(apply(full_df[,c("x","y")], 2, range))
# set up the raster, for example
r <- rast(e, ncol=500, nrow=500) # LATER MAKE SPECIFIC METERS
crs(r) <- "EPSG:4326"
r[] = 1

# Get shapefile of SRE
sre <- st_read("../sre.gpkg") %>%
  st_transform(crs = crs(r))

# Mark raster template to SRE
r_sre <- mask(r, sre)

# Create IDW gstat object
gs <- gstat(formula = agbd~1, 
            locations = ~x+y, 
            data = full_df[,c("x","y","agbd")], 
            nmax = 10, 
            set = list(idp = 0.5))

nn <- interpolate(r, gs, debug.level=0)

nn_sre <- mask(nn, sre)

plot(nn_sre)

writeRaster(nn_sre, '../idw_nn_sre.tiff')




