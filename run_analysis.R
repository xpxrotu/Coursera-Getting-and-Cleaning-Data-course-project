# run_analysis

# 1. Merges the training and the test sets to create one data set.
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
features <- read.table("./UCI HAR Dataset/features.txt")

# ---- training data
train <- read.table("./UCI HAR Dataset/train/X_train.txt", stringsAsFactors = FALSE, header = FALSE, colClasses=c("numeric"))
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", stringsAsFactors = FALSE, header = FALSE)
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", stringsAsFactors = FALSE, header = FALSE)
length(levels(factor(subject_train$V1)))
# => we have 21 subjects in the train set

test <- read.table("./UCI HAR Dataset/test/X_test.txt", stringsAsFactors = FALSE, header = FALSE, colClasses=c("numeric"))
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", stringsAsFactors = FALSE, header = FALSE)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", stringsAsFactors = FALSE, header = FALSE)
length(levels(factor(subject_test$V1)))
# => we have 21 subjects in the test set

merged_measurements <- rbind(train, test)
any(nrow(test) + nrow(train) == nrow(merged_measurements))

merged_labels <- rbind(y_train, y_test)
any(nrow(y_test) + nrow(y_train) == nrow(merged_labels))
names(merged_labels)

merged_subjects <- rbind(subject_train, subject_test)
any(nrow(subject_test) + nrow(subject_train) == nrow(merged_subjects))
names(merged_subjects)

# --------------------------------------------------------------
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
relevant_columns <- features[grepl("mean()", features$V2) | grepl("std()", features$V2), 1]
merged_measurements <- merged_measurements[,relevant_columns]

# --------------------------------------------------------------
# 3. Uses descriptive activity names to name the activities in the data set

# since merge changes the order of the data we need to add IDs to all the tables we are going to merge sa long as they are in the right order
merged_subjects <- cbind(seq_along(merged_subjects$V1), merged_subjects)
names(merged_subjects) <- c("seq_id", "subject.id")
head(merged_subjects)

merged_labels <- cbind(seq_along(merged_labels$V1), merged_labels)
names(merged_labels) <- c("seq_id", "label.id")
head(merged_labels)

merged_measurements <- cbind("seq_id" = seq_along(merged_measurements$V1), merged_measurements)
names(merged_measurements)

# now do the merge
merged_measurements2 <- merge(x = merged_labels, y = merged_measurements,
                              by.x = "seq_id", by.y = "seq_id",
                              all = TRUE)
names(merged_measurements2)
any(nrow(merged_measurements) == nrow(merged_measurements2))

merged_measurements2 <- merge(x = merged_subjects, y = merged_measurements2,
                              by.x = "seq_id", by.y = "seq_id",
                              all = TRUE)
names(merged_measurements2)
any(nrow(merged_measurements) == nrow(merged_measurements2))

# add a nicer names to the activity labels data frame.
names(activity_labels) <- c("activity.id", "activity.name")
merged_measurements2 <- merge(x = activity_labels, y = merged_measurements2,
                              by.x = "activity.id", by.y = "label.id",
                              all = TRUE)
any(nrow(merged_measurements) == nrow(merged_measurements2))
names(merged_measurements2)
head(merged_measurements2, n=3)

# -----------------------------------------------------------
# 4. Appropriately labels the data set with descriptive variable names. 

names(merged_measurements2)
column_names <- features[grepl("mean()", features$V2) | grepl("std()", features$V2), 2]
column_names <- gsub("mean\\(\\)", "MEAN", column_names)
column_names <- gsub("meanFreq\\(\\)", "MEANFREQ", column_names)
column_names <- gsub("std\\(\\)", "STD", column_names)
column_names <- gsub("-", "_", column_names)
#column_names
names(merged_measurements2) <- c("activity.id", "activity.name", "seq_id"
                                 , "subject.id", column_names)
names(merged_measurements2)

# -------------------------------------------------------------------------
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(dplyr)
merged_measurements2_averaged <-
    merged_measurements2 %>%
    group_by(activity.name, subject.id) %>%
    summarise_each(funs(mean), tBodyAcc_MEAN_X:fBodyBodyGyroJerkMag_MEANFREQ)

# just check that the dimension of the data has 180 rows (30 subjects * 6 activity types)
dim(merged_measurements2_averaged)
names(merged_measurements2_averaged)
head(merged_measurements2_averaged)

# write the output file
write.table(merged_measurements2_averaged, file="merged_measurements_averaged.txt", row.name = FALSE)







