---
title: "Spotlight: LiDAR"
---



LiDAR observations are point clouds representing the returns of laser pulses reflected from objects, e.g. a tree canopy. Processing LiDAR (or optical point cloud) data generally  requires more computational resources than 2D optical observations. Therefore, tile based processing is a key element at least for preprocessing.

<!--more-->

For this example, the lidR package will be used. Extensive documentation and workflow examples can be found in the Wiki of the respective [GitHub repository](https://github.com/Jean-Romain/lidR). Other software options include e.g. [GRASS GIS](https://grass.osgeo.org/screenshots/lidar/) or [ArcGIS](https://desktop.arcgis.com/en/arcmap/10.3/manage-data/las-dataset/a-quick-tour-of-lidar-in-arcgis.htm).

For the following, make sure these libraries are part of your setup.

```r
libs = c("lidR", "link2GI", "mapview", "raster", "rgdal", "rlas", "sp")
```

## Preparing LAS datasets for further processing
LiDAR data comes in the LAS format (for a format definition see [asprs documentation file](https://www.asprs.org/a/society/committees/standards/LAS_1_4_r13.pdf)). One LAS dataset typically covers an area of 1 km by 1 km. Since the point clouds in the LAS datasets are large, a spatial index file (LAX) considerably reduces search and select operations in the data.


```r
# Get all LAS files in a folder
las_files = list.files(envrmt$path_lidar_org, pattern = glob2rx("*.las"),
                       full.names = TRUE)

# Write LAX file for each LAS file
for(f in las_files){
  writelax(f)
}
```
If one wants to read a single LAS file (now), one could use the readLAS function. Plotting the dataset results in a 3D interactive map which opens from within R.

```r
lidar_file = readLAS(file.path(envrmt$path_lidar_org, "U4765632.las"))
plot(lidar_file, bg = "white", color = "Z")
```

{% include figure image_path="/assets/videos/lidar_point_cloud.gif" alt="LiDAR 3D animation." %}




## Coping with computer memory resources
Tile based processing can generally be handled with loops but has some pitfalls. E.g. if you compute some focal operations, you have to make sure that if the filter is close to the boundary of the tile that data from the neighboring tile is loaded in addition. 

The lidR package comes with a feature called catalog and a set of catalog functions which make tile-based life easier. A catlog meta opject also holds information on e.g. the cartographic reference system of the data or the cores used for parallel processing.


```r
# Create catalog and set projection and parallel processing information
lcat = catalog(envrmt$path_lidar_org)
lcat@crs = CRS("+init=epsg:25832") # ETRS89 / UTM zone 32N
cores(lcat) <- 3L
tiling_size(lcat) = 500
```





To view the catalog tiles, just plot it.

```r
plot(lcat)
```
{% include media url="/assets/misc/lcat_map.html" %}


In addition to tile based processing, clipping the data to the area of interest is helpfull, too. A drawback of this approach is that the cliped data set is saved as a single LAS file which in this example will be written to the tmp directory. If you prefer to continoue computing on the original tiles, have a look at the catalog_apply function.

```r
# Clip catalog to the area of interest
aoi = readOGR(file.path(envrmt$path_data_mof, "aoi.shp"))
aio_bb = bbox(aoi)
lasclipRectangle(lcat, xleft = aio_bb[1], ybottom = aio_bb[2], 
                 xright = aio_bb[3], ytop = aio_bb[4],
                 ofile=file.path(envrmt$path_tmp, "las_mof_aio.las"))
```


To split the create LAS data, create a new catalog pointing to the file. Afterwards, one can retile the data to e.g. 500 m tiles which results in another new catalog for which one can define settings defining parallel computation etc. again.

```r
# Create a LAX file for the cliped data, create a new catalog and set catalog 
# options as above but extened by the tiling size attribute that is set to 
# 500 m.
writelax(file.path(envrmt$path_tmp, "las_mof_aio.las"))
lcat = catalog(file.path(envrmt$path_tmp, "las_mof_aio.las"))
lcat@crs = CRS("+init=epsg:25832")
cores(lcat) = 3L
tiling_size(lcat) = 500
buffer(lcat) = 0

# Tile the catalog LAS file(s) to 500 m tiles and point the dataset to a new
# catalog. The tiled las files are stored in the path_clip directory.
lcat_tiled = catalog_retile(lcat, envrmt$path_clip, "las_mof_aio_")
lcat_tiled@crs = CRS("+init=epsg:25832")
cores(lcat_tiled) = 3L
tiling_size(lcat_tiled) = 500
buffer(lcat_tiled) = 0
```




The above operations will result in a dataset with the following tile geometry (which is overlayed the original catalog tiles without showing it in this code snippet).

```r
plot(lcat_tiled)
```
{% include media url="/assets/misc/lidar_catalog_map.html" %}

If you also want to have more control over plotting, you could use the mapview package (which is actually used in the background of the catalog plotting function of the lidR package). Therefore convert the catalog class variable to a spatial data frame.


```r
lcat_spatial = as.spatial(lcat)
mapview(lcat_spatial)
```


Note that LiDAR preprocessing might also require the classification of returns into ground/non-ground, the removal of returns depending on the flight line geometry etc.

## Examplary product
Once the data is preprocessed, one can compute a variety of point cloud or raster based products. One dataset which is basically allways of interest is the surface model.


```r
# Compute surface model with 0.5 m resolution and convert it to a raster object.
lchm = grid_canopy(lcat_tiled, 0.5, subcircle = 0.2)
lchmr = as.raster(lchm)
crs(lchmr) = lcat@crs
```







```r
mapshot(mapview(lchmr), url = "lidar_dhm_map.html")
```
{% include media url="/assets/misc/lidar_dhm_map.html" %}


