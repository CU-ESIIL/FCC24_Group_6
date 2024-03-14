# Project presentation overview
*Abstract*  Forests play a vital role in mitigating climate change impacts through carbon sequestration. However, forests are under threat from increasing disturbances like wildfires, droughts, and insect outbreaks. Using remote sensing data, forests can be monitored across large spatial scales and at increasingly high resolutions to observe forest measurements. The Global Ecosystem Dynamics Investigation (GEDI) provides high resolution laser footprints of forests at large spatial scales, enabling estimates of above-ground biomass density (AGBD). Utilizing these AGBD footprints in combination with data on disturbance histories, we predict AGBD for sites not covered by GEDI and model forest recovery trajectories following disturbances in the Southern Rocky Mountain ecoregion.

*Project Question* How does the trajectory of carbon recovery vary among different combinations of disturbance legacies?

*Project Description* The goal of this project is to understand trajectories (via a spatial random forest model using GEDI data) of above ground carbon recovery across combinations of disturbance legacies among wildfire, drought, and insects. We aim to understand these trajectories and create a predictive model to interpolate GEDI footprint data and understand how these disturbances impact above ground biomass density.

# Data Sources
*Response:*
GEDI L4A Footprint Biomass product converts each high-quality waveform to an AGBD prediction (Mg/ha)
*Predictors/features:*
Geographic location
30-yr normals for climatic water deficit (‘def’) and actual evapotranspiration (aet); TopoFire Holden et al.
Tree cover; MODIS
Peak NDVI; Landsat
Forest type; MODIS
Time since disturbances; EarthLab “disturbance stack”
Fire
Insect outbreak
Hotter drought 

# Methods - The Model and Data Exploration
## Data Analysis

### Baseline  (null) model: Inverse-distance weighted interpolation
To have a baseline to compare against, we performed spatial interpolation using inverse distance weighting on the GEDI above-ground biomass density point estimates. 

` TYLER - *INSERT SNIPPET OF MODEL CODE HERE`

### Example of Weighted Interpolation 
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/1b9776a7-397c-4412-82e4-f15be0bf205f)


### Random Forest Modeling
Random forest modeling was performed on CyVerse using the R [spatialRF](https://blasbenito.github.io/spatialRF/) package. The script for modeling is [spatial_rf_model.R](https://github.com/CU-ESIIL/FCC24_Group_6/tree/gh-pages-documentation/code/analysis/spatial_rf_model.R).


`KYLEN - *INSERT SNIPPET OF MODEL CODE HERE`

### Model Evaluation
Both models (kriging and random forest) were trained on a training set consisting of 70% of the GEDI data rows. 15% of the data were used as a validation set and 15% were withheld as a final test set. After training, we computed RMSE and R^2 on the validation set to compare. 

![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/d245f085-78ab-4553-8a78-255fe7866c94)


## Data Exploration & Visualizations
Visualizations of above ground biomass density versus fire, drought, and insect disturbances were created using Tidyverse ggplot methodology. We also explored the impact of these disturbance types on NDVI and forest type distribution in corelation with trajectories of disturbance recovery visuals. Above ground biomass density was limited to 500 Mg due to time constraints.

### Range of Above Ground Biomass Distribution Across Southern Rocky Mountain EcoRegion
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/5ec244fc-5979-4387-8e37-b78386feb41a)

### Example of Disturbance Impact on Above Ground Biomass - Wildfire
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/a7fc6657-223f-42cf-8c9d-6adfd5c9f285)

# Results: Random Forest Model vs. Baseline Interpolation - The Biomass Prediction
*INSERT COOL SHIT HERE*
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/afd29635-ee50-4c2e-932c-5933cab01bf9)
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/683d9846-a9e3-4516-a379-0e3bf6cd8f95)

# Disturbance Recover Trajectories
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/1e18caa7-1738-4a66-8ee6-6dba98515970)







# Presentation

