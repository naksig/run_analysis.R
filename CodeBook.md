---
title:  Code Book  run_analysis.R
author: Nakazawa Shigeki
date:   August 22, 2015
---
   
   
---
   
   
## 1. Introduction
This script creates tidy data sets from the data collected from accelerometers from smartphone on human activities. The script modifies the original data and creates a data set "signalActivitySubject.txt" which extracts measurements of means and standard deviations, then calculated the average of each signal measurements for each activity and each subject (person).

For details of the data collection, see below.

- Background: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
- Original Data: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

**NOTE on REQUIRED ENVIRONMENT **
To use this script,    
1) download the above data, unzip, and save UCI HAR Dataset directory to the working directory of R.   
2) load the dplyr and plyr package in R.
   
   
---
   
   
## 2. Variables and data
### 1) Variables
These variables are in the final output "signalActivitySubject.txt". 

 * No.1 subjectTest     : int   
    The numbers of 1-30 represent each subject.   
 * No.2 trainingLabel   : Factor   
    Types of activities of 6 levels: LAYING, SITTING, STANDING, WALKING, WALKING_DOWNSTAIRS, WALKING_UPSTAIRS   
   

Following variable No.3-88 are measurements from smartphone.
Their variable names consist of combination of following parameters.

- Time domain signals,                        e.g. TimeBodyAccelerometerMeanX
- Frequency domain signals,                   e.g. FreqBodyAccelerometerMeanX 
- Angular velocity,                           e.g. AngleXGravityMean
- 3-axial raw signals are represented in XYZ, e.g. TimeBodyAccelerometerMeanZ

of
- Accelerometer,                              e.g. TimeBodyAccelerometerStdZ
- Gyroscope,                                  e.g. TimeBodyGyroscopeMeanX

in
- Body acceleration signals,                  e.g. TimeBodyAccelerometerJerkMeanX
- Gravity acceleration signals,               e.g. AngleYGravityMean            
- Jerk signals,                               e.g. FreqBodyAccelerometerJerkMeanX
- Magnitude of these three-dimensional signals, e.g. FreqBodyGyroscopeMagnitudeStd


For technical details of these variables, refer to the above Background resource. The feature.info.txt in the Original Data also explains the details.



Rows represent combination of subjects (30 persons) with activities (6 types), total 180 rows.


### 2) Data
This is a list of R objects made in this script in alphabetical order.  
    
    
 No | variable | object | purpose / function
---- | ---- | ---- | ----
1 | activityLabels | data frame | save activity_labels.txt, 6 types of activities 
2 | columnNames | chr vector | save variable names of signal.tidy, for clean-up of the names         
3 | features | data frame | save features.txt, variable names of the original data           
4 | meanStdColumns | int vector | save vector numbers of variable names with mean & std           
5 | signal | data frame | save merged data of mean & std of test and train data              
6 | signal.tidy | data frame | 1st tidy data. save cleaned-up texts of signal        
7 | signalActivitySubject | data frame | 2nd tidy data (final output), save the averages by group
8 | signalTidyGroup | data frame | grouped signal by subjectTest & trainingLabel variables   
9 | subjectTest | data frame | save subject_test.txt, subjects in numbered codes for test data    
10 | subjectTrain | data frame | save subject_train.txt, subjects in numbered codes for train data  
11 | xTest | data frame | save X_test.txt, main measurement data in the original data in test data 
12 | xTest.MeanStd | data frame | subset data of xTest, extracted mean & std         
13 | xTrain | data frame | save X_test.txt, main measurement data in the original data in train data  
14 | xTrain.MeanStd | data frame | subset data of xTest, extracted mean & std     
15 | yTest | data frame | save y_test.txt, test types in coded numbers of 1-6, decoded by activitLabels
16 | yTrain | data frame | save y_train.txt, test types in coded numbers of 1-6, decoded by activiLabels


---
   
   
## 3. Transformations or work for data clean-up
### 1) Read the original data.
This script reads following 8 files in the UCI HAR Dataset and creates corresponding 8 data sets.

- Test directory  (Randomly partitioned measurement data of 30%)
     - X_test.txt (Measurement data) -> xTest (Data without column & row names)
     - y_test.txt (Types of activity) -> yTest (Numbers 1-6 represent activities)
     - subject_test.txt (Subject numbers) -> subjectTest (Numbers 1-30 represent subjects)

- Taring directory (Randomly partitioned measurement data of 70%)
     - X_train.txt (Measurement data) ->  xTrain (Data without column & row names)
     - y_Train.txt (Types of activity) -> Train (Numbers 1-6 represent activities)
     - subject_train.txt (Subject numbers) -> subjectTrain (Numbers 1-30 represent subjects)

- UCI HAR Dataset directory
     - features (Types of measurements) -> features (This becomes column/variable labels of the above xTest & xTrain.)
     - activity_labels.txt (Types of activity in character) -> activityLabels (This denotes the numbers in the above yTest/Train.)


### 2) Merge the original data and create a data set.
Measurement data sets are the main data table, to which   
- types of measurements were added as column names,   
- types of activity and subject numbers were add as variables.

Then, the data in training and test directories were merged and made another data set: signal.
The signal data set has 88 variables mentioned on the above 2. Variables and data .


### 3) Extract the measurements on the mean and standard deviation for each measurement. 
From the column labels signal data set (or originally the data of features data set), programatically extracted labels that contain Mean, mean, Std, or std.


### 4) Change the types of activity to descriptive activity names
Types of activities were originally described in numbers: 1-6, which correspond to the data in activityLabels. With the activityLabels data, types of activity were changed to descriptive names, e.g. 1 -> WALKING .


### 5) Change the variable labels as descriptive names.
Many of original variable labels were abbreviated.   
These names were programaticaly modified to be more descriptive:   
- Spelled the abbreviations (as much as possible in full).   
- Capitalized words.   
- removed non alphabetical marks: - , ( , ) , ' , . , "   
   
These modifications were made on a character vector "columnNames".  
Following is a list of modifications. The mark -> represents "changed to".    
- Acc -> Accelerometer   
- Gyro -> Gyroscope   
- Mag  -> Magnitude   
- t -> time   
- (t -> (Time   
- f -> Freq   
- BodyBody -> Body   
- angle -> Angle   
- gravity -> Gravity   
- mean -> Mean    
- std -> Std   
- jerk -> Jerk   
- () -> ""   
- - -> ""   
- , -> ""   
- ( -> ""   
- ) -> ""   
   
As the result, data in columnNames were replaced, combined with signal data set, and made a data frame "signal.tidy".  
   
   
### 6) Create a second, independent tidy data set
Based on the signal.tidy data, calculated the average of each variable for each activity and each subject and created another data frame "signalActivitySubject"" .

The data set was written as a text file "signalActivitySubject.txt".
  
  
---
**END**




