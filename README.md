# Week 2: Data frames, Tidyverse, map projections

![Philadelphia crime map](https://github.com/MUSA-620-Spring-2018/MUSA-620-Week-2/blob/master/phila_crime_sk.gif "Philadelphia crime map")
Animated map of Philadelphia crime (credit: [Simon Kassel](https://twitter.com/SimonKassel))


## Links

[Compare map projections](http://metrocosm.com/compare-map-projections.html)

[The True Size](https://thetruesize.com/)

[Tidyverse](https://www.tidyverse.org/)
- [dplyr](http://dplyr.tidyverse.org/)
- [tidyr](http://tidyr.tidyverse.org/)


## Assignment

Create an animated choropleth map of Philadelphia (Census tracts level), using a Census variable of your choice.

This assignment is **required**. Please turn it in by email to myself (galkamaxd at gmail) and Evan (ecernea at sas dot upenn dot edu).

**Due:** 30-Jan at the start of class

### Deliverable:

The final deliverable should include:
- the map itself (animated GIF)
- any code and data used in the construction of the map
- a written explanation of: the steps you took to create it, reasons for your design choices, and anything else you would like to add about what the map shows / what patterns you see.

### Task:

Using the methods we've learned in class, create an animated choropleth map of Philadelphia using a Census variable of your choice.
- The map should be a Census tract-level map that uses Census tract-level data.
- You may choose any variable you wish, though the data must go back at least 5 years (i.e. the animation must include at least 5 frames).
- The richest source of data can be found in the [Census ACS Survey](https://data2.nhgis.org/main), though data from other sources is fair game.
- Example topics: property values, median income, most common occupation, etc.

The methods for creating the map should follow roughly this path:
- Make and necessary preparations to your tabular Census data: clean up columns, modify/add columns, make sure it includes a "join" column.  
- Join the tabular data to your Philadelpia map.
- Use ggplot2 to style the map, one year of data at a time.
- Export the plots as images and combine into a GIF.

This assignment is not intended as a purely technical exercise. You should also give careful consideration to design choices. The goal is for the map to tell as clear a "story" as possible.
- Are you using an appropriate color scheme? Number of colors? Well chosen break points?
- Does the animation run at a good pace?
- Does it include explanatory features (title, legend, etc) that make clear what you're looking at?
- All other aspects of the map's design


### Data sources:

- [Philadelphia Census tracts shapefile/geojson](https://www.opendataphilly.org/dataset/census-tracts)
- [Census ACS data portal](https://data2.nhgis.org/main)

### Grading

The map will be graded on:
- Completion of the project as described
- Clarity of communication (does the map tell a clear story? can you defend your design choices?)
- Writeup (was it well thought out?)

Your code itself will not be factored into the grade.

**Extra credit:**

Have an idea for a map that builds upon the project description (see the example at the top)? If so, please let me know by email what you have in mind for the chance to receive extra credit.
