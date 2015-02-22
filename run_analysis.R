# script should be placed in the folder containing the README file for the UCI HAR dataset
library(reshape2)

# load the test data
filename = "./test/X_test.txt"
testdata <- read.table(filename,colClasses="numeric",header=F,stringsAsFactors=F)

# load the test activities
filename = "./test/y_test.txt"
testactivities <- read.table(filename,colClasses="numeric",header=F,stringsAsFactors=F,col.names = "ActivityID")

# load the test subject data
filename = "./test/subject_test.txt"
testsubjects <- read.table(filename,colClasses="numeric",header=F,stringsAsFactors=F,col.names = "SubjectID")

# load the training  data
filename = "./train/X_train.txt"
traindata <- read.table(filename,colClasses="numeric",header=F,stringsAsFactors=F)

# load the training  activities
filename = "./train/y_train.txt"
trainactivities <- read.table(filename,colClasses="numeric",header=F,stringsAsFactors=F,col.names = "ActivityID")

# load the training subject data
filename = "./train/subject_train.txt"
trainsubjects <- read.table(filename,colClasses="numeric",header=F,stringsAsFactors=F,col.names = "SubjectID")

# 1. Merges the training and the test sets to create one data set.
# add the activity column to the test data
testdatamerged <- cbind(testdata,testactivities,testsubjects)

# add the activity column to the training data
traindatamerged <- cbind(traindata,trainactivities,trainsubjects)

# merge the two dataframes by adding the rows from the test data to the rows of the training data
mergeddata <- rbind(testdatamerged,traindatamerged)

# load the features (column names)
filename = "./features.txt"
features <- read.table(filename,header=F,stringsAsFactors=F,col.names= c("ColID","ColName"))

# labels the columns
colnames(mergeddata) <- c(features$ColName,"ActivityID","SubjectID")

# get the columns with mean and std in the column name
wantedcolnumbers <- c(grep("mean|std",features$ColName, ignore.case = T),which(colnames(mergeddata) %in% c("ActivityID","SubjectID")))

# get the columns from the merged data
activitydata <- mergeddata[,c(wantedcolnumbers)]

filename <- "activity_labels.txt"
activitylabels <- read.table(filename,header=F,stringsAsFactors=F,col.names=c("ActivityID","ActivityName"))

# add the activity names to the data set
activitydata <- merge(activitydata,activitylabels,by="ActivityID")

# get the column names to melt
colnamestomelt <- colnames(activitydata)
colnamestomelt <- colnamestomelt[colnamestomelt != "ActivityName" & colnamestomelt != "SubjectID" & colnamestomelt != "ActivityID"]
melted <- melt(activitydata,id="SubjectID",measure.vars=colnamestomelt)

# pivot table with subject id and mean of values
meandata <- dcast(melted,SubjectID ~ variable,mean)

# write data to the file
write.table(meandata,file="meandata.txt",row.names=FALSE)
