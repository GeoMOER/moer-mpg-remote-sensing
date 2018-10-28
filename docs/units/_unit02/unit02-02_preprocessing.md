---
title: "Image preprocessing"
---

Basic image preprocessing encompasses the (i) making sure that every dataset has the same projection, (ii) cropping of the dataset to your region of interest, (iii) making sure that NA values are defined in a comparable (or even the same) manner and (iv) tiling or merging datesets depending on both the requirements of functions intended to use during the analysis and potential computer memory limitations. In addition, there will likely be other flaws in the data which have to be taken care of before continouing with the actual analysis. 

## Aerial images of Marburg Open Forest
The aerial images provided within this course cover the area of Marburg Open Forest. The dataset consists of several tiles which are visualized in a very reduced resolution in the map below.

{% include media url="/assets/misc/aerial_images_map.html" %}
[Larger version of the map]({{ site.baseurl }}/assets/misc/aerial_images_map.html){:target="_blank"}


## Defining a first preprocessing workflow
You will notice, that the overall extent of the aerial images is larger than necessary. Hence, the image areas outside the study area are just producing computation time so let's crop them.

Hence, the preprocessing workflow is the following:
1. Checking the projection of each image tile, set and or change the projection if necessary.
1. Cropping each individual tile so only the part of the image is contained which falls into the area of interest.
1. Handle the overlapping image pairs to make sure that valid data instead of "white stripes" is kept for further analysis.
1. Merge the resulting tiles into one multi-band image.
