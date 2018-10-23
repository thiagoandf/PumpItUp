# Creating Train and Test Dataset

trainData <- read.csv("data/Training set values - 4910797b-ee55-40a7-8668-10efd5c1b960.csv", sep=",")
trainData <- trainData[order(trainData$id),]
trainLabels <- read.csv("data/Training set labels - 0bf8bc6e-30d0-4c50-956a-603fc693d966.csv", sep=",")
trainLabels <- trainLabels[order(trainLabels$id),]
trainDataset <- cbind(trainData, status_group = trainLabels$status_group)

testData <- read.csv("data/Test set values  - 702ddfc5-68cd-4d1d-a0de-f5f566f76d91.csv", sep=",")
submissionFormat <- read.csv("data/SubmissionFormat.csv", sep=",")
testData <- cbind(testData, status_group = submissionFormat$status_group)

cleanData <- function(dataset, training = FALSE){
  
  # Meaningless columns
  dataset <- dataset[ , -which(names(dataset) %in% 
                                 c('id','num_private', 'wpt_name', 'recorded_by', 'date_recorded', 
                                   'funder', 'installer', 'scheme_name', 'public_meeting', 
                                   'scheme_management'))]
  
  # More than 53 factors
  dataset <- dataset[ , -which(names(dataset) %in% c('subvillage','lga','ward'))]
  
  # Removing repeated columns => identical()
  dataset <- dataset[ , -which(names(dataset) %in% c('payment_type', 'quantity_group'))]
  
  # Removing columns that mean the same thing
  dataset <- dataset[ , -which(names(dataset) %in% 
                                 c('region_code', 'source_type', 'source_class',
                                   'waterpoint_type_group', 'extraction_type_group',
                                   'extraction_type_class', 'management_group',
                                   'quality_group'))] # region_code means the same as region
  
  # There are many related fields, but the level of specificity required will be determined as we test
  # different algorithms
  if(training == TRUE) {
    # Removing meaningless rows
    dataset <- dataset[dataset$construction_year != 0,]
    dataset <- dataset[dataset$amount_tsh != 0,]
    dataset <- dataset[dataset$permit != '',]
    dataset <- dataset[dataset$population > 1,]
    dataset <- dataset[complete.cases(dataset), ]
  }
  return(dataset)
}

trainDataset <- cleanData(trainDataset, training = TRUE)
testData <- cleanData(testData)


library(randomForest)
# small trick nao sei o que faz
testData <- rbind(trainDataset[1, ] , testData)
testData <- testData[-1,]


ntree <- c(500,700)
mtry <- c(5,9,12)
nodesize <- c(1, 3)
#maxnodes <- c(10,100,NA)

formula <- status_group ~ .
result <- data.frame(mtry=integer(), ntree=integer(), nodesize=integer(),  oob=integer())
for(i in mtry){
  for(j in ntree){
    for(k in nodesize){
      print(paste(i,'  ',j,'  ',k))
      model <- randomForest(formula, data=trainDataset, mtry = i, ntree = j, nodesize = k, na.action=na.roughfix)  
      result <- rbind(result, c(i,j,k,model$err.rate[nrow(model$err.rate),1]))
    }
  }
}
names(result) <- c('mtry','ntree','nodesize','oob')
View(result)

#
# A configuracao com o menor OOB foi mtry = 5, ntree = 700, nodesize = 3
# OOB = 16,63%
# criando modelo com esta configuração:

model <- randomForest(myFormula, data=train, do.trace=100, mtry = 5, ntree=700, nodesize=3)
plot(model)
pred <- predict(model, newdata = testData)
confusionMatrix(table(pred,test$Y))

submissionFormat <- data.frame(testData$id, pred)
write.csv(submissionFormat, "Submission.csv")

