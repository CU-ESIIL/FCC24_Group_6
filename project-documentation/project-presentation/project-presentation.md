# Post-disturbance trajectories of aboveground biomass across the Southern Rocky Mountain Ecoregion 
Authors (listed alphabetically)

Tyler Hoecker, Vibrant Planet PBC

Luis X. de Pablo, University of Colorado Boulder, Dept. of Ecology and Evolutionary Biology/Biofrontiers Institute 

Bre Powers, Northern Arizona University, School of Forestry 

Kylen Solvik, University of Colorado Boulder, Depart. of Geography

Natalie Wiley, Brilliant Earth 

### Project Description
Forests could provide a nature-based solution to mitigate climate-change impacts by fixing and sequestering carbon. However, forests are under threat from increasingly frequent and severe disturbances including wildfire, drought, and insect outbreak. Using Earth observation data, forests can be monitored across large spatial scales and at increasingly high resolutions to observe forest measurements. The Global Ecosystem Dynamics Investigation (GEDI) provides high resolution laser footprints of forests at large spatial scales, enabling estimates of above-ground biomass density (AGBD). Utilizing these AGBD footprints in combination with data on disturbance histories, we predict AGBD for sites not covered by GEDI and model forest recovery trajectories following disturbances in the Southern Rocky Mountain ecoregion. The goal of this project is to understand trajectories of AGBD recovery after interacting wildfire, drought, and insect disturbances. We aim to understand the role of individual and interacting disturbances as drivers of AGBD and predict contemporary AGBD across the study region using GEDI footprint data.

### Research Questions
1. What is the relative importance of different disturbance combinations in shaping above ground biomass density?
2. How do post-disturbance biomass trajectories vary among disturbance types and combinations?
3. Do models that include information about disturbance predict biomass density better than models that do not?

# Methods 

## Data Sources
*Response variable:*
+ GEDI L4A Footprint Biomass product converts each high-quality waveform to an AGBD prediction (Mg/ha)
  
*Predictor variables/features:*
+ Geographic location (lat/lon)
+ 30-yr normals for climatic water deficit (‘def’) and actual evapotranspiration ('aet'); TopoFire Holden et al.
+ Tree cover; MODIS
+ Peak NDVI; Landsat
+ Forest type; NLCD
+ Time since disturbances; EarthLab “disturbance stack”
  + Fire
  + Insect outbreak
  + Hotter drought
    
## Data Exploration & Visualizations
Visualizations of above ground biomass density versus fire, drought, and insect disturbances were created using Tidyverse ggplot methodology. We also explored the impact of these disturbance types on NDVI and forest type distribution in corelation with trajectories of disturbance recovery visuals. Above ground biomass density was limited to 500 Mg to exclude outliers.

### Range of Above Ground Biomass Distribution Across Southern Rocky Mountain EcoRegion
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/5ec244fc-5979-4387-8e37-b78386feb41a)

The figure illustrates the spatial variability of Above Ground Biomass Density in the Southern Rocky Mountain Ecoregion, with a color gradient reflecting biomass levels, ranging from low (yellow) to high (dark purple), based on GEDI lidar sensor data.

### Example of Disturbance Impact on Above Ground Biomass - Wildfire
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/a7fc6657-223f-42cf-8c9d-6adfd5c9f285)

## Data Analysis

### Null model (inverse-distance weighted spatial interpolation) 
We evaluated the perfomance of a model that included informaiton about disturbance and environmental conditions against a null model based only on geographic location. We developed our null model based on a simple spatial interpolation among GEDI footprints using inverse distance weighting. Estimates were based on values of the 50 nearest neighbors, weighted by a power of 2 (i.e., inverse distance squared). We used the `gstat` package, impleneted in R.  

```
# Build IDW model
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

<img width="312" alt="image" src="https://github.com/CU-ESIIL/FCC24_Group_6/assets/20931106/496d1dbd-c9a3-46ea-a8b1-7bf78a54a272">

Spatial interpolation using inverse-distance weighting. This simple interpolation method was used as a "null model" against which to evaluate our random forest model.


### Random Forest Modeling
Random forest modeling was performed on CyVerse using the R [spatialRF](https://blasbenito.github.io/spatialRF/) package. The script for modeling is [code/analysis/spatial_rf_model.R](https://github.com/CU-ESIIL/FCC24_Group_6/tree/gh-pages-documentation/code/analysis/spatial_rf_model.R). We trained a model with 500 trees, a minimum node size of 25, and mtry (the number of variables to possibly split with in each node) set to 3. 


```
# Fit random forest model
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
- 13 variables were used as predictors in the model, including years since disturbance, location in UTM coordinates, and climatic variables (including actual evapotranspiration and climatic water deficit).
- We also multiplied each of the disturbance variables by each other (e.g. years since drought * years since fire) as a basic way to capture interactions between disturbances.
- A full list of predictor variables is available in the Methods section of this website. 

## Results: Variable Importance
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/24379590/265cfad0-4ff5-4ae3-9e93-62f4f1d144dd)

- Years since drought and years since fire appear important
- Interactions (e.g. years since drought * years since fire) also important
- Years since insect disturbance does not appear very important by itself.

## Results: Variable Response Curves & Surfaces
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/24379590/034d9429-e5f2-481a-84ad-970af80ecfe4)

- Shows how predictions change in response to varying years since disturbance (holding other variables constant).
- We see the basic patterns we'd expect: dip following the disturbance followed by recovery.
  
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/24379590/b846ac3c-e975-4b2e-903c-7fc1692aaf8d)

- Shows how predictions change with varying years since fire and years since drought together.
- We see the lowest aboveground biomass density when there are successive drought and fire disturbances, with 10-15 years since drought and 5-10 years since fire. 

### Model Evaluation
Both models (the baseline inverse-distance weighting model and the random forest model) were trained on a training set consisting of 70% of the GEDI data rows. 15% of the data were used as a validation set and 15% were withheld as a final test set. After training, we computed RMSE and R^2 on the validation set to compare.

# Results: Random Forest Model vs. Baseline Interpolation - The Biomass Prediction
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/24379590/ba8163e1-da49-447f-8244-888f709f5729)

*The random forest model outperformed the baseline spatial interpolation model based on RMSE and R^2.* 

## Results: Disturbance Recovery Trajectories
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/20931106/6fff997e-a6b5-4bcd-8815-4f8f878f532d)  

LOESS curves showing empirical post-disturbance biomass trajectories for three disturbance types (colored solid lines) and the mean biomass of samples that did not experience any of the three disturbances in the last 20 years (dashed line).

# Discussion and Conclusion
<img width="869" alt="image" src="https://github.com/CU-ESIIL/FCC24_Group_6/assets/20931106/6dc3be48-cfc8-4f1e-9995-ed8289bcc873">

Idealized conceptual diagram showing trajectories of live (purple) and dead (orange) and total biomass pool (black) trajectories after disturbance; successful (solid) and failed (dashed) recovery trajecetories are illustrated.

This project utilized GEDI lidar sensor data to map and analyze Above Ground Biomass Density (AGBD) in the Southern Rocky Mountain Ecoregion. The application of spatial random forest models provided new insights into the trajectories of carbon recovery following various disturbances, such as drought, insect outbreaks, and fire. We were able to predict AGBD outside of GEDi’s direct coverage and assess the impact of past disturbances on forest carbon storage. Future work will focus on refining these models for  precision and validating models against independent datasets, ensuring their robustness and reliability of predicting effects of disturbance on AGBD. These types of predictive models are useful for informing sustainable forest management under the evolving pressures of climate change.

# Sketches by Luis X. de Pablo
![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/5830be2b-dc72-4376-8ee7-701971c49374) ![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/40eb59b0-6e04-47d8-a2bb-5f05165ebbb7) ![image](https://github.com/CU-ESIIL/FCC24_Group_6/assets/122820473/5688c446-665a-4484-b08c-35d8c336d95e)

# Acknowledgments
We gratefully acknowledge the work of the "Linked Disturbances" working group that organized during ESIIL's Forest Resilience workshop in spring 2023, who outlined similar research questions and compiled the dataset we used here. Including: Megan Cattau, Kyra Clark-Wolf, Xiulin Gao, Tyler Hoecker, Adam Mahood, Tyler McIntosh, Asha Paudel, and Bre Powers.  



