# Pump it Up

trainData <- read.csv("data/Training set values - 4910797b-ee55-40a7-8668-10efd5c1b960.csv", sep=",")
trainData <- trainData[order(trainData$id),]

trainLabels <- read.csv("data/Training set labels - 0bf8bc6e-30d0-4c50-956a-603fc693d966.csv", sep=",")
trainLabels <- trainLabels[order(trainLabels$id),]

status_group <- trainLabels$status_group

trainDataset <- cbind(trainData, status_group)

# Removing meaningless columns
trainDataset$num_private <- NULL
trainDataset$wpt_name <- NULL
trainDataset$recorded_by <- NULL
trainDataset$date_recorded <- NULL
trainDataset$funder <- NULL
trainDataset$installer <- NULL

identical(trainDataset$quantity, trainDataset$quantity_group)
trainDataset$quantity_group <- NULL

# Removing meaningless rows
trainDataset <- trainDataset[trainDataset$construction_year != 0,]
trainDataset <- trainDataset[trainDataset$amount_tsh != 0,]

View(trainDataset)


testData <- read.csv("data/Test set values  - 702ddfc5-68cd-4d1d-a0de-f5f566f76d91.csv", sep=",")
testData

submissionFormat <- read.csv("data/SubmissionFormat.csv", sep=",")
submissionFormat
