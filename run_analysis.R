require(RCurl)
require(data.table)
setwd("F:/TP/coursera/Getting_and_Cleaning_data")

# Check if the directory already exists, else create one ------------------

if(!file.exists("./data")){dir.create("./data")}
URL <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL, destfile = "./data/SmartphoneData.zip")
unzip("./data/SmartphoneData.zip",exdir="./data")

#### unzipped  ####
list.files("./data")#### Shows UCI HAR Dataset, Success ####
setwd("F:/TP/coursera/Getting_and_Cleaning_data/data/UCI HAR Dataset/")

# List the unzipped files for exploration-------------------------------------------------

list.files(recursive=T)

# Uncomment for seeing dimensions of files --------------------------------
# for(i in 1:length(files)){
#   try(
#     print(paste(as.numeric(i),dim(read.table(files[i])))),silent=FALSE
#     )
#   }
# End of exploration ------------------------------------------------------


# Define the outcomes -----------------------------------------------------
activity_matrix <- read.table("./activity_labels.txt",header=FALSE,colClasses="character")


# Define Feature Labels ----------------------------------------------------------
feature_labels <- read.table("./features.txt",header=FALSE,colClasses="character")
feature_labels <- feature_labels[,2] 

# Read and label the training data --------------------------------------------------
train_predictors <- read.table("./train/X_train.txt",header=FALSE)
colnames(train_predictors) <- feature_labels

# Read and label the training outcomes ---------------------------------------------
train_outcome <- read.table("./train/y_train.txt",header=FALSE)
train_outcome$V1 <- factor(train_outcome$V1,levels=activity_matrix$V1,labels=activity_matrix$V2)
colnames(train_outcome) <- "Activity"

# Read and label Training subjects --------------------------------------------------
train_subjects <- read.table("./train/subject_train.txt",header=FALSE)
colnames(train_subjects) <- "Subject"


# Create a tidy training data ---------------------------------------------
training_data <- cbind(train_subjects,train_outcome,train_predictors)

# Read and label the test data ------------------------------------------------------
test_predictors <- read.table("./test/X_test.txt",header=FALSE)
colnames(test_predictors) <- feature_labels

# Read and label the test outcomes ----------------------------------------
test_outcome <- read.table("./test/y_test.txt",header=FALSE)
test_outcome$V1 <- factor(test_outcome$V1,levels=activity_matrix$V1,labels=activity_matrix$V2)
colnames(test_outcome) <- "Activity"

# Read the test subjects --------------------------------------------------
test_subjects <- read.table("./test/subject_test.txt",header=FALSE)
colnames(test_subjects) <- "Subject"

# Create a tidy test data ---------------------------------------------
test_data <- cbind(test_subjects,test_outcome,test_predictors)

# Merge the training and test data ----------------------------------------
merged_data <- rbind(training_data,test_data)

# Check the top and bottom of the data ------------------------------------
View(head(merged_data))
View(tail(merged_data))


# Calculate mean and standard deviation of each feature -------------------

merged_data_mean <- sapply(merged_data[,-c(1,2)],mean,na.rm=T)
merged_data_sd <- sapply(merged_data[,-c(1,2)],sd,na.rm=T)



# Create and write a csv file for an independent tidy dataset  ----------------------------------
temp <- data.table(merged_data)
tidy_data<-temp[,lapply(.SD,mean),by="Subject,Activity"]
write.table(tidy_data,"tidy.txt",sep=",",row.names=FALSE)
