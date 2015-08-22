---
title:  README  run_analysis.R
author: Nakazawa Shigeki
date:   August 22, 2015
---
   

This document explains how the scripts in run_analysis.R work and how they are connected.
   
   
---


# I. Introduction
This script extracts means and standard deviations from the original data in UCI HAR Dataset, tidy the data. Final output is a tidy dataset: the average of each variable for each activity and each subject. For more details on the UCI HAR Dataset, refer to the Code Book.
   
   
---
   
   
# II. Summary of function
The script is divided into following blocks:

* 0 Check and prepare
     + 0A check if the folder exists.
     + 0B load library
* 1 Read and change the original data
     + 1A Read tables
          + 1A1 Read test sub directory
          + 1A2 Read training sub directory
          + 1A3 Read UCI HAR Dataset
     + 1B Change column labels of the read data sets
* 2 Subset and merge
     + 2A Subset std & mean columns
          + 2A1 Get column numbers of mean & std  
          + 2A2 Subset the data with the extracted column numbers
     + 2B Add data on training types & subjects
          + 2B1 to test data set
          + 2B2 to training data set
     + 2C Merge test & training data sets
* 3 Rename activity labels from numbers to descriptive texts
* 4 Rename column labels to descriptive names
* 5 Calculate average, make final data set and output as a text file.
   
   
---
   
   
# III. Step-by-step guide
## 0 Check and prepare
Show message to notify the step.  
Likewise, on each step of this script, a message is shown to notify the progress, since a few steps needs some time.
```{r}
message("0. check requirements and prepare.")
```
   
   
### 0A check if the folder exists.
Confirm the UCI HAR Dataset is in the working directory. If it doesn't exist, stop the script and show message.
```{r}
 #0A check if the folder exists.
     if(dir.exists("./UCI HAR Dataset")==FALSE) {
          stop("No UCI HAR Dataset folder in the Working Directory.\n  please save the folder there and try again.")
     }
```
### 0B load library
Load plyr & dplyr library. After the library is loaded, show message to notify the completion.  
```{r}
 #0B load library
     library(plyr)
     library(dplyr)
message(" a) checked UCI HAR Dataset folder. \n b) loaded dplyr.")
```
   
---
   
   
## 1 Read and change the original data
### 1A Read tables
The original data is divided in three parts: test sub-directory, train sub-directory, and UCI HAR Dataset directory.
   
#### 1A1 read test sub-directory (Divided in 1A1a-1A1c)
Read table from the test sub-directory, create each corresponding data set. In this case,x_test.txt is read as xTest. There is no column and row label info, which will be added in the later part.
```{r}
  #1A1a read xTest
     xTest       <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
     if (exists("xTest")){message(" a) have read x_test.txt as xTest.")}
```
Similarly, read tables from other files, too.
* x_test.txt as xTest: main measurement data
* y_test.txt as yTest: type activity in coded numbers
* subject_test.txt as subjectTest: subject numbers

#### 1A2 read train sub-directory (Divided in 1A2a-1A2c)
As did in 1A1, similar files are read in train sub-directory. 
* x_train.txt as xTrain  
* y_train.txt as yTrain  
* subject_train.txt as subjectTrain

#### 1A3 read features & activityLabels
Right under the UCI HAR dataset directory, there are two files to be read which are common data for the test & train data sets.
* features.txt as features: variable/column data of main measurement data sets
* activity_labels.txt as activityLabel: factor, character data of activity types

### 1B Change column labels of the read data sets
Apply data in features to variable labels of xTest & xTrain.
```{r}
     names(xTest)  <- features[,2]
     names(xTrain) <- features[,2]
     message(" i) changed column labels of xTest & xTrain with features.")
```
   
   
---
   
   
## 2 Subset and merge
### 2A Subset std & mean columns
#### 2A1 Get column numbers of mean & std
With the data in features, extract vector numbers which elements contain key words: Mean, mean, Std, or std, save the numbers in meanStdColumn vector.
```{r}
     meanStdColumns <- grep("(Mean|mean|Std|std)", features[,2])
```

#### 2A2 Subset the data with the extracted column numbers
With the extracted vector numbers of mean & std, subset the measurement data sets of xTest & xTrain,   
create xTest.MeanStd & xTrain.MeanStd .
```{r}
     xTest.MeanStd   <- xTest [, meanStdColumns]
     if(ncol(xTest.MeanStd==88)) {message(" a) extracted mean & std columns from xTest.")}
     xTrain.MeanStd  <- xTrain[, meanStdColumns]
     if(ncol(xTrain.MeanStd==88)) {message(" b) extracted mean & std columns from xTrain.")}
```

### 2B Add data on training types & subjects
#### 2B1 to test data set
#### 2B2 to training data set
To xTest.MeanStd & xTrain.MeanStd respectively, add variables:
* trainingLabel from yTest/Train: type activity in coded numbers
* subjectTest from subjectTest/Train : coded numbers of subject
```{r}
     xTest.MeanStd$trainingLabel <- yTest$V1
     xTest.MeanStd$subjectTest   <- subjectTest$V1
     if(
          is.vector(xTest.MeanStd$trainingLabel, mode = "integer") & 
          is.vector(xTest.MeanStd$subjectTest, mode = "integer")
     ) {message(" c) added training label and subject test to exracted xTest data.")}

```
```{r}
     xTrain.MeanStd$trainingLabel <- yTrain$V1
     xTrain.MeanStd$subjectTest   <- subjectTrain$V1
     if(
          is.vector(xTrain.MeanStd$trainingLabel, mode = "integer") & 
          is.vector(xTrain.MeanStd$subjectTest, mode = "integer")
     ) {message(" d) added training label and subject test to extracted xTrain data.")}
```
   
### 2C Merge test & training data sets
Merge xTest.MeanStd & xTrain.MeanStd and create signal data set.   
Show message with numbers of columns & rows (just to confirm the merging is correctly done).
```{r}
     signal <- merge(xTest.MeanStd, xTrain.MeanStd, all = TRUE)
     message(" e) finished merging. Created signal:",
             ncol(signal), " columns, ",
             nrow(signal), " rows.")
```
   
---
   
   
## 3 Rename activity labels from numbers to descriptive texts
Make a subset of signal: signal.tidy.   
Replace elements in activityLabel: from coded numbers of 1-6  to descriptive characters in activityLabels with sapply.
```{r}
message("3. Rename activity labels.")
 #from activity_labels.txt,
 #assign corresponding names to the tidy dataset: signal.tidy
     signal.tidy <- signal
     signal.tidy$trainingLabel <- sapply(signal$trainingLabel, function(x) {activityLabels$V2[x]} )
     message(" a) modified trainingLabel as descriptive data.")
```
   
---
   
   
## 4 Rename column labels to descriptive names
Rename variable labels in signal.tidy from abbreviated ones to spelled & capitalized ones, plus clean-ups of several non-alphabetical marks (see details in the Code Book). Mainly used gsub.   
Moved subject and training variable to the left of signal.tidy data frame.
```{r}
message("4. clean up column labels.")
     columnNames <- names(signal.tidy)  #extract column label
     columnNames <- gsub("Acc", "Accelerometer", columnNames)    #Acc -> Accelerometer
     columnNames <- gsub("Gyro", "Gyroscope",    columnNames)    #Gyro -> Gyroscope
     columnNames <- gsub("Mag", "Magnitude",     columnNames)    #Mag  -> Magnitude
     columnNames <- gsub("^t", "Time",           columnNames[1:86])     #t -> time
     columnNames <- append(columnNames, names(signal.tidy)[87:88], after = 87)
     columnNames <- gsub("\\(t", "\\(Time",      columnNames)    #(t -> (Time
     columnNames <- gsub("^f", "Freq",           columnNames)    #f -> Freq
     columnNames <- gsub("BodyBody", "Body",     columnNames)    #BodyBody -> Body
     columnNames <- gsub("angle", "Angle",       columnNames)    #angle -> Angle
     columnNames <- gsub("gravity", "Gravity",   columnNames)    #gravity -> Gravity
     columnNames <- gsub("\\(\\)", "",           columnNames)    #() -> ""
     columnNames <- gsub("mean", "Mean",         columnNames)    #mean -> Mean
     columnNames <- gsub("std", "Std",           columnNames)    #std -> Std
     columnNames <- gsub("-", "",                columnNames)    #- -> ""
     columnNames <- gsub("jerk", "Jerk",         columnNames)    #jerk -> Jerk
     columnNames <- gsub(","  ,  "" ,            columnNames)    # , -> ""
     columnNames <- gsub("\\("  ,  "" ,          columnNames)    # ( -> ""
     columnNames <- gsub("\\)"  ,  "" ,          columnNames)    # ) -> ""
     
     names(signal.tidy) <- columnNames                 #apply columnNames to signal.tidy's column
     signal.tidy <- signal.tidy[,c(88, 87, 1:86)]      #move subject and training to the left
     
     message(" a) Spelled abbreviations. \n b) Capitalized words. \n c) removed -, (, ), '.")
```
   
---
   
   
## 5 Calculate average, make final data set and output as a text file.
With dplyr & plyr libraries, create a grouped table with subjectTest & trainingLabel (each subject and each activity). With summarise_each_, create average measurements (mean & std) per group.

The final data set is signalActivitySubject, which is written as signalActivitySubject.txt file in the working directory.

Show message if the final file exists. If not (in case of any unforeseen problems), show error message.

```{r}
message("5. make another dataset: \n   average of each variable for each activity and each subject")
     signalTidyGroup <- group_by(signal.tidy, subjectTest, trainingLabel)
     signalActivitySubject <- summarise_each_(signalTidyGroup, funs(mean), names(signalTidyGroup)[3:88])
     message(" a) made the dataset: signalActivitySubject")

#output a text file.     
write.table(signalActivitySubject, file="signalActivitySubject.txt",  row.name=FALSE)

if(file.access("signalActivitySubject.txt")!=0){
     message(" error. could not make the text file.")
} else {
     message("***** made signalActivitySubject.txt in the working directory. ******")
}
```
   
   
---
   
   
# IV. Development enviroment
R version 3.2.1   
RStudio Version 0.99.46   
Windows 8.1 x64   
   
   
---
**END**
