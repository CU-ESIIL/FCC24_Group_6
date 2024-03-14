# install.packages('Metrics')
library(tidyverse)
library(Metrics)

# Read in predictions
baseline_df <- read_csv('~/data/valid_null.csv')
val_df <- read_csv('~/data/predicted_val_v3.csv')

# Need to remove points with NA values for peakNDVI (since RF can't predict on that)
# df_temp <- read_csv('~/data/linked_disturbance_data_clean.csv')
# val_df_peakndvi_naclean <- df_temp[df_temp$test_validation_training=='validation',]

# ndvi_goodvalues <- !is.na(val_df_peakndvi_naclean$peakNDVI)
# baseline_df <- baseline_df[ndvi_goodvalues,]

# The kriging results have one NA, so we'll remove that as well
# baseline_goodvalues <- !is.na(baseline_df$agbd_idw)
# val_df <- val_df[baseline_goodvalues,]
# baseline_df <- baseline_df[baseline_goodvalues,]

# Calculate RMSE
rmse(val_df$agbd, val_df$predicted)
rmse(baseline_df$agbd, baseline_df$idw_pred)

# Calculate R2
cor(baseline_df$agbd, baseline_df$idw_pred)^2
cor(val_df$agbd, val_df$predicted)^2

val_df$residual <- val_df$agbd - val_df$predicted
baseline_df$residual <- baseline_df$agbd - baseline_df$idw_pred

# Plot
hist(val_df$residual)
hist(baseline_df$residual)

ggplot() +
  geom_histogram(data = val_df, aes(x = residual), fill = "red", bins=100) +
  geom_histogram(data = baseline_df, aes(x = residual),  fill = "transparent", col='blue',bins=100) +
  scale_color_manual(name=c('RF','Baseline')) +
  labs(x='Model Residual (Mg/ha)', y='Count', title='Model Residual Histograms: Baseline vs. RF')
  
  
ggplot() +
  geom_smooth(data = val_df[1:1000,], aes(x = agbd, y=predicted), method='lm', col='blue') +
  geom_smooth(data = baseline_df[1:1000,], aes(x = agbd, y=idw_pred), method='lm',col='red')





