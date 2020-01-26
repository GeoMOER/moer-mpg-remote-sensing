---
title: "Spotlight: Spatial variable selection "
toc: true
toc_label: In this example
---

The appropriate collection of training data is essential for all monitored classifications. In theory, the rules to be followed are simple, but it is often difficult to achieve a robust, practical application. 

<!--more-->

## From arbitrary dimensioned Field data to Spatial continous Predictions

{% include figure image_path="/assets/images/researcharea.jpg" alt="Illustration of the MOF research area." %}


## Land Cover Classification

{% include figure image_path="/assets/images/MOF_trainings_concept.jpg" alt="Illustration of a spatial training data sampling concept." %}


Please note that especially the spatial validation concepts is a cutting edge theme for spatial prediction of data. The following talks will give you a brief introduction
{: .notice--info} 

## Talks

[Machine learning applications in environmental remote sensing](https://www.youtube.com/watch?v=mkHlmYEzsVQ&list=PLXUoTpMa_9s1npXD6S9M0_2pUgnTd6cqV&index=11&t=0s){:target="_blank"}

[Machine learning in remote sensing applications Moving from data reproduction to spatial prediction" (practical)](https://htmlpreview.github.io/?https://github.com/HannaMeyer/OpenGeoHub_2019/blob/master/practice/ML_LULC.html){:target="_blank"}

## Reference
[Importance of spatial predictor variable selection in machine learning applications -Moving from data reproduction to spatial prediction](https://www.researchgate.net/publication/335819474_Importance_of_spatial_predictor_variable_selection_in_machine_learning_applications_-Moving_from_data_reproduction_to_spatial_prediction){:target="_blank"}

## Control Script

```r
#------------------------------------------------------------------------------
# Type: control script 
# Name: basic_rf_ffs_scv.R
# Author: Chris Reudenbach, creuden@gmail.com
# Description:  basic worflow for a random forest 
# forward feature selection prediction worflow
# Data: raster data stack of prediction variables , taining data
# Output: prediction of landuse clases 
# Copyright: Hanna Meyer, Chris Reudenbach, Thomas Nauss 2019, GPL (>= 3)
# URL: https://github.com/HannaMeyer/OpenGeoHub_2019/blob/master/practice/ML_LULC.Rmd
#------------------------------------------------------------------------------


# 0 - load packages
#-----------------------------
rm(list=ls())
library(caret)
library(CAST)
library(doParallel)
library(velox)

# 1 - source files
#-----------------
source(file.path(envimaR::alternativeEnvi(root_folder = "~/edu/mpg-envinsys-plygrnd",
                                          alt_env_id = "COMPUTERNAME",
                                          alt_env_value = "PCRZP",
                                          alt_env_root_folder = "F:/BEN/edu"),
                 "src/mpg_course_basic_setup.R"))
path_run<-envrmt$path_run
unlink(file.path(path_run,"*"), force = TRUE)

sagaLinks<-link2GI::linkSAGA()
gdalLinks<-link2GI::linkGDAL()
otbLinks<-link2GI::linkOTB()


# 2 - define variables
#---------------------

#  RGB image
aerialRGB  <- raster::stack(file.path(envrmt$path_aerial_org,"geonode-ortho_muf_1m.tif"))
# training data  https://github.com/HannaMeyer/OpenGeoHub_2019/tree/master/practice/data
trainSites <- sf::read_sf(file.path(envrmt$path_geostat2019,"trainingSites.shp"))
# correction of the ref system
trainSites <- sf::st_transform(trainSites,crs=projection(aerialRGB))
# load the spatial fold squares https://github.com/HannaMeyer/OpenGeoHub_2019/tree/master/practice/data
spfolds    <- sf:: read_sf(file.path(envrmt$path_geostat2019,"spfolds.shp"))

# plot it
#viewRGB(aerialRGB , r = 3, g = 2, b = 1, map.types = "Esri.WorldImagery")+
#mapview(trainSites)+mapview(spfolds)
# define classes and colors for the prediction map
cols_df <- data.frame("Type_en"=c("Beech","Douglas Fir","Field","Grassland", "Larch","Oak","Road","Settlement", "Spruce", "Water"),
                      "col"=c("brown4", "pink", "wheat", "yellowgreen","lightcoral", "yellow","grey50","red","purple","blue"))

# 3 - start code 
#-----------------

# create pred stack using the uavRst package

##- calculate some synthetic channels from the RGB image and the canopy height model
##- then extract the from the corresponding training geometries the data values aka trainingdata
trainDF <- uavRst::calc_ext(calculateBands    = TRUE,
                    extractTrain      = FALSE,
                    suffixTrainGeom   = "",
                    patternIdx        = "index",
                    patternImgFiles   = "geonode" ,
                    patterndemFiles   = "chm",
                    prefixRun         = "tutorial",
                    prefixTrainImg    = "",
                    rgbi              = TRUE,
                    indices           = c("VVI","VARI","RI","BI",
                                          "SI","HI","TGI","GLI",
                                          "GLAI"),
                    #channels          = c("red"),
                    rgbTrans          = FALSE,
                    hara              = TRUE,
                    haraType          = c("simple"),
                    stat              = TRUE,
                    edge              = TRUE,
                    morpho            = TRUE,
                    pardem            = FALSE,
                    #demType           = c("slope", "MTPI"),
                    kernel            = 3,
                    currentDataFolder = envrmt$path_aerial_org,
                    currentIdxFolder  = envrmt$path_data,
                    sagaLinks = sagaLinks,
                    gdalLinks = gdalLinks,
                    otbLinks =otbLinks)

# get the prediction stack  (load  and apply bandnames)
predStack  <- raster::stack(file.path(envrmt$path_data,"indexgeonode-ortho_muf_1m.gri"))
# load(file.path(envrmt$path_data,"tutorialbandNames.RData"))
# names(predStack)<-paste0(bandNames)

## extract data via velox

# convert raster stack to velox object
vxpredStack <- velox(predStack)
# extract polygon to dataframe 
tDF <- vxpredStack$extract(sp = trainSites,df = TRUE)
# rename the cols
names(tDF)<-c("id",names(predStack))
# brute force approach to get rid of NA
tDF<-tDF[ , colSums(is.na(tDF)) == 0]

## define predictor/ response col header
# tDF contains "id" + all predictor variables with valid values
predictors <- names(tDF)[2:length(names(tDF))]
response <- "Type"

## much slower raster extraction
# extr <- raster::extract(predStack, trainSites, df=TRUE)

# join the data tables
trainDF <- merge(tDF, trainSites, by.x="id", by.y="PolygonID")

# split data
set.seed(100)
trainids <- createDataPartition(trainDF$id,list=FALSE,p=0.15)
trainDat <- trainDF[trainids,]


# define control settings for basic cv
ctrl <- trainControl(method="cv", 
                     number =10, 
                     savePredictions = TRUE)

# train common rf model using doParallel for speeding up
cl <- makePSOCKcluster(4)
registerDoParallel(cl)
set.seed(100)
model <- train(trainDat[,predictors],
               trainDat[,response],
               method="rf",
               metric="Kappa",
               trControl=ctrl,
               importance=TRUE,
               ntree=75)
stopCluster(cl)

# validation of the model
# get all cross-validated predictions:
cvPredictions <- model$pred[model$pred$mtry==model$bestTune$mtry,]
# calculate Kappa etc:
confusionMatrix(cvPredictions$pred,cvPredictions$obs)$overall
# var importance
plot(varImp(model),plotType="selected")

# predict the classes
prediction <- predict(predStack,model)

# name the classes 
mapview(prediction,col.regions=as.character(cols_df$col))
spplot(prediction,col.regions=as.character(cols_df$col))

##-----------------------------------------------------------------------------
## now spatial cv with ffs

# leave location out spatial cv
set.seed(100)
folds <- CreateSpacetimeFolds(trainDat, spacevar="spBlock", k=20)

# define caret control settings
ctrl_sp <- trainControl(method="cv",
                        savePredictions = TRUE,
                        index=folds$index,
                        indexOut=folds$indexOut)

# train model 
cl <- makeCluster(4)
registerDoParallel(cl)
set.seed(100)
ffsmodel_spatial <- ffs(trainDat[,predictors],
                        trainDat[,response],
                        method="rf",
                        metric="Kappa",
                        tuneGrid=data.frame("mtry"=model$bestTune$mtry),
                        trControl = ctrl_sp,
                        ntree=75)
stopCluster(cl)

# plotting the results of the variable selection 
plot_ffs(ffsmodel_spatial)
plot_ffs(ffsmodel_spatial, plotType="selected")
# var importance
plot(varImp(ffsmodel_spatial))

# validation of the model
# get all cross-validated predictions and calculate kappa
cvPredictions <- ffsmodel_spatial$pred[ffsmodel_spatial$pred$mtry==ffsmodel_spatial$bestTune$mtry,]
confusionMatrix(cvPredictions$pred,cvPredictions$obs)$overall

# make ffs model based prediction
prediction_ffs <- predict(predStack,ffsmodel_spatial)

# plot it
spplot(prediction_ffs,col.regions=as.character(cols_df$col))+spplot(prediction,col.regions=as.character(cols_df$col))

```