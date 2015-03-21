#DATA Dictionary - Human Activity Recognition Using Smartphones Dataset Averages

This data is a summary of the Human Activity Recognition Using Smartphones Dataset (version 1.0) downloaded [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).
The information about the file is here: [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
Please refer to the README file of that data set to find out how the data was obtaineed.

##Input data
The input data is split in 2 sets, train and test, each in its' own folder.
Each set has 3 files in txt format, the records are separated by newlines and the fields within a record separated by space. Here we describe them using the train set:

* *subject_train.txt*: the list of subject Ids that corresponds to each measurement
* *X_train.txt*: the list of 561 variables, one for each measurement
* *y_train.txt*: the list of activity type Ids that corresponds to each measurement

Also the top folder contains the following relevant files:
* *activity_labels.txt*: contains the activity name that corresponds to each activity type Id
* *features.txt*: contains the measurement name corresponding to each column in the X_train.txt and X_test.txt files.

The files in the Inertial Signals folders are not used at all.

##Processing steps
####1. Loaded the text files into R data frames.

We use the following parameters for the read.table() function:
* stringsAsFactors = FALSE: we don't want to have factors because we don't need them and they can generate error when converting to numeric values.
* for the 2 large files, train/X_train.txt and test/X_test.txt we use also headers = FALSE and colClasses = c("numeric"), which speed up the import, especially the 2nd one, because R doesn't have to guess the type of the columns.
For the subject files we checked that the number of subjects loaded into the data
frames match the number of subjects described in the README.txt file.

####2. Concatenated the measurements, labels and subjects data frames into new data frames

Since we already have the data frames, created the new ones using the rbind() function.  
After the concatenation we peeked at the data lengths and names to check for inconsistencies, none were found.

####3. Extracted only the columns requested (those whose names contained "mean()" or "std()") into a new data frame.

The columns to extract were determined by getting the 1st column in the *features* data frame, after it was filtered to include only the relevant names.

####4. Add the descriptive activity names to the data set. This means that instead of activity type Id, use the activity name in the activity_labels data frame, corresponding to the activity_types.txt file.

For this we have a few steps:

* We will use the "merge" function to match the activity names with the
measurements data set. Since the merge operation will return a data frame
with the records in an unknown order, we add a new column called "id" to the
data frames we want to merge so that we can match the records in their original
order after the 1st merge. We use the seq_along() function to generate the Ids.
In this step we also rename the variables in the labels and subjects tables 
for easier reference using the names() function.

* Merge the labels data frame (*merged_labels*) with the measurements data frame (*merged_measurements*). The resulting
data frame has the activity type corresponding to each measurement.

* Merge the subjects data frame (*merged_subjects*) with the data frame resulted from the previous step (*merged_measurements2*). The resulting data frame now also has the subject Id corresponsing to each measurement.

* Merge the activity_labels data frame (*activity_labels*) with the data frame resulted in the previous step (*merged_measurements2*). The resulting data frame now has the descriptive activity name corresponding to each measurement.

After each step we do a test to make sure that the number of rows resulting from
the merge operation is the same as the number of rows in the original merged
measurements data frame, so there was a 1:1 match between the merged tables (as
it should be). And we also peek at the names in the resulted data frame.
Now our resulting data frame is called *merged_measurements2*.

####5. We label the data columns in the *merged_measurements2* data frame with more descriptive names, obtained from the features data frame.

We use the same tactic as we did when getting the columns, filter the *features*
data frame, but this time take the 2nd column which has the names. This filtered
set of names is saved into the list called *column_names*.
For easier refering to the variables later we take out the parentheses and minus
characters from the original names, using the gsub() function.

In the end we assign a new list of names to the names(merged_measurements2)
expression, and peek at it to see that the names are updated.

####6. Create a new tidy data set that has the data values averaged, grouped by activity type and subject.
 
The easiest way to do this is to use the functions in the dplyr package, so we
load it.

First we use the group_by() function to group the data frame by the activity.name
and subject.id columns, then we call the summarise_each() function.
summarise_each is better in this case than simply calling summarise() for each
variable because there are 79 fields to type and it's a lot of typing. Instead we can
give it the function to execute and the columns to run it on as a sequence expression
specifying only the 1st and last columns.

Because we are operating on the same data frame at each step we use the pipe
( %>% ) operator to simplify the code.

After the piped functions created, the new data it is saved into a new variable
called *merged_measurements2_averaged*. We peek at the names and dimensions of this
new data frame to see that it has 180 records, as it should have for 30 subjects
* 6 activity types.

####7. Save the final data frame into an output file called "merged_measurements_averaged.txt", using the write.table() function.

##Columns in the output file:
* *activity.name*  
	WALKING  
	WALKING_UPSTAIRS  
	WALKING_DOWNSTAIRS  
	SITTING  
	STANDING  
	LAYING  

* *subject.id* = one of the 30 subjects, each identified by a number  
	1  
	2  
	.  
	.  
	30  

The other columns represent the averaged values of the mean and standard deviation measurements of various variables measured in the original data set.
Please refer to the features_info.txt included in the original data set files.



