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
trainDataset$date_recorded <- NULL # Could be used in a more sophisticated model; will evaluate later
trainDataset$funder <- NULL
trainDataset$installer <- NULL
trainDataset$scheme_name <- NULL
trainDataset$payment <- NULL # same as payment_type
trainDataset$public_meeting <- NULL # unclear meaning
trainDataset$scheme_management <- NULL

# Factors bigger than 53
trainDataset$subvillage <- NULL
trainDataset$lga <- NULL
trainDataset$ward <- NULL

identical(trainDataset$quantity, trainDataset$quantity_group)
trainDataset$quantity_group <- NULL

# Will remove further columns
# There are many related fields, but the level of specificity required will be determined as we test
# different algorithms


# Removing meaningless rows
trainDataset <- trainDataset[trainDataset$construction_year != 0,]
trainDataset <- trainDataset[trainDataset$amount_tsh != 0,]
trainDataset <- trainDataset[trainDataset$permit != "",]
trainDataset <- trainDataset[trainDataset$population > 1,]

# View(trainDataset)

testData <- read.csv("data/Test set values  - 702ddfc5-68cd-4d1d-a0de-f5f566f76d91.csv", sep=",")
submissionFormat <- read.csv("data/SubmissionFormat.csv", sep=",")

status_group <- submissionFormat$status_group
testData <- cbind(testData, status_group)

# Removing meaningless columns
testData$num_private <- NULL
testData$wpt_name <- NULL
testData$recorded_by <- NULL
testData$date_recorded <- NULL
testData$funder <- NULL
testData$installer <- NULL
testData$scheme_name <- NULL
testData$payment <- NULL
testData$public_meeting <- NULL
testData$scheme_management <- NULL

# Factors bigger than 53
testData$subvillage <- NULL
testData$lga <- NULL
testData$ward <- NULL


testData$quantity_group <- NULL

# Removing meaningless rows
testData <- testData[testData$construction_year != 0,]
testData <- testData[testData$amount_tsh != 0,]
testData <- testData[testData$permit != "",]
testData <- testData[testData$population > 1,]


library(randomForest)
# small trick nao sei o que faz
testData <- rbind(trainDataset[1, ] , testData)
testData <- testData[-1,]
formula <- status_group ~ .
model <- randomForest(formula, data = trainDataset)
prediction <- predict(model, newdata = testData)

submissionFormat <- data.frame(testData$id, prediction)
View(submissionFormat)

write.csv(submissionFormat, "Submission.csv")

