### Introduction

This codebook describes the source of the data, variables and transformations required to arrive at a tidy data.

### Data Source 

Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto. 
Smartlab - Non Linear Complex Systems Laboratory 
DITEN - UniversitÃ  degli Studi di Genova, Genoa I-16145, Italy. 
activityrecognition '@' smartlab.ws 
www.smartlab.ws 

### Data Set Information:
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. 

#### Attribute Information:

For each record in the dataset it is provided: 
* Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
* Triaxial Angular velocity from the gyroscope. 
* A 561-feature vector with time and frequency domain variables. 
* Its activity label. 
* An identifier of the subject who carried out the experiment.

### Variables

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

### Steps to arrive at the tidy data

#### Load RCurl and data.table libraries 
```
require(RCurl)
require(data.table)
setwd("...")
```

#### Use the URL provided at the course site to download the data
```
if(!file.exists("./data")){dir.create("./data")}
URL <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL, destfile = "./data/SmartphoneData.zip")
unzip("./data/SmartphoneData.zip",exdir="./data")
```

#### See the downloaded files and change the working directory into the extracted data folder
```
list.files("./data")#### Shows UCI HAR Dataset, Success ####
setwd("./UCI HAR Dataset/")
```
#### Define the outcomes i.e. the activities of subjects -----------------------------------------------------
```
activity_matrix <- read.table("./activity_labels.txt",header=FALSE,colClasses="character")
```

#### Define Feature Labels ----------------------------------------------------------
```
feature_labels <- read.table("./features.txt",header=FALSE,colClasses="character")
feature_labels <- feature_labels[,2] 
```
#### Read and label the training data --------------------------------------------------
```
train_predictors <- read.table("./train/X_train.txt",header=FALSE)
colnames(train_predictors) <- feature_labels
```
#### Read and label the training outcomes ---------------------------------------------
```
train_outcome <- read.table("./train/y_train.txt",header=FALSE)
train_outcome$V1 <- factor(train_outcome$V1,levels=activity_matrix$V1,labels=activity_matrix$V2)
colnames(train_outcome) <- "Activity"
```
#### Read and label Training subjects --------------------------------------------------
```
train_subjects <- read.table("./train/subject_train.txt",header=FALSE)
colnames(train_subjects) <- "Subject"
```

#### Create a tidy training data ---------------------------------------------
```
training_data <- cbind(train_subjects,train_outcome,train_predictors)
```
#### Read and label the test data ------------------------------------------------------
```
test_predictors <- read.table("./test/X_test.txt",header=FALSE)
colnames(test_predictors) <- feature_labels
```
#### Read and label the test outcomes ----------------------------------------
```
test_outcome <- read.table("./test/y_test.txt",header=FALSE)
test_outcome$V1 <- factor(test_outcome$V1,levels=activity_matrix$V1,labels=activity_matrix$V2)
colnames(test_outcome) <- "Activity"
```
#### Read the test subjects --------------------------------------------------
```
test_subjects <- read.table("./test/subject_test.txt",header=FALSE)
colnames(test_subjects) <- "Subject"
```
#### Create a tidy test data ---------------------------------------------
```
test_data <- cbind(test_subjects,test_outcome,test_predictors)
```
#### Merge the training and test data ----------------------------------------
```
merged_data <- rbind(training_data,test_data)
```
#### Check the top and bottom of the data ------------------------------------
```
View(head(merged_data))
View(tail(merged_data))
```

#### Calculate mean and standard deviation of each feature -------------------
```
merged_data_mean <- sapply(merged_data[,-c(1,2)],mean,na.rm=T)
merged_data_sd <- sapply(merged_data[,-c(1,2)],sd,na.rm=T)
```


#### Finally, create and write a csv file for an independent tidy dataset  ----------------------------------
```
temp <- data.table(merged_data)
tidy_data<-temp[,lapply(.SD,mean),by="Subject,Activity"]
write.table(tidy_data,"tidy.txt",sep=",",row.names=FALSE)
```
