# load libraries
library(tidyverse)

# set working directory
setwd("/home/jovyan/data-store/FCC24_Group_6")
getwd()

system('mkdir -p ~/data')
system('cp /data-store/iplant/home/shared/earthlab/linked_disturbance/data/linked_disturbance_data_frame.csv ~/data/')
disturbance_data <- read.csv('~/data/linked_disturbance_data_frame.csv') 