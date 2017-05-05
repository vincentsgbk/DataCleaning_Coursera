# load libraries
library(dplyr)

# download the zipped file from internet, and un-compress it
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                "HAR.zip", method = "curl")
unzip ("HAR.zip", exdir = "./")

# read and merge train & test datasets
X = rbind(tbl_df(read.table("./UCI HAR Dataset/train/X_train.txt")), 
          tbl_df(read.table("./UCI HAR Dataset/test/X_test.txt")))
y = rbind(tbl_df(read.table("./UCI HAR Dataset/train/y_train.txt")), 
          tbl_df(read.table("./UCI HAR Dataset/test/y_test.txt")))
subject = rbind(tbl_df(read.table("./UCI HAR Dataset/train/subject_train.txt")), 
                tbl_df(read.table("./UCI HAR Dataset/test/subject_test.txt")))

# read features and pass them as variable names of X
names(X) = gsub("\\(|\\)|-", "", read.table("./UCI HAR Dataset/features.txt")[,2])
# select only the variables with "mean" or "std" in their names
X <- X[,grepl("mean|std", names(X))]

# load activity label, and rename the variables
activityLabels = tbl_df(read.table("./UCI HAR Dataset/activity_labels.txt")) %>%
        rename(activityIndex = V1, activityName = V2)
# merge y and activity labels, then drop the activity index
names(y) = "activityIndex"
y = merge(y, activityLabels, by = "activityIndex") %>%
        select(-activityIndex)

# give tbl subject a descriptive name, then column combine subject, y & X
names(subject) = "subject"
mergedDataset = tbl_df(cbind(subject, y, X))

# group previous dataset by subject & activity name
# then summarize each variables into a second / new dataset
groupSummary = group_by(mergedDataset, subject, activityName) %>%
        summarize_each(funs(mean))

# write 2 datasets into csv
write.table(mergedDataset, file = "mergedDataset.csv",sep = ",", row.names = FALSE)
write.table(groupSummary, file = "groupSummary.csv", sep = ",", row.names = FALSE)

