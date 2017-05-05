# DataCleaning@Coursera Assignment

This repo is created for final assignment, of ["Getting and Cleaning Data" on Coursera](https://www.coursera.org/learn/data-cleaning/peer/FIZtT/getting-and-cleaning-data-course-project). It gets human activity recognition data from [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones), and transforms them into one tidy dataset.

 
## Files included in this repo:


First Header   | Second Header
-------------  | -------------
README.md      | Readme
run_analysis.R | R script to run the analysis
CodeBook.md    | Codebook
HAR.zip		  | HAR data downloaded from UCI website
UCI HAR Dataset (folder) | Data de-compressed from HAR.zip
mergedDataset.csv| Output of R script: merged tidy data set
groupSummary.csv | Output of R script: mean of each measurements grouped by subject & activity


## run_ayalysis.R

This is the main script downloading, processing, and outputting the final tidy dataset. The script has below blocks.

1. Load library.

	```R
	# load libraries
	library(dplyr)
	```

2. Download and unzip HAR data from website.

	```R
	download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
	                "HAR.zip", method = "curl")
	unzip ("HAR.zip", exdir = "./")
	``` 
3. Read and merge train & test datasets.

	```R
	X = rbind(tbl_df(read.table("./UCI HAR Dataset/train/X_train.txt")), 
	          tbl_df(read.table("./UCI HAR Dataset/test/X_test.txt")))
	y = rbind(tbl_df(read.table("./UCI HAR Dataset/train/y_train.txt")), 
	          tbl_df(read.table("./UCI HAR Dataset/test/y_test.txt")))
	subject = rbind(tbl_df(read.table("./UCI HAR Dataset/train/subject_train.txt")), 
	                tbl_df(read.table("./UCI HAR Dataset/test/subject_test.txt")))
```

4. Select only those variables with "mean" or "std" in their names.
	
	```R
	# read features and pass them as variable names of X
	names(X) = gsub("\\(|\\)|-", "", read.table("./UCI HAR Dataset/features.txt")[,2])
	# select only the variables with "mean" or "std" in their names
	X <- X[,grepl("mean|std", names(X))]
	```
	
5. Substitute activity index with descriptive activity names.
	
	```R
	# load activity label, and rename the variables
	activityLabels = tbl_df(read.table("./UCI HAR Dataset/activity_labels.txt")) %>%
	        rename(activityIndex = V1, activityName = V2)
	# merge y and activity labels, then drop the activity index
	names(y) = "activityIndex"
	y = merge(y, activityLabels, by = "activityIndex") %>%
	        select(-activityIndex)
	```
6. Column combine subject, activity, and measures tables.
	
	```R
	# give tbl subject a descriptive name, then column combine subject, y & X
	names(subject) = "subject"
	mergedDataset = tbl_df(cbind(subject, y, X))
	```
7. Summarize the table by subject & activity using dplyr.
	
	```R
	# group previous dataset by subject & activity name
	# then summarize each variables into a second / new dataset
	groupSummary = group_by(mergedDataset, subject, activityName) %>%
        summarize_each(funs(mean))
	```
	
8. Output 2 datasets into csv files.

	```r
	# write 2 datasets into csv
	write.table(mergedDataset, file = "mergedDataset.csv",sep = ",", row.names = FALSE)
	write.table(groupSummary, file = "groupSummary.csv", sep = ",", row.names = FALSE)
	```