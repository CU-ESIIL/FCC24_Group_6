# Project presentation overview
*Abstract* - Forests play a vital role in mitigating climate change impacts through carbon sequestration. However, forests are under threat from increasingly frequent and severe disturbances like wildfires, droughts, and insect outbreaks. Using remote sensing data, forests can be monitored across large spatial scales and at increasingly high resolutions to observe forest measurements. The Global Ecosystem Dynamics Investigation (GEDI) provides high resolution laser footprints of forests at large spatial scales, enabling estimates of above-ground biomass density (AGBD). Utilizing these AGBD footprints in combination with data on disturbance histories, we predict AGBD for sites not covered by GEDI and model forest recovery trajectories following disturbances in the Southern Rocky Mountain ecoregion.

*Project Questions*
1. What is the relative importance of different disturbance combinations in shaping above ground biomass density?
2. How do post-disturbance biomass trajectories vary among disturbance types and combinations?
3. Do models that include information about disturbance predict biomass density better than models that do not?


*Project Description* - The goal of this project is to understand trajectories (via a random forest model using GEDI data) of above ground carbon recovery across combinations of disturbance legacies among wildfire, drought, and insects. We aim to understand these trajectories and create a predictive model to interpolate GEDI footprint data and understand how these disturbances impact above ground biomass density.

# Data Sources
*Response:*
+ GEDI L4A Footprint Biomass product converts each high-quality waveform to an AGBD prediction (Mg/ha)
  
*Predictors/features:*
+ Geographic location (lat/lon)
+ 30-yr normals for climatic water deficit (‘def’) and actual evapotranspiration ('aet'); TopoFire Holden et al.
+ Tree cover; MODIS
+ Peak NDVI; Landsat
+ Forest type; NLCD
+ Time since disturbances; EarthLab “disturbance stack”
  + Fire
  + Insect outbreak
  + Hotter drought 

# Methods - The Model and Data Exploration
## Data Analysis

### Baseline  (null) model: Inverse-distance weighted interpolation
To have a baseline to compare against, we performed spatial interpolation using inverse distance weighting on the GEDI above-ground biomass density point estimates. 

```
gs <- gstat(formula = agbd~1, 
            locations = ~x+y, 
            data = full_df[,c("x","y","agbd")], 
            nmax = 50, 
            set = list(idp = 2))

# Interpolate based on IDW model
nn <- interpolate(r, gs, debug.level=0)

# Mask to SRE
idw_sre <- mask(nn["agbd_idw"], sre)
```

### Example of Weighted Interpolation 
<img width="312" alt="image" src="https://github.com/CU-ESIIL/FCC24_Group_6/assets/20931106/496d1dbd-c9a3-46ea-a8b1-7bf78a54a272">

Spatial interpolation using inverse-distance weighting. This simple interpolation method was used as a "null model" against which to evaluate our random forest model.


### Random Forest Modeling
Random forest modeling was performed on CyVerse using the R [spatialRF](https://blasbenito.github.io/spatialRF/) package. The script for modeling is [code/analysis/spatial_rf_model.R](https://github.com/CU-ESIIL/FCC24_Group_6/tree/gh-pages-documentation/code/analysis/spatial_rf_model.R). We trained a model with 500 trees, a minimum node size of 25, and mtry (the number of variables to possibly split with in each node) set to 3. 


```
model.non.spatial <- spatialRF::rf(
  data = train_df,
  dependent.variable.name = dependent.variable.name,
  predictor.variable.names = predictor.variable.names,
  xy = train_xy,
  seed = random.seed,
  verbose = FALSE,
  ranger.arguments=list(
    num.trees=500,
    mtry=3,
    min.node.size=25
  )
)
```

### Model Evaluation
Both models (the baseline inverse-distance weighting model and the random forest model) were trained on a training set consisting of 70% of the GEDI data rows. 15% of the data were used as a validation set and 15% were withheld as a final test set. After training, we computed RMSE and R^2 on the validation set to compare.


## Data Exploration & Visualizations
Visualizations of above ground biomass density versus fire, drought, and insect disturbances were created using Tidyverse ggplot methodology. We also explored the impact of these disturbance types on NDVI and forest type distribution in corelation with trajectories of disturbance recovery visuals. Above ground biomass density was limited to 500 Mg to exclude outliers.

### Range of Above Ground Biomass Distribution Across Southern Rocky Mountain EcoRegion
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/5ec244fc-5979-4387-8e37-b78386feb41a)

The figure illustrates the spatial variability of Above Ground Biomass Density in the Southern Rocky Mountain Ecoregion, with a color gradient reflecting biomass levels, ranging from low (yellow) to high (dark purple), based on GEDI lidar sensor data.

### Example of Disturbance Impact on Above Ground Biomass - Wildfire
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/a7fc6657-223f-42cf-8c9d-6adfd5c9f285)

# Results: Random Forest Model vs. Baseline Interpolation - The Biomass Prediction
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/24379590/ba8163e1-da49-447f-8244-888f709f5729)


## Results: Variable Importance
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/24379590/265cfad0-4ff5-4ae3-9e93-62f4f1d144dd)


## Results: Variable Response Curves & Surfaces
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/24379590/034d9429-e5f2-481a-84ad-970af80ecfe4)
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/24379590/b846ac3c-e975-4b2e-903c-7fc1692aaf8d)


## Results: Disturbance Recovery Trajectories
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/20931106/6fff997e-a6b5-4bcd-8815-4f8f878f532d)  

LOESS curves showing empirical post-disturbance biomass trajectories for three disturbance types.

# Conclusion



# Sketches by Luis X. de Pablo
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/5830be2b-dc72-4376-8ee7-701971c49374) ![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/40eb59b0-6e04-47d8-a2bb-5f05165ebbb7) ![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/5688c446-665a-4484-b08c-35d8c336d95e)

# Acknowledgments








