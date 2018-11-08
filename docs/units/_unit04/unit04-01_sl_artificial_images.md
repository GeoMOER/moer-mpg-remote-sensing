---
title: "Spotlight: Artificial Images"
---

Artificial images result from mathematical operations on image data. The operations are pixel or neighborhood based.

<!--more-->

## Artifical image computations
Artificial images can be used to highlight certain aspects of the spectral information recorded in the original dataset or its horizontal pattern. To compute artificial images, new values have to be calculated for each pixel in the original datasets (original data can be the initially recorded data or any other artificial image which has already been computed). For an extreme example on the utilization of artificial images see e.g. [Meyer et al. 2017](https://www.tandfonline.com/doi/abs/10.1080/2150704X.2017.1312026){:target="_blank"} who uses over 300 artificial images to estimate their usability in satellite rainfall retrievals.

### Pixel-wise computation
If the  computation is pixel-wise, only those original pixel values are included in the computation at a time which are located at the same position as the respective target pixel. Examples for this type of computation are any kind of spectral index values like the Normalized Different Vegetation Index (NDVI, see [this NASA page](https://earthobservatory.nasa.gov/Features/MeasuringVegetation/measuring_vegetation_2.php){:target="_blank"}). A principal component analysis, also based on the entire dataset, can also be regarded as pixel-wise since the final value of e.g. the first principal component at a specific pixel location results from the transformation of the original pixel values at this position. 

A special type of pixel-wise computation is the aggregation of LiDAR or other point cloud values into a regular raster and compute information like the minimum or maximum value in this point cloud subset or the number of points etc.

### Neighborhood-based computation
If the computation includes neighboring pixels, the value of the respective target pixel results from a odd number of original pixels located in e.g. a 3 by 3 or 5 by 5 neighborhood of the target pixel including the value of the original pixel in the the center. Examples for this type are any kind of spatial filters, e.g. a standard deviation filter. A prominent group is associated with grey level co-occurence matrix. In general, some filters can not only be based on a single original data layer but a stack of layers.

The following gallery shows three examples of spatial filters.

![]({{ site.baseurl }}/assets/images/rmd_images/e01-01/unnamed-chunk-1-1.png)

### Morphological feature computation
A second spatial method aims in computing morphological features based on individual raster values. A typical data source is a digital elevation model and typical target datasets are rasters showing the slope, exposition etc. of the surface.

## Starting with artifical image computation in R
A good starting point for spatial filtering with R is the [raster::focal](https://www.rdocumentation.org/packages/raster/versions/2.7-15/topics/focal){:target="_blank"} function for "classic" spatial filtering or the [glcm package](https://cran.r-project.org/package=glcm){:target="_blank"} for grey level co-occurence matrix computations). For the latter, the [Orfeo ToolBox](https://www.orfeo-toolbox.org/){:target="_blank"} offers a large set of Haralick texture computation functions. To link it with R, see the [link2GI](https://cran.r-project.org/web/packages/link2GI/index.html){:target="_blank"} package and the otbtex_* functions of the [uavRst](https://github.com/gisma/uavRst){:target="_blank"} package.







