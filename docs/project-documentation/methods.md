# Project methods overview

## Data Sources

Unpublished aggregated data from [Linked Disturbance Group](https://github.com/tylerhoecker/linked_disturbance) from Forest Resilience Working Group. Used with permission of group. Data gathered from all public sources: GEDI, MODIS, and more. 

## Data Processing Steps - Luis (anything I missed)

Code for cleaning original data frame is in [data_wrangling.r](https://github.com/CU-ESIIL/FCC24_Group_6/blob/gh-pages-documentation/code/data-processing/data_wrangling.r).

This script saves a cleaned csv in ~/data/. The rest of the analyses load from this cleaned csv. 

## Data Analysis

### Baseline model: Kriging - Tyler
To have a baseline to compare against, we performed spatial kriging on the GEDI above-ground biomass density point estimates. 

### Random Forest Modeling - Kylen
Random forest modeling was performed on CyVerse using the R [spatialRF](https://blasbenito.github.io/spatialRF/) package. 

### Model Evaluation - Kylen
Both models (kriging and random forest) were trained on a training set consisting of 70% of the GEDI data rows. 15% of the data were used as a validation set and 15% were withheld as a final test set. After training, we computed RMSE and R^2 on the validation set to compare. 

## Visualizations - Nat/Bre/Luis
Describe visualizations created and any specialized techniques or libraries that users should be aware of.

## Conclusions
Summary of the full workflow and its outcomes. Reflect on the methods used.

## References
Citations of tools, data sources, and other references used.
