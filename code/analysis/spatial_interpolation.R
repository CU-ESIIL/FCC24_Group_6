# Packages
library(tidyverse)
install.packages("gstat")
library(gstat)
library(terra)
library(sf) 

# Working directory should be 
setwd("~/data-store/FCC24_Group_6")

data_path <- "~/data"

full_df <- read_csv(file.path(data_path,"linked_disturbance_data_clean.csv")) %>%
  rename(x = lon_lowest, y=lat_lowest) %>%
  filter(test_validation_training != "validation")

# Simple spatial interpolation nearest neighbor

# Create empty raster template to interpolate over
e <- ext(apply(full_df[,c("x","y")], 2, range))
# set up the raster, for example
r <- rast(e, ncol=500, nrow=500) # LATER MAKE SPECIFIC METERS
crs(r) <- "EPSG:4326"


# Get shapefile of SRE
sre <- st_read("../sre.gpkg") %>%
  st_transform(crs = crs(r))

# Create IDW gstat object
gs <- gstat(formula = agbd~1, 
            locations = ~x+y, 
            data = full_df[,c("x","y","agbd")], 
            nmax = 50, 
            set = list(idp = 2))

# Interpolate based on IDW model
nn <- interpolate(r, gs, debug.level=0)
names(nn) <- c("agbd_idw","na")

# Mask to SRE
idw_sre <- mask(nn["agbd_idw"], sre)
# Plot
plot(idw_sre)
# Write out for better mapping...
writeRaster(idw_sre, '../idw_agbd.tiff', overwrite = TRUE)

# Extract over validation points
valid_df <- read_csv(file.path(data_path,"linked_disturbance_data_clean.csv")) %>%
  rename(x = lon_lowest, y=lat_lowest) %>%
  filter(test_validation_training == "validation")

# Convert to spatial object
valid_sf <- st_as_sf(valid_df, coords = c("x","y"), crs = st_crs(idw_sre))

# Extract IDW null model estimates
valid_null <- terra::extract(idw_sre, valid_sf)

# 

"/home/jovyan/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/GEDI_L4B_Gridded_Biomass_V2_1"


# Write out
write_csv(valid_null, "")

