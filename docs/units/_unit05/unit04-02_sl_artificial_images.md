---
title: "Spotlight: Artificial Images"
---

Artificial images result from mathematical operations on image data. The operations are pixel or neighborhood based.

<!--more-->

## Artifical image computations
Artificial images can be used to highlight certain aspects of the spectral information recorded in the original dataset or its horizontal pattern. To compute artificial images, new values have to be calculated for each pixel in the original datasets (original data can be the initially recorded data or any other artificial image which has already been computed). 

For an extreme example on the utilization of artificial images see e.g. [Meyer et al. 2017](https://www.tandfonline.com/doi/abs/10.1080/2150704X.2017.1312026){:target="_blank"} who uses over 300 artificial images to estimate their usability in satellite rainfall retrievals.

A list of (minimum) available indices can be found in the [Index Data Base](https://www.indexdatabase.de/db/i.php){:target="_blank"} of Verena Henrich and Katharina Brüser at Bonn University.
{: .notice--info}
 

The principal component analysis (PCA) is widely used to reduce the dimensionality and arbitray effects in the data (see e.g.[Principal Component Methods in R: Practical Guide ](http://www.sthda.com/english/articles/31-principal-component-methods-in-r-practical-guide/112-pca-principal-component-analysis-essentials/)). In remote sensing based approaches it is most often an approach to reduce the number of bands without loosing to much information. That means it provides a smaller number but uncorrelated synthetic bands. Especially for the calculation of RGB-imagery based texture and structure analysis this seems to be a promising approach to rely on the maximum possible information in **one** synthetic band (usually the first main component).  Beside the basic implementation in the `raster` package (see [raster rs turorial](https://rspatial.org/rs/rs.pdf)) a convenient alternative package is [RStoolbox](https://bleutner.github.io/RStoolbox/rstbx-docu/RStoolbox.html) for performing this job.


For getting an idea of the combination of (1) spectral indices, (2) textures and (3) a principal component analsysis (PCA) exemplarily have a look at [Li et al. 2019](https://www.mdpi.com/2072-4292/11/15/1763/pdf).

## Computational Approaches

### Pixel-wise computation
If the  computation is pixel-wise, only those original pixel values are included in the computation at a time which are located at the same position as the respective target pixel. Examples for this type of computation are any kind of spectral index values like the Normalized Different Vegetation Index (NDVI, see [this NASA page](https://earthobservatory.nasa.gov/Features/MeasuringVegetation/measuring_vegetation_2.php){:target="_blank"}). A principal component analysis, also based on the entire dataset, can also be regarded as pixel-wise since the final value of e.g. the first principal component at a specific pixel location results from the transformation of the original pixel values at this position. 

A special type of pixel-wise computation is the aggregation of LiDAR or other point cloud values into a regular raster and compute information like the minimum or maximum value in this point cloud subset or the number of points etc.

For the RGB based indes a basic call would look like:

```
# example calculat a vegetation indices from rgb image
# VVI http://phl.upr.edu/projects/visible-vegetation-index-vvi
# getting some example data
library(link2GI)
data('rgb', package = 'link2GI')  
red =  rgb[[1]]
green = rgb[[2]]
blue = rgb[[3]]
## calculate   Visible Vegetation Index (VVI)
  VVI = (1 - abs((red - 30) / (red + 30))) * 
        (1 - abs((green - 50) / (green + 50))) * 
        (1 - abs((blue - 1) / (blue + 1)))
raster::plot(VVI)

```
![]({{ site.baseurl }}/assets/images/vvi/vvi-1.png)

### Neighborhood-based computation
If the computation includes neighboring pixels, the value of the respective target pixel results from a odd number of original pixels located in e.g. a 3 by 3 or 5 by 5 neighborhood of the target pixel including the value of the original pixel in the the center. Examples for this type are any kind of spatial filters, e.g. a standard deviation filter. A prominent group is associated with grey level co-occurence matrix. In general, some filters can not only be based on a single original data layer but a stack of layers.

The following gallery shows three examples of spatial filters.

{% include gallery_collection gallery_path = "images/filters" caption = "Examples of focal computations." %}

The sobel filter is computed using the following matrix supplied to the raster::focal function.
```r
#getting data
library(link2GI)
library(raster)
data('rgb', package = 'link2GI')

kx = matrix(c(-1,-2,-1,0,0,0,1,2,1), ncol=3)
ky = matrix(c(1,0,-1,2,0,-2,1,0,-1), ncol=3)
k = (kx**2 + ky**2)**0.5

sobel_raster <- focal(rgb[[1]], w=k)
plot(sobel_raster)
```
![]({{ site.baseurl }}/assets/images/sobel/sobel.png)

### Morphological feature computation
A second spatial method aims in computing morphological features based on individual raster values. A typical data source is a digital elevation model and typical target datasets are raster showing the slope, exposition etc. of the surface. Actually this means the calculation of neighborhood indices and so on.

## Starting with artifical image computation in R
A good starting point for spatial filtering with R is the [raster::focal](https://www.rdocumentation.org/packages/raster/versions/2.7-15/topics/focal){:target="_blank"} function for "classic" spatial filtering or the [glcm package](https://cran.r-project.org/package=glcm){:target="_blank"} for grey level co-occurence matrix computations). For the latter, the [Orfeo ToolBox](https://www.orfeo-toolbox.org/){:target="_blank"} offers a faster and more comprehensive approach as given by the *Haralick texture* computation functions. To link it with R, see the [link2GI](https://cran.r-project.org/web/packages/link2GI/index.html){:target="_blank"} package and the otbtex_* functions of the [uavRst](https://github.com/gisma/uavRst){:target="_blank"} package.







