---
title: "Discussion: Images and Area of Interest"
---

Remote sensing data is generally provided in some form of image or data tiles. Each data tile covers a certain area. Before one could start with some analysis, the images provided by the data provider have to be preprocessed for homogenization and areal extent considerations.


## Aerial images of Marburg Open Forest
The aerial images used within this course cover the area of Marburg Open Forest. They are thankfully provided by the [Hessische Verwaltung für Bodenmanagement und Geoinformation (HVBG)](http://www.hvbg.hessen.de/irj/HVBG_Internet){:target="_blank"}. The dataset consists of several tiles which are visualized in the map below in a reduced spatial resolution.

{% include media url="/assets/misc/aerial_images_map.html" %}
[Full screen version of the map]({{ site.baseurl }}/assets/misc/aerial_images_map.html){:target="_blank"}


## Defining a first task list for image preprocessing
You will notice, that the overall extent of the aerial images is larger than necessary. Hence, the image areas outside the study area are just producing computation time so it is a good idea to crop them. What else might be relevant during preprocessing? Discuss this issue in your team and make a list of potential tasks using the just created project board environment of your GitHub repository.

Once you are finished, just have a second look on the task list and delineate those tasks which are always relevant and which are just for the images at hand.