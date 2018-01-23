
# ** Data frames **

# built-in data frames: trees,USArrests,mtcars
head(trees)

# view the full table
View(trees)

# access columns with $
trees$Height

# select rows 5 thru 10
trees[5:10,]

# create a new row (a 1-row data frame)
newRow <- data.frame(list(Girth=999,Height=888,Volume=777))

# add the new row to the original data frame
mytrees <- rbind(trees,newRow)
mytrees

# delete the added row
mytrees <- mytrees[-32,]


