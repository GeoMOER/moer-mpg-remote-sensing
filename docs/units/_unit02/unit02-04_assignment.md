---
title: "Unmarked Assignment: Image preprocessing"
toc: true
toc_label: In this worksheet
---

This worksheet focuses on the preprocessing of the aerial images to compile a comprehensive multi-band GeoTiff which covers the area of interest.

After completing this worksheet, you should have a set of R scripts which are suitable to compute the preprocessing.

## Things you need for this worksheet
  * [R](https://cran.r-project.org/){:target="_blank"} — the interpreter can be installed on any operation system.
  * [RStudio](https://www.rstudio.com/){:target="_blank"} — we recommend to use R Studio for (interactive) programming with R.
  * [Git](https://git-scm.com/downloads){:target="_blank"} environment for your operating system. For Windows users with little experience on the command line we recommend [GitHub Desktop](https://desktop.github.com/){:target="_blank"}.
  * Remote sensing data provided by the course instructors.

## Every beginning is hard
Since this might likely be the first time you get in contact with semi-automatic preprocessing of remote sensing data in R and in order to prepare you for the upcoming project assignment, the worksheet will guide you through this task step-by-step. It will summarize the required workflow, provide you with some R script templates and give you some more tips and hints.

## Suggested workflow
Based on the discussion of the orignal aerial images, one can define the following preprocessing workflow:
1. Checking the projection of each image tile, set and or change the projection if necessary.
1. Cropping each individual tile so only the part of the image is contained which falls into the area of interest.
1. Handle the overlapping image pairs to make sure that valid data instead of "white stripes" is kept for further analysis.
1. Merge the resulting tiles into one multi-band image.



Please write an R script which crops the aerial images to the extent of the LiDAR data set. Please make sure that the new raster files do not overwrite the original ones by e.g. saving the new files into a folder called "aerial_croped". Mark the original and no longer necessary files with the suffix "deprc".

Please copy the code of the above R script to an Rmd file with html output, add a screenshot of the cropped images as visualized in a GIS software of your choice and include it in your GitHub classroom repository.

Please identify the reason for the white boarders and sketch a potential solution which will remove the boarders but preserves the general geometry of the aerial images tiles of 2 by 2 km.

Write an R script which solves the problem according to your sketch. Please make sure that the new raster files do not overwrite the original ones by e.g. saving the new files into a folder called "aerial_merged". Mark the original and no longer necessary files with the suffix "deprc".
















Please create the working environment for this course following the mandatory settings provided by the [info on assignments]({{ site.baseurl }}/unit01/unit01-04_notes_on_assignments#mandatory-working-environment).





Download the aerial images required for this course using the link provided by the course instructors. 

Please write an R markdown script with html output which describes how to read and (very basically) visualize the provided aerial images in R.

Save your Rmd file in your course repository, knitr it, update (i.e. commit) your local repository and publish (i.e. push) it to the GitHub classroom. Make sure that the created html file is also part of your GitHub repository.

The R package [*raster*](https://cran.r-project.org/web/packages/raster/index.html){:target="_blank"} is a good starting point for raster data I/O.
{: .notice--info}

