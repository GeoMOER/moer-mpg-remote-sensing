---
title: "Unmarked Assignment: Image preprocessing"
---

This worksheet focuses on the preprocessing of the aerial images to compile a comprehensive multi-band GeoTiff which covers the area of interest.

After completing this worksheet, you should have a set of R scripts which are suitable to compute the preprocessing.

## Things you need for this worksheet
  * [R](https://cran.r-project.org/){:target="_blank"} — the interpreter can be installed on any operation system.
  * [RStudio](https://www.rstudio.com/){:target="_blank"} — we recommend to use R Studio for (interactive) programming with R.
  * [Git](https://git-scm.com/downloads){:target="_blank"} environment for your operating system. For Windows users with little experience on the command line we recommend [GitHub Desktop](https://desktop.github.com/){:target="_blank"}.
  * Remote sensing data provided by the course instructors.

## Develop an R workflow for your image preprocessing
You have already created a task list in the preceding discussion prompt. As a major result, the preprocessing should covers
* the definition of a common projection for the datasets,
* the croping of images to the area of interest,
* the removal of "white stripes",
* the combination of all tiles into one multi-band image.

Please work off your task list using R and save your final preprocessed aerial image dataset as one GeoTiff and one RDS file.

Please also create an R markdown file with html output which describes the preprocessing of the images in five sentences max. Include a visualization of the final preprocessed dataset in the markdown file.

Include your R, Rmd and html files in your team repository and update it in the GitHub classroom. Remember to separate documentation from source code as [discussed previously]({{ site.baseurl }}{% link _unit01/unit01-05_environment_setup.md %}).


Use the rectangular extent of the MOF "core area" i.e. the big region between L 3288 and L3092 and the smaller path south of it as area of interest.
{: .notice--info}