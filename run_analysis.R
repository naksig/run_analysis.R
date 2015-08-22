#                    run_analysis.R
#                                       Aug.20 2015
#                                  Nakazawa Shigeki
#
#
#0 check and prepare
#---------------------------------
message("0. check requirements and prepare.")
#---------------------------------
 #0A check if the folder exists.
#------------------------
     if(dir.exists("./UCI HAR Dataset")==FALSE) {
          stop("No UCI HAR Dataset folder in the Working Directory.\n  please save the folder there and try again.")
     }
#------------------------
 #0B load library
#------------------------
     library(plyr)
     library(dplyr)
message(" a) checked UCI HAR Dataset folder. \n b) loaded dplyr.")


#---------------------------------
#1 Read & change the orginal data
#---------------------------------
#1A read tables
#------------------------
message("1. read files to R. This may take some time.")
 #1A1 read test
  #1A1a read xTest
     xTest       <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
     if (exists("xTest")){message(" a) have read x_test.txt as xTest.")}
  #1A1b read yTest
     yTest       <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE)
     if (exists("yTest")){message(" b) have read y_test.txt as yTest.")}
  #1A1c read subjectTest
     subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
     if (exists("subjectTest")){message(" c) have read subject_test.txt as subjectTest. \n  Please wait.")}
 #1A2 read train
  #1A1a read xTrain
     xTrain       <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE)
     if (exists("xTrain")){message(" d) have read x_train.txt as xTrain.")}
  #1A1b read yTrain
     yTrain       <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE)
     if (exists("yTrain")){message(" e) have read y_train.txt as yTrain.")}
  #1A1c read subjectTrain
     subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
     if (exists("subjectTrain")){message(" f) have read subject_train.txt as subjectTrain.")}
 #1A3 read features & activityLabels
     features       <- read.table("./UCI HAR Dataset/features.txt", header = FALSE)
     if (exists("features")){message(" g) have read features.txt as features.")}
     activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE)
     if (exists("activityLabels")){message(" h) have read activity_labels.txt as activityLabel.")}
#-----------------------------
#1B change column labels of xTest & xTrain with features
#-----------------------------
     names(xTest)  <- features[,2]
     names(xTrain) <- features[,2]
     message(" i) changed column labels of xTest & xTrain with features.")


#----------------------------------
#2 Subset & merge
#----------------------------------
#2A subset std & mean columns
#-----------------------------
message("2. extract necceary data and merge xTest & xTrain.")
#----------------------------- 
 #2A1 from features, get column numbers of mean & std: meanStdColumns
  #   (This vector is used for train set, too.)
#------------------------
     meanStdColumns <- grep("(Mean|mean|Std|std)", features[,2])
#------------------------   
 #2A2 subset xTest & xTrain with meanStdColumns
#------------------------
     xTest.MeanStd   <- xTest [, meanStdColumns]
     if(ncol(xTest.MeanStd==88)) {message(" a) extracted mean & std columns from xTest.")}
     xTrain.MeanStd  <- xTrain[, meanStdColumns]
     if(ncol(xTrain.MeanStd==88)) {message(" b) extracted mean & std columns from xTrain.")}
 
#----------------------------
#2B merge yTest, yTrain, & subjectTest
#   ;add trainingLabel & subjectTest to xTest & xTrain
#----------------------------
 #2B1 to xTest
#-------------------------
     xTest.MeanStd$trainingLabel <- yTest$V1
     xTest.MeanStd$subjectTest   <- subjectTest$V1
     if(
          is.vector(xTest.MeanStd$trainingLabel, mode = "integer") & 
          is.vector(xTest.MeanStd$subjectTest, mode = "integer")
     ) {message(" c) added training label and subject test to exracted xTest data.")}
#------------------------
 #2B2 to xTrain
#------------------------
     xTrain.MeanStd$trainingLabel <- yTrain$V1
     xTrain.MeanStd$subjectTest   <- subjectTrain$V1
     if(
          is.vector(xTrain.MeanStd$trainingLabel, mode = "integer") & 
          is.vector(xTrain.MeanStd$subjectTest, mode = "integer")
     ) {message(" d) added training label and subject test to extracted xTrain data.")}
#----------------------------
#2C merge xTain & xTest: signal
#----------------------------
     signal <- merge(xTest.MeanStd, xTrain.MeanStd, all = TRUE)
     message(" e) finished merging. Created signal:",
             ncol(signal), " columns, ",
             nrow(signal), " rows.")

     
#---------------------------------
#3 Rename activity labels
#---------------------------------
message("3. Rename activity labels.")
 #from activity_labels.txt,
 #assign corresponding names to the tidy dataset: signal.tidy
     signal.tidy <- signal
     signal.tidy$trainingLabel <- sapply(signal$trainingLabel, function(x) {activityLabels$V2[x]} )
     message(" a) modified trainingLabel as descriptive data.")
     

#---------------------------------
#4 Rename column label of signal.tidy
#---------------------------------
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


#---------------------------------
#5 Make another dataset;
#Average of each variable for each activity and each subject
#-------------------------------
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

#-------------END----------------
     