---
title: "Control files and functions"
toc: true
toc_label: In this example
---


At the moment there don't seem to be any real advantages to using functions instead of control scripts.  The main reason is that we just created a batch file that simply processes external functions (e.g. those of the lidR package) one after the other.
<!--more-->
However, we also notice that we still have to do a lot of preprocessing and already the control files are starting to get cluttered. 
Therefore it makes sense to separate and generalize some repetitive functionalities.  For example, the preprocessing of the lidar data up to the correct setup of the catalog. 

Keep in mind we should go one step further and [follow Hadley Wickham's explanation](https://r4ds.had.co.nz/functions.html#when-should-you-write-a-function) when you should write a function?  

# Splitting up the control file
However we start simply with splitting up the control files to clarify the structure and reduce the redundant repetitions.

It is a good practice to separate at least setup of a projet, data pre-processing, data analysis and the presentation of the results. 
{: .notice--success}

This separation means that we need a kind of a master control script that rules the workflow and provides general settings. 

We start bottom up. First we transform the clipping into a function.


## Example 10_preprocess_RGB.R

So if I want to extract a section from a LAS file it would be very helpful to be able to call this as a function. In this call at least the data file and the coordinates have to be passed.

Furthermore it is mandatory for further projects to have a detailed or standardized documentation. This costs once more time but pays off more than.  Please note that the following examples already use the `Roxygen2` documentation syntax which can be used later for automated documentation 

Let us start with the `10_preprocess_RGB.R` control script. This script already uses a setup script (`000_setup.R`) to create a reproducible environment. So we have to identify four different aspects:

* what is code that is used again and again? -> make a function of it
* what is the general setup for my working environment? -> put it into the setup script
* what are the overall control structures (workflow, settings etc.)-> create a master control file for ruling the rest

### The original control file

```r
#------------------------------------------------------------------------------
# Type: control script 
# Name: 10_preprocess_RGB.R
# Author: Chris Reudenbach, creuden@gmail.com
# Description:  - fixes the white areas of airborne RGB images
#               - merge all image to one image
#               - clip the image to the sapflow half moon
#              
#              
# Data: regular authority provided airborne RGB imagery 
# Output: merged, clipped and corrected image of AOI
# Copyright: Chris Reudenbach, Thomas Nauss 2017,2020, GPL (>= 3)
# git clone https://github.com/GeoMOER-Students-Space/msc-phygeo-class-of-2020-creu.git
#------------------------------------------------------------------------------

## clean your environment
rm(list=ls()) 

# 0 - load additional packages
#-----------------------------
# for an unique combination of all files in the file list
# google expression: rcran unique combination of vector 
# alternative google expression: expand.grid unique combinations
# have a look at: https://stackoverflow.com/questions/17171148/non-redundant-version-of-expand-grid
add_pkgs = c("gtools")


## dealing with the crs warnings is cumbersome and complex
## you may reduce the warnings with uncommenting  the following line
## for a deeper  however rarely less confusing understanding have a look at:
## https://rgdal.r-forge.r-project.org/articles/CRS_projections_transformations.html
## https://www.r-spatial.org/r/2020/03/17/wkt.html
rgdal::set_thin_PROJ6_warnings(TRUE)


# 1 - source files
#-----------------
source(file.path(envimaR::alternativeEnvi(root_folder = "~/edu/mpg-envinsys-plygrnd/",
                                          alt_env_id = "COMPUTERNAME",
                                          alt_env_value = "PCRZP",
                                          alt_env_root_folder = "F:/BEN/edu/mpg-envinsys-plygrnd"),
                 "msc-phygeo-class-of-2020-creu/src/000_setup.R"))


# 2 - define variables
#---------------------

## define current projection (It is not magic you need to check the meta data 
## or ask your instructor) 
## ETRS89 / UTM zone 32N
## the definition of proj4 strings is kind ob obsolet have a look at the links under section zero
epsg_number = 25832

set.seed(1000)

# creating a list for files to be deleted if necessary
r_flist = ""

# test area so called "sap flow halfmoon"
xmin = 477500
ymin = 5631730
xmax = 478350

ymax = 5632500


# for an unique combination of all files in the file list
# google expression: rcran unique combination of vector 
# alternative google expression: expand.grid unique combinations
# have a look at: https://rdrr.io/cran/gimme/src/R/expand.grid.unique.R
expand.grid.unique <- function(x, y, incl.eq = FALSE){
        g <- function(i){
                z <- setdiff(y, x[seq_len(i - incl.eq)])
                if(length(z)) cbind(x[i], z, deparse.level = 0)
        }
        do.call(rbind, lapply(seq_along(x), g))
}



# 3 - start code 
#-----------------

#---- this part is for clipping only

# Get all *.las files of a the folder you have specified to contain the original las files
tif_files = list.files(envrmt$path_aerial_org, pattern = glob2rx("*.tif"), full.names = TRUE)

# we create a unique combination of all files for a brute force comparision of the extents
# first possibility using the sourced function from the gimme library
df = expand.grid.unique(tif_files,tif_files)
# second possibility using the combinations() function from the gtools package
#----- NOTE it is not necessary to write the code by yourself 
#      you need to know (1) What do you want to do (2) What do you need (3) express it to google
df = combinations(n = length(tif_files), r = 2, v = tif_files, repeats.allowed = FALSE)

#---- The idea is to check for each unique pair of files if they have the same extent
#     if so we fix the white area using the formula image A + image B - 255
#     additionally we write this file to the name without the "_1" extension and 
#     rename the "_1" file in "_1~" what t least means on unix flavoured systems 
#     that it is handled as a backup file

no_comb = nrow(df)
fixed = 0

# for loop for each element of the data frame (nrow())


for (i in 1:nrow(df)) {
        if (raster(df[i,1])@extent==raster(df[i,2])@extent){ # compare the extent
                cat("fix ",df[i,1]," ", df[i,2],"\n")        # output for information 
                new_raster = stack(df[i,1]) + stack(df[i,2]) - 255  # formula to fix
                cat("write ",paste0(envrmt$path_aerial_org,basename(max(df[i,]))),"\n") # output for information
                writeRaster(new_raster,  paste0(envrmt$path_aerial_org,basename(max(df[i,]))),overwrite=T) # save it
                cat("rename ",paste0(envrmt$path_aerial_org,basename(min(df[i,]))),"\n") # output for information
                r_flist = append(r_flist,paste0(envrmt$path_aerial_org,basename(min(df[i,]))))
                fixed = fixed + 1
        } 
}
cat(no_comb ," combinations checked\n ",fixed," images are fixed\n")
file.remove(r_flist)

#---- now we need to merge these images to on big image
#     again lets have a look what google tell us
#     google expression: merging multiple rasters R cran     
#     https://stackoverflow.com/questions/15876591/merging-multiple-rasters-in-r
#     with regards to Flo Detsch who asked it the right way

# ok lets follow the rabbit

# create a list for the files to be merged
mofimg=list()
# get new filelist
tif_files = list.files(envrmt$path_aerial_org, pattern = glob2rx("*.tif"), full.names = TRUE)
# stacking all files and put them in the list object
cat("stack files...\n")
for (f in 1:length(tif_files)){
mofimg[[f]] = stack(tif_files[f])
}

# setting the parameters
mofimg$tolerance = 1
mofimg$filename  = paste0(envrmt$path_aerial_org,"merged_mof.tif")
mofimg$overwrite = TRUE
cat("merge files - this will take a while \n")
merged_mof = do.call(raster::merge, mofimg)

# cropping it using the ?crop or ?clip and decide  
# or google for something like "crop clip raster images R cran"
# as a result you need a vector file or an extent

# defining the extent object using the above defined params 
# for more info ?extent
cat("crop AOI\n")
ext <- extent(xmin,xmax,ymin,ymax)

# cropping it
sapflow  =  crop(merged_mof, ext)	

# 4 - visualize 
# -------------------

plotRGB(merged_mof)

plotRGB(sapflow)





```


### Step 1: Extract the general variables and functions - Adaption of 000_setup.R
To utilize this concept we need to adapt the `000_setup.R` script. Basically we have add the argument `fkts` which is pointing to a folder which contains all of our functions - in this case the `cut_mof()` function. Additionally we have moved some of the common variables and options in the basic setup file. 

```r
#---- mpg course basic setup
# install/check from github
devtools::install_github("envima/envimaR")
#devtools::install_github("gisma/uavRst")
devtools::install_github("r-spatial/link2GI")

library(envimaR)

packagesToLoad = c("lidR", "link2GI", "mapview", "raster", "rgdal", "rlas", "sp",  "sf")

mvTop<-mapview::mapviewPalette("mapviewTopoColors")
mvSpec<-mapviewTopoColors<-mapview::mapviewPalette("mapviewSpectralColors")

# get viridris colAZor palette
pal<-mapview::mapviewPalette("mapviewTopoColors")

#########################################################################

# define rootfolder
rootDir = envimaR::alternativeEnvi(root_folder = "/home/creu/edu/mpg-envinsys-plygrnd/",
                                   alt_env_id = "COMPUTERNAME",
                                   alt_env_value = "PCRZP",
                                   alt_env_root_folder = "F:/BEN/edu")


# define project specific subfolders
projectDirList   = c("data/",                # datafolders for all kind of date
                     "data/auxdata/",        # the following used by scripts however
                     "data/aerial/",     # you may add whatever you like                     
                     "data/aerial/org/",     # you may add whatever you like
                     "data/lidar/org/",
                     "data/lidar/",
                     "data/grass/",
                     "data/lidar/level0/",                     
                     "data/lidar/level1/",
                     "data/lidar/level1/normalized",
                     "data/lidar/level1/ID",
                     "data/lidar/level2/",
                     "data/lidar/level0/all/",
                     "data/data_mof", 
                     "data/tmp/",
                     "run/",                # temporary data storage
                     "log/",                # logging
                     "src/",                # scripts
                     "/doc/")                # documentation markdown etc.

############################################################################
############################################################################
############################################################################
# setup of root directory, folder structure and loading libraries
# returns "envrmt" list which contains the folder structure as short cuts
envrmt = envimaR::createEnvi(root_folder = rootDir,
                             folders = projectDirList,
                             path_prefix = "path_",
                             libs = packagesToLoad,
                             alt_env_id = "COMPUTERNAME",
                             alt_env_value = "PCRZP",
                             fcts_folder = file.path(rootDir,"msc-phygeo-class-of-2020-creu/src/fun/"),
                             alt_env_root_folder = "F:/BEN/edu")
# set raster temp path
raster::rasterOptions(tmpdir = envrmt$path_tmp)

## dealing with the crs warnings is cumbersome and complex
## you may reduce the warnings with uncommenting  the following line
## for a deeper  however rarely less confusing understanding have a look at:
## https://rgdal.r-forge.r-project.org/articles/CRS_projections_transformations.html
## https://www.r-spatial.org/r/2020/03/17/wkt.html
rgdal::set_thin_PROJ6_warnings(TRUE)

###############################
# test area so called "sap flow halfmoon"
xmin = 477500
ymin = 5631730
xmax = 478350
ymax = 5632500

## define current projection ETRS89 / UTM zone 32N
## the definition of proj4 strings is DEPRCATED have a look at the links under section zero
epsg = 25832
# for reproducible random
set.seed(1000)

return(envrmt)
```
### Step 2 Create a main control file

We set up a preliminary master control file 00_classify_RGB.R This file has to rule the whole process. 

Due to the fact that all other controll files are sourced we create a batch of variables products step by step. Keep in mind that this may result in weird situations if you are messing up in between variable names etc.
{: .notice--danger}
```r
#------------------------------------------------------------------------------
# Type: control script 
# Name: 00_classify_RGB.R
# Author: Chris Reudenbach, creuden@gmail.com
# Description:  - fixes the white areas of airborne RGB images
#               - merge all image to one image
#               - clip the image to the sapflow half moon
#               - calculates synthetic bands
#               -
#               -
#               
# Data: regular authority provided airborne RGB imagery 
# Output: merged, clipped and corrected image of AOI, stack of synthetic bands
# Copyright: Chris Reudenbach, Thomas Nauss 2017,2020, GPL (>= 3)
# git clone https://github.com/GeoMOER-Students-Space/msc-phygeo-class-of-2020-creu.git
#------------------------------------------------------------------------------

## clean your environment
## 
rm(list=ls()) 


# 0 - load additional packages
#-----------------------------
# for an unique combination of all files in the file list
# google expression: rcran unique combination of vector 
# alternative google expression: expand.grid unique combinations
# have a look at: https://stackoverflow.com/questions/17171148/non-redundant-version-of-expand-grid
library(gtools)
require(envimaR)

# 1 - source setup file


source(file.path(envimaR::alternativeEnvi(root_folder = "~/edu/mpg-envinsys-plygrnd",
                                          alt_env_id = "COMPUTERNAME",
                                          alt_env_value = "PCRZP",
                                          alt_env_root_folder = "F:/BEN/edu/mpg-envinsys-plygrnd"),
                 "msc-phygeo-class-of-2020-creu/src/000_setup.R"))



# 2 start analysis 
#-----------------
## source control 05 
source(05_RS_prepcrocess_RGB.R")

## source control 20
source("20_RScalculate_synthetic_bands.R")


## source control 30
source("30_RS_extract_training_df.R")

## source control 30
source("30_RS_prepare_training_df.R")


## source control 50
source("50_RS_LLO_rf_classification.R")


```
### Step 3 Cleaning the original script


```r
#------------------------------------------------------------------------------
# Type: control script 
# Name: 05_preprocess_RGB.R
# Version 0.2
# Author: Chris Reudenbach, creuden@gmail.com
# Description:  - destripe the white areas of the airborne RGB images
#               - merge all images in a folder to one image
#               - clip the image to a defined (NOTE by default as defined in setup)
#                 the "sap flow half moon" extent is used
#              
# changelog 0.2:- merge and correction code has moved to functions
#               - It is tested now if the files exist 
#                 to jump over the time consuming process of 
#                 correcting merging, projecting and cropping the data
#               - all output filenames names are defined by variables 
#
# Data: regular authority provided airborne RGB imagery 
# Output: merged, clipped and corrected image of AOI is written to filesystem 
#         and added to the environment (aoi_RGB)
# Copyright: Thomas Nauss, Chris Reudenbach 2017,2020, GPL (>= 3)
# git clone https://github.com/GeoMOER-Students-Space/msc-phygeo-class-of-2020-creu.git
#------------------------------------------------------------------------------

# 0 - additional libraries
#----------------
library(gtools)
require(envimaR)

# 1 - source files
#-----------------

## source setup file 
## NOTE you MUST adapt the last line according to your needs
cat(":::: sourcing setup file \n")
source(file.path(envimaR::alternativeEnvi(root_folder = "~/edu/mpg-envinsys-plygrnd",
                                          alt_env_id = "COMPUTERNAME",
                                          alt_env_value = "PCRZP",
                                          alt_env_root_folder = "F:/BEN/edu/mpg-envinsys-plygrnd"),
                 "msc-phygeo-class-of-2020-creu/src/000_setup.R"))

# 2 - define variables
#---------------------

# link to the GI packages
# adapt it to your needs
gdal<-linkGDAL()
saga<- link2GI::linkSAGA()
otb<- link2GI::linkOTB(searchLocation = "/usr/bin/")

# create a list for storing temporary files for latter deletion
r_flist = ""

# create deprecated proj4 projection string
crs_rgb=sp::CRS("+init=epsg:32632")

# modify cropping extent according to example training data
# see: https://github.com/HannaMeyer/OpenGeoHub_2019/blob/master/practice/data/
trainSites <- sf::read_sf(file.path(envrmt$path_auxdata,"training_MOF_1m.shp"))
trainSites <- sf::st_transform(trainSites,crs=crs_rgb)
# defining the cropping extent
ext <- extent(trainSites)

# define file name and location
mergename=file.path(envrmt$path_aerial,"MOF_rgb_merged.tif")
outname=file.path(envrmt$path_aerial,"MOF_rgb.tif")

# start processing 
#-----------------------------------------

##-- if necessary correcting the white stripes
# get list of files
# NOTE adapt the wildcard in the glob2rx call if necessary
tif_files = list.files(envrmt$path_aerial_org, pattern = glob2rx("4*.tif"), full.names = TRUE)
destripe_rgb(files = tif_files,
             envrmt = envrmt)


##-- if the merge file exist just load it for cropping
if(file.exists(mergename)){
  merged_mof = raster::stack(mergename)
} else {
  
##-- merge and re-project the single images
# NOTE adapt the wildcard in the glob2rx call if necessary
  tif_files = list.files(envrmt$path_aerial_org, pattern = glob2rx("4*.tif"), full.names = TRUE)
  merged_mof = merge_rgb(files = tif_files,
                         output = mergename,
                         cropoutput=outname,
                         proj4 = crs_rgb,
                         ext = ext)
}

# cropping it
if(!file.exists(outname)){
cat("crop AOI\n")
aoi_RGB  =  crop(merged_mof, ext)	

# save the croped raster
raster::writeRaster(aoi_RGB ,
                    outname,
                    overwrite=TRUE,
                    progress="text")
}

cat(getCrayon()[[3]](":::: finished 05_RS_preprocess_RGB.R\n"))
cat(getCrayon()[[1]](":::: merged file is saved at: ",mergename,"\n"))
cat(getCrayon()[[1]](":::: cropped file is saved at: ",outname ,"\n"))
```

### Step 4 Identifying candidates for functions
You will see that the pretty simple code for merging has obviously inflated. Why should we do so? Actually we have evolved a hard coded script into a fairly well documented function that is usable for for all kind of merging raster data. In addition if we provide a filename and extent for cropping the merged image it is also doing it. And last but not least if we provide a valid proj4 string it will reproject the result. So whenever we need to merge/crop/reproject raster files (which happens fairly often) we may use it. 

### merge_rgb 
```r
#' merge single images
#' @description  merge single geocoded images to on big image
#' @param files list of filenames to be merged
#' @param proj4 valid proj4 string 
#' @param output valid path and name for the output image
#' @param ext valid extent of the the area that is requested
#
#' @details https://stackoverflow.com/questions/15876591/merging-multiple-rasters-in-r
#'     with regards to Flo Detsch who asked it the right way
#' @note if proj4 is NULL no reprojection is performed otherwise the merged raster is projected by using the proj4 string.      
#' @return The merged image as a raster object 
#' # example
#' # tif_files is a list of valid filenames
#' merged_r = merge_rgb(files = tif_files,
#'                      out = file.path(tempdir(),"out.tif"))
#' @export merge_rgb                     
#' 

merge_rgb = function(files=NULL,proj4=NULL,output=NULL,cropoutput=NULL,ext=NULL){
  # create a list for the files to be merged
  mofimg=list()
  # get new filelist
  
  if (is.null(files) || is.null(output)) return("Input/Output arguments are not valid\n")
  
  # stacking all files and put them in the list object
  cat("stack files...\n")
  for (f in 1:length(files)){
    mofimg[[f]] = stack(files[f])
  }
  
  # setting the merging parameters

  if(!is.null(ext)){
    mofimg$tolerance = 1
    mofimg$overwrite = TRUE
    mofimg$filename  = cropoutput
    mofimg$ext = ext
    
    cat(getCrayon()[[3]]("merge and crop files - this will take quite a while \n"))
  } else {
    mofimg$tolerance = 1
    mofimg$filename  = output
    mofimg$overwrite = TRUE
    mofimg$ext = ext
    cat(getCrayon()[[3]]("merge files - this will take quite a while \n"))
  }
  r = do.call(raster::merge, mofimg)
  
  # reproject it 
  if (!is.null(proj)){
    cat(getCrayon()[[3]]("Projecting image... this will take even longer\n"))
    r = raster::projectRaster(r,crs = proj4)}
  
  return(r)
}
```

### destripe_rgb

Now it is your turn. Beneath you find the raw function for destriping. You may use the upper function as a kind of template to improve the destriping in a similar way.

```r
destripe_rgb = function(files = tif_files,
                        envrmt = envrmt)
  {
  # we create a unique combination of all files for a brute force comparision of the extents
  df = combinations(n = length(tif_files), r = 2, v = tif_files, repeats.allowed = FALSE)
  no_comb = nrow(df)
  fixed = 0
  
  # for loop for each element of the data frame (nrow())
  for (i in 1:nrow(df)) {
    if (raster(df[i,1])@extent==raster(df[i,2])@extent){ # compare the extent
      cat("fix ",df[i,1]," ", df[i,2],"\n")        # output for information 
      new_raster = stack(df[i,1]) + stack(df[i,2]) - 255  # formula to fix
      cat("write ",paste0(envrmt$path_aerial_org,basename(max(df[i,]))),"\n") # output for information
      writeRaster(new_raster,  paste0(envrmt$path_aerial_org,basename(max(df[i,]))),overwrite=T) # save it
      cat("rename ",paste0(envrmt$path_aerial_org,basename(min(df[i,]))),"\n") # output for information
      r_flist = append(r_flist,paste0(envrmt$path_aerial_org,basename(min(df[i,]))))
      fixed = fixed + 1
    } 
  }
  file.remove(r_flist)
  return(message(no_comb ," combinations checked\n ",fixed," images are fixed\n"))
}
```

## Bring it together

After extracting the functions you have to adapt the main script. This process of refinement will give you a good chance to re-think the implementation and structure of workflow and is a valuable opportunity to evaluate your concepts and code. 

You will find more examples cloning the repo  `git clone https://github.com/GeoMOER-Students-Space/msc-phygeo-class-of-2020-creu.git`