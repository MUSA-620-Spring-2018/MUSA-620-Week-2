# VISUALIZING PHILADELPHIA CRIME ------------------------------------------

# Simon Kassel
#   23 Mar 2017

# Animated gif visualizing crime in Philadelphia by time of day

# SETUP -------------------------------------------------------------------

# packages
library(ggplot2)
library(dplyr)
library(animation)
library(tigris)
library(broom)
library(sp)
library(lubridate)
library(tidyr)
library(broom)
library(viridis)
library(animation)
library(grid)
library(gridExtra)
library(scales)

# global options
options(stringsAsFactors = FALSE)
options(scipen = "999")

# data
crime <- read.csv("https://data.phila.gov/api/views/sspu-uyfa/rows.csv?accessType=DOWNLOAD")

# get tracts
tracts <- tracts(state = 'PA', county = 101)

# parse and filter by date/time
crime$dateTime <- mdy_hms(crime$Dispatch.Date.Time)
crime$year <- year(crime$dateTime)
cr <- filter(crime, year <= 2016 & year > 2006)

# extract coordinates
cr$coords <- substr(cr$Shape, 8, nchar(cr$Shape) - 1)
cr <- filter(cr, coords != "")
cr <- cr %>% separate(coords, c("Long", "Lat"), " ")

# spatial points object for crime
cr_points <- SpatialPointsDataFrame(cbind(as.numeric(cr$Long), as.numeric(cr$Lat)), 
                                    data = cr, 
                                    proj4string = tracts@proj4string)

# reproject to State Plane PA South
cr_pas <- spTransform(cr_points, CRS("+init=epsg:6565"))
tr_pas <- spTransform(tracts, CRS("+init=epsg:6565"))

# dataset
# spatially join points to tracts
cr_tr <- cbind(cr_pas@data, over(cr_pas, tr_pas))
# summarize crimes by census tract
t <- group_by(cr_tr, GEOID, Hour) %>% 
  summarise(n = round((n() / 10), digits = 0)) %>% 
  data.frame()

# decile field to map with
t$decile <- ntile(t$n, 10)

# tidy the sp object for ggplot
tr_tidy <- tidy(tr_pas, region = "GEOID")
tr_tidy$GEOID = tr_tidy$id

# join data back to tidied dataset
dat <- full_join(tr_tidy, t)

# define legend labels
labels <- unname(quantile(t$n, seq(.1, 1, .1))) %>% round(digits = 0)
newLabels <- c()
for (i in c(1:length(labels))) {
  if (i == 1) {
    newLabels[i] <- paste0("< ", labels[1])
  } else if (i == length(labels)) {
    newLabels[i] <- paste0("> ", labels[i - 1])
  } else {
    newLabels[i] <- paste0(labels[i - 1], " - ", labels[i])
  }
}
# decided to go with fewer labels, remove some 
for (i in c(2,3,5,6,8,9)) {
  newLabels[i] <- ""
}

# PLOT GIF ----------------------------------------------------------------

saveGIF({
  # loop through each hour
  for (i in 0:23) {
    # just the data from that hour
    hourData <- filter(dat, Hour == i)
    
    # define the 'time' variable as a string to label my plot
    if (i == 0) {
      time = "12:00 AM"
    } else if (i == 12) {
      time = "12:00 PM"
    } else if (i > 12) {
      time = paste0((i-12), ":00 PM")
    } else {
      time = paste0(i, ":00 AM")
    }
    print(time)
    
    # determine the where this hour ranks in terms of crime volume and 
    # fincd corresponding color to use in order to color label box/time series point
    avgColor <- inferno(10)[mean(filter(t, Hour == i)$decile) %>% round(digits = 0)]
    
    # plot the map
    hourPlot <- ggplot(hourData, aes(x = long, y = lat, group = group, fill = decile)) + 
      # the actual map
      geom_polygon(colour = "white", size = 0.1) + 
      coord_equal() + 
      theme_void() +
      
      # annotation indicating the time
      annotate("rect", 
               xmin = min(na.omit(dat$long)),
               xmax = min(na.omit(dat$long) + 37500),
               ymax = max(na.omit(dat$lat)),
               ymin = max(na.omit(dat$lat) - 10000),
               fill = avgColor,
               alpha = 0.65) +
      annotate("rect", 
               xmin = min(na.omit(dat$long)),
               xmax = min(na.omit(dat$long) + 37500),
               ymax = max(na.omit(dat$lat)),
               ymin = max(na.omit(dat$lat) - 10000),
               color = avgColor,
               size = 1, 
               fill = NA,
               alpha = 1) +
      annotate("text", x = min(na.omit(dat$long)),
               y = max(na.omit(dat$lat)),
               label = time,
               hjust = ifelse(nchar(time) == 8, -.03, -.122),
               vjust = 1.35,
               size = 10,
               color = "white") +
      labs(title = "Which times of day do most crimes occur?",
           subtitle = "Philadelphia's average annual crimes (2007-2016), by Census Tract") +
      theme(
        text = element_text(family = "Courier"),
        legend.justification=c(0,.5),
        plot.subtitle = element_text(face="italic", hjust = 0),
        plot.title = element_text(face="italic", size = 18, hjust = 0),
        plot.margin = unit(c(.25, .25, .25, .25), "in"),
        legend.key.height = unit(.65, "in"),
        legend.title = element_text(face = "italic", vjust = 2)
      ) +
      scale_fill_viridis("Crimes",
                         option = "inferno",
                         breaks = seq(1,10,1),
                         limits = c(1, 10),
                         labels = newLabels)
    
    # build a time series of the annual citywide average for hour i
    # summarise the whole dataset by hour
    ts_data <- group_by(dat, Hour) %>%
      summarise(n = sum(n)) %>%
      data.frame()
    
    # plot this variable in thousand (divide by 1000) and we're looking
    # at the 10-year average (divide by 10)
    ts_data$n <- ts_data$n / 10000
    
    # all hours up to and incliuding hour i
    ts <- filter(ts_data, Hour <= i)
    
    # plot time series
    ts_plot <- ggplot(ts, aes(x = Hour, y = n)) + geom_line() + theme_minimal() +  
      geom_point(data = filter(ts, Hour == i), color = avgColor, size = 4) +
      labs(title = "Average annual citywide crime count by hour (in 1,000s)",
           caption="Source: Philadelphia Police Department\n@SimonKassel") +
      theme(
        plot.caption = element_text(hjust = 0, vjust = 0),
        text = element_text(family = "Courier"),
        plot.title = element_text(face="italic", hjust = 0, size = 10),
        axis.title.y = element_blank()
      ) +
      scale_x_continuous(name = "", limits = c(0, 24), breaks = c(0, 6, 12, 18, 24), 
                         labels = c("Midnight", "6:00 AM", "Noon", "6:00 PM", "Midnight")) +
      scale_y_continuous(limits = c(min(ts_data$n - 5), max(ts_data$n + 5)),  labels = comma)
    
    
    # arrange plots on the page
    # a helper function to define a region on the layout
    define_region <- function(row, col){
      viewport(layout.pos.row = row, layout.pos.col = col)
    } 
    #create a blank page
    grid.newpage()
    # Create a grid layout: 44 columns by 34 rows
    pushViewport(viewport(layout = grid.layout(44, 34)))
    # plot both plots on new page
    print(hourPlot, vp = define_region(1:34, 1:33))
    print(ts_plot, vp = define_region(35:44, 2:32))
  }
  
}, movie.name = 'phila_crime_sk.gif', interval = 0.5, ani.width = 500, ani.height = 600)




