library(dplyr)
library(tidyr)


# RESHAPE NYC TAXI HOURLY PICKUP DATA

rawdata <- read.csv("d:/taxiPickupsByHour.csv")


# head(rawdata)
#
# lat     lon     hour   num_pickups
# 40.748 -73.979   18       14527
# 40.769 -73.983   18       16856
# 40.743 -73.990   16        2267
# 40.764 -73.998   19        2467
# 40.747 -73.994   15       28033
# 40.728 -74.005    7        3221



# REMOVE PICKUPS THAT HAPPENED OUTSIDE NYC (NYC'S BOUNDING BOX)
reduced <- filter(rawdata, lon > -74.26, lon < -73.69, lat > 40.47, lat < 40.92)

# SORT BY num_pickups (JUST SO WE CAN SEE THE HIGHEST VALUES -- NOT NECESSARY FOR ANYTHING BELOW)  
sorted <- arrange(reduced, desc(num_pickups))
head(sorted)

# ADD A NEW COLUMN FOR THE HOUR VALUES
withHourLabel <- mutate(sorted, hour_label = paste("hour_",hour,sep = ""))

# WE NO LONGER NEED THE "hour" COLUMN, SO REMOVE IT
hourValueRemoved <- select(withHourLabel,lat,lon,num_pickups,hour_label)

# CONVERT THE hour_label VALUES INTO COLUMNS
wideFormat <- spread(hourValueRemoved, key=hour_label, value=num_pickups)

# REPLACE NA VALUES WITH 0's 
NAsTo0s <- replace(wideFormat, is.na(wideFormat), 0)

# GROUP ROWS BY LAT, LON
grouped <- group_by(NAsTo0s, lat, lon)

# TRIM THE DATASET DOWN BY REMOVING ROWS WITH 0 PICKUPS IN HOUR 7 (ARBITRARY)
trimmed <- filter(grouped, hour_7 > 0)

# ONE MORE SORT (NOT NECESSARY)
finalSort <- arrange(trimmed, desc(hour_7))
head(finalSort)



# NOW WE CAN USE THIS FILE FOR OUR HOURLY DISTRIBUTIONS OF TAXI PICKUPS
write.csv(finalSort, file = "d:/hourlyPickupsReshaped.csv")



# IF WE WANTED TO PUT THE TABLE BACK IN TALL FORMAT
tallFormat = gather(finalSort, key=hour, value=pickups, hour_0:hour_9)



